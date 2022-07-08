import 'dart:convert';
import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:riverpod/riverpod.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_locale_translations.dart';
import '../../entity/arb/arb_placeholder.dart';
import '../../entity/arb/arb_template.dart';
import '../../entity/arb/arb_translation.dart';
import '../../entity/project/l10n_configuration.dart';
import '../../entity/project/load_stage.dart';
import '../../entity/project/project.dart';
import '../../entity/project/recent_project.dart';
import '../../exception/l10n_arb_exception.dart';
import '../../exception/l10n_exception.dart';
import '../../exception/l10n_fix_exception.dart';
import '../../exception/l10n_pubspec_exception.dart';
import '../../provider/providers.dart';
import '../../validator/arb_validator.dart';
import 'recent_projects_usecase.dart';

part 'notifier/project_notifier.dart';

class ProjectUsecase {
  const ProjectUsecase({required this.read, required this.recentProjectsUsecase});

  static final _localeFromFileNameRegExp = RegExp(r'^\w+_(\w\w).arb$');
  static const asyncDelay = Duration(milliseconds: 100);

  final Reader read;
  final RecentProjectsUsecase recentProjectsUsecase;

  void closeProject() => read(projectProvider.notifier)._close();

  void cancelLoading() => read(projectProvider.notifier)._loadStage(LoadStage.canceled);

  Future<void> loadProject({required String projectPath}) async {
    final projectNotifier = read(projectProvider.notifier);
    try {
      await _initProject(projectPath: projectPath);

      if (read(projectProvider).loadStage.isFinished) return;
      await _loadPubspec();

      if (read(projectProvider).loadStage.isFinished) return;
      await _defineConfiguration();

      if (read(projectProvider).loadStage.isFinished) return;
      await _readTemplateFile();

      if (read(projectProvider).loadStage.isFinished) return;
      await _readTranslationFiles();

      if (read(projectProvider).loadStage.isFinished) return;
      await _saveToRecentProjects();

      if (read(projectProvider).loadStage.isFinished) return;
      await _setLoaded();
    } on L10nException catch (e) {
      projectNotifier._l10nException(e);
    } catch (e) {
      projectNotifier._l10nException(L10nGenericError(e));
    }
  }

  Future<void> _initProject({required String projectPath}) async {
    final projectNotifier = read(projectProvider.notifier);
    projectNotifier._loadStage(LoadStage.initial);
    await Future.delayed(asyncDelay);

    read(arbUsecaseProvider).clearSelection();
    read(projectProvider.notifier)._init(projectPath);
  }

  Future<void> _loadPubspec() async {
    final projectNotifier = read(projectProvider.notifier);
    projectNotifier._loadStage(LoadStage.readingPubspec);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    final file = File('${project.path}/pubspec.yaml');
    if (!await file.exists()) {
      throw const L10nMissingPubspecException();
    }

    final content = await file.readAsString();
    final pubspec = Pubspec.parse(content);
    projectNotifier._name(pubspec.name);

    const localizationsDepName = 'flutter_localizations';
    var dep = pubspec.dependencies[localizationsDepName];
    if (dep == null) {
      throwMissingDependency(localizationsDepName, projectPath: project.path, isSDK: true);
    }
    if (dep is! SdkDependency) {
      throw const L10nIncompleteDependencyException(localizationsDepName);
    }

    const intlDepName = 'intl';
    dep = pubspec.dependencies[intlDepName];
    if (dep == null) {
      throwMissingDependency(intlDepName, projectPath: project.path);
    }

    final generate = pubspec.flutter?['generate'] == true;
    projectNotifier._generateFlag(generate);
  }

  Future<void> _defineConfiguration() async {
    final projectNotifier = read(projectProvider.notifier);
    projectNotifier._loadStage(LoadStage.definingConfiguration);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    final file = File('${project.path}/l10n.yaml');

    late L10nConfiguration configuration;
    if (!await file.exists()) {
      configuration = const L10nConfiguration(usingYamlFile: false);
    } else {
      final content = await file.readAsString();
      final yaml = loadYaml(content) ?? <String, dynamic>{};
      if (yaml is! Map) {
        throw const L10nInvalidConfigurationFileException();
      }

      configuration = L10nConfiguration(
        usingYamlFile: true,
        arbDir: yaml['arb-dir'] ?? '',
        templateArbFile: yaml['template-arb-file'] ?? '',
        syntheticPackage: yaml['synthetic-package'] ?? L10nConfiguration.defaultSyntheticPackage,
        outputDir: yaml['output-dir'] ?? '',
        outputLocalizationFile: yaml['output-localization-file'] ?? '',
        outputClass: yaml['output-class'] ?? '',
        header: yaml['header'] ?? '',
        requiredResourceAttributes: yaml['required-resource-attributes'] ??
            L10nConfiguration.defaultRequiredResourceAttributes,
        nullableGetter: yaml['nullable-getter'] ?? L10nConfiguration.defaultNullableGetter,
      );
    }
    projectNotifier._configuration(configuration);
  }

  Future<void> _readTemplateFile() async {
    final projectNotifier = read(projectProvider.notifier);
    projectNotifier._loadStage(LoadStage.readingDefinitions);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    final config = project.configuration;
    final dir = Directory('${project.path}/${config.effectiveArbDir}');
    if (!await dir.exists()) {
      throwMissingArbFolder(dir, config.effectiveArbDir);
    }

    final path = '${project.path}/${config.effectiveArbDir}/${config.effectiveTemplateArbFile}';
    final file = File(path);
    if (!await file.exists()) {
      throwMissingTemplateFile(file, config);
    }

    final content = await file.readAsString();
    final global = <String, String>{};
    final translations = <String, String>{};
    final definitions = <String, dynamic>{};
    final arb = jsonDecode(content);
    if (arb is! Map<String, dynamic>) {
      throw L10nArbFileFormatException(config.effectiveTemplateArbFile);
    }

    for (final entry in arb.entries) {
      if (entry.key.startsWith('@@')) {
        if (entry.value is String) {
          global[entry.key] = entry.value;
        } else {
          throw L10nArbGlobalDefinitionException(entry.key);
        }
      } else if (entry.key.startsWith('@')) {
        definitions[entry.key] = entry.value;
      } else {
        if (entry.value is String) {
          translations[entry.key] = entry.value;
        } else {
          throw L10nArbDefinitionException(entry.key);
        }
      }
    }

    const validator = ArbValidator();
    validator.validate(
      configuration: project.configuration,
      translations: translations,
      definitions: definitions,
    );

    final locale = _locale(config.effectiveTemplateArbFile, arb);
    final template = _arbTemplate(global: global, translations: translations, meta: definitions);
    projectNotifier._template(template);
    projectNotifier._localeTranslations(_localeTranslations(locale, translations));
  }

  ArbTemplate _arbTemplate({
    required Map<String, String> global,
    required Map<String, String> translations,
    required Map<String, dynamic> meta,
  }) {
    final globalResources = global.entries.map((e) => ArbTranslation(key: e.key, value: e.value));
    final definitions =
        translations.entries.map((keyValue) => _definition(keyValue.key, keyValue.value, meta));
    return ArbTemplate(
      globalResources: globalResources.toList(growable: false),
      definitions: definitions.toList(growable: false),
    );
  }

  ArbDefinition _definition(String key, String value, Map<String, dynamic> meta) {
    final definitionKey = '@$key';
    final definitionMap = meta[definitionKey];
    return ArbDefinition(
      key: key,
      value: value,
      context: definitionMap?['context'] as String?,
      description: definitionMap?['description'] as String?,
      placeholders: _placeholders(definitionMap?['placeholders'] as Map<String, dynamic>?),
    );
  }

  List<ArbPlaceholderBase>? _placeholders(Map<String, dynamic>? placeholders) {
    if (placeholders == null) {
      return null;
    }
    final arbPlaceholders = <ArbPlaceholderBase>[];
    for (final entry in placeholders.entries) {
      if (entry.value is! Map<String, dynamic>) {
        throw L10nArbPlaceholdersFormatException(entry.key);
      }
      final key = entry.key;
      final type = entry.value['type'] as String?;
      final desc = entry.value['description'] as String? ?? '';
      final example = entry.value['example'] as String? ?? '';
      if (type == null) {
        arbPlaceholders.add(ArbPlaceholder(key: key, description: desc, example: example));
      } else if (type == 'String') {
        arbPlaceholders.add(ArbStringPlaceholder(key: key, description: desc, example: example));
      } else if (type == 'DateTime') {
        arbPlaceholders.add(
          ArbDateTimePlaceholder(
            key: key,
            description: desc,
            example: example,
            format: entry.value['format'] ?? '',
            isCustomDateFormat: entry.value['isCustomDateFormat'] == "true",
          ),
        );
      } else if (type == 'num' || type == 'int' || type == 'double') {
        final formatName = entry.value['format'] as String?;
        final format = formatName == null ? null : ArbNumberPlaceholderFormat.forName(formatName);
        final optionalParamsMap = entry.value['optionalParameters'] as Map<String, dynamic>?;
        final optionalParameters = <String, String>{};
        if (format != null && optionalParamsMap != null) {
          for (final entry in optionalParamsMap.entries) {
            try {
              final parameter = ArbNumberPlaceholderParameter.forName(entry.key);
              if (format.optionalParameters.contains(parameter)) {
                optionalParameters[entry.key] = entry.value;
              }
            } catch (e) {
              throw const L10nException();
            }
          }
        }
        arbPlaceholders.add(
          ArbNumberPlaceholder(
            key: key,
            description: desc,
            example: example,
            type: ArbPlaceholderType.forType(type),
            format: format,
            optionalParameters: optionalParameters,
          ),
        );
      }
    }
    return arbPlaceholders;
  }

  Future<void> _readTranslationFiles() async {
    final projectNotifier = read(projectProvider.notifier);
    projectNotifier._loadStage(LoadStage.readingTranslations);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    final configuration = project.configuration;
    final dir = Directory('${project.path}/${configuration.effectiveArbDir}');
    if (!await dir.exists()) {
      throwMissingArbFolder(dir, configuration.effectiveArbDir);
    }

    final languageFiles = <File>[];
    final dirList = dir.listSync();
    for (final file in dirList) {
      if (file is File) {
        final name = file.uri.pathSegments.last;
        if (name.endsWith('.arb')) {
          if (name != configuration.effectiveTemplateArbFile) {
            languageFiles.add(file);
          }
        }
      }
    }
    for (final file in languageFiles) {
      final localeTranslations = await _readTranslationFile(file);
      projectNotifier._localeTranslations(localeTranslations);
    }
  }

  Future<ArbLocaleTranslations> _readTranslationFile(File file) async {
    final name = file.uri.pathSegments.last;
    final content = await file.readAsString();
    final arb = json.decode(content);
    if (arb is! Map<String, dynamic>) {
      throw L10nArbFileFormatException(name);
    }

    final locale = _locale(name, arb);
    final translationsMap = <String, String>{};
    for (final entry in arb.entries) {
      if (!entry.key.startsWith('@')) {
        if (entry.value is String) {
          translationsMap[entry.key] = entry.value;
        } else {
          throw L10nArbDefinitionException(entry.key);
        }
      }
    }
    return _localeTranslations(locale, translationsMap);
  }

  ArbLocaleTranslations _localeTranslations(String locale, Map<String, String> translationsMap) {
    final translations = <String, ArbTranslation>{};
    for (final entry in translationsMap.entries) {
      translations[entry.key] = ArbTranslation(key: entry.key, value: entry.value);
    }
    return ArbLocaleTranslations(locale: locale, translations: translations);
  }

  String _locale(String fileName, Map<String, dynamic> arb) =>
      arb['@@locale'] ?? _matchLocaleFromFileName(fileName);

  String _matchLocaleFromFileName(String name) {
    final match = _localeFromFileNameRegExp.firstMatch(name);
    if (match == null) {
      throw L10nFileMissingLocaleException(name);
    }
    return match.group(1)!;
  }

  Future<void> _saveToRecentProjects() async {
    final projectNotifier = read(projectProvider.notifier);
    projectNotifier._loadStage(LoadStage.savingToRecentProjects);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    final recentProject = RecentProject(name: project.name, path: project.path);
    recentProjectsUsecase.setFirst(recentProject);
  }

  Future<void> _setLoaded() async {
    final projectNotifier = read(projectProvider.notifier);
    projectNotifier._loadStage(LoadStage.loaded);
    await Future.delayed(asyncDelay);
  }

  Future<void> saveConfiguration(L10nConfiguration conf) async {
    final project = read(projectProvider);
    final writer = YAMLWriter();
    final content = writer.write({
      if (conf.arbDir.isNotEmpty) 'arb-dir': conf.arbDir,
      if (conf.templateArbFile.isNotEmpty) 'template-arb-file': conf.templateArbFile,
      if (conf.requiredResourceAttributes != L10nConfiguration.defaultRequiredResourceAttributes)
        'required-resource-attributes': conf.requiredResourceAttributes,
      if (conf.syntheticPackage != L10nConfiguration.defaultSyntheticPackage)
        'synthetic-package': conf.syntheticPackage,
      if (conf.outputDir.isNotEmpty) 'output-dir': conf.outputDir,
      if (conf.outputLocalizationFile.isNotEmpty)
        'output-localization-file': conf.outputLocalizationFile,
      if (conf.outputClass.isNotEmpty) 'output-class': conf.outputClass,
      if (conf.nullableGetter != L10nConfiguration.defaultNullableGetter)
        'nullable-getter': conf.nullableGetter,
      if (conf.header.isNotEmpty) 'header': conf.header,
    });
    final file = File('${project.path}/l10n.yaml');
    await file.writeAsString(content);
  }

  void throwMissingDependency(String depName, {required String projectPath, bool isSDK = false}) {
    throw L10nMissingDependencyException(
      depName,
      fixActionLabel: 'Add Dependency',
      fixActionDescription: 'Add "$depName" dependecy.',
      fixActionInfo: 'Add required dependency to pubspec.yaml and reload this project.',
      fixActionCallback: () => _addDependency(depName, projectPath: projectPath, isSDK: isSDK),
    );
  }

  Future<void> _addDependency(
    String depName, {
    required String projectPath,
    bool isSDK = false,
    bool isDev = false,
  }) async {
    final result = await Process.run(
      'flutter',
      [
        'pub',
        'add',
        if (isDev) '--dev',
        depName,
        if (isSDK) '--sdk=flutter',
      ],
      workingDirectory: projectPath,
      runInShell: true,
    );
    if (result.exitCode != 0) {
      final exception = L10nAddDependencyError(depName);
      read(projectProvider.notifier)._l10nException(exception);
      throw exception;
    }
  }

  void throwMissingArbFolder(Directory dir, String folderName) {
    throw L10nMissingArbFolderException(
      folderName,
      fixActionLabel: 'Create Folder',
      fixActionDescription: 'Create ARB folder.',
      fixActionInfo: 'Create missing folder in this project structure.',
      fixActionCallback: () => _createFolder(dir, folderName),
    );
  }

  Future<void> _createFolder(Directory dir, String folderName) async {
    try {
      await dir.create(recursive: true);
    } catch (e) {
      final exception = L10nCreateFolderError(folderName);
      read(projectProvider.notifier)._l10nException(exception);
      throw exception;
    }
  }

  void throwMissingTemplateFile(File file, L10nConfiguration configuration) {
    final path = '${configuration.effectiveArbDir}/${configuration.effectiveTemplateArbFile}';
    throw L10nMissingArbTemplateFileException(
      path,
      fixActionLabel: 'Create Template File',
      fixActionDescription: 'Create "${configuration.effectiveTemplateArbFile}" template file.',
      fixActionInfo:
          'Create missing "${configuration.effectiveTemplateArbFile}" template file inside this project ARB folder.',
      fixActionCallback: () => _createTemplateFile(file, configuration.effectiveTemplateArbFile),
    );
  }

  Future<void> _createTemplateFile(File file, String fileName) async {
    late final String locale;
    try {
      locale = _matchLocaleFromFileName(fileName);
    } on L10nFileMissingLocaleException {
      final exception = L10nCreateTemplateFileWithoutLocaleSufixError(fileName);
      read(projectProvider.notifier)._l10nException(exception);
      throw exception;
    }
    try {
      await file.create(recursive: true);
      await file.writeAsString('{\n  "@@locale": "$locale"\n}\n');
    } catch (e) {
      final exception = L10nCreateTemplateFileError(fileName);
      read(projectProvider.notifier)._l10nException(exception);
      throw exception;
    }
  }
}

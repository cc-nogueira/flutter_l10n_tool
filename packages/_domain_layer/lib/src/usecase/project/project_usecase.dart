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
import '../../entity/project/project.dart';
import '../../exception/l10n_arb_exception.dart';
import '../../exception/l10n_exception.dart';
import '../../exception/l10n_fix_exception.dart';
import '../../exception/l10n_pubspec_exception.dart';
import '../../provider/providers.dart';
import '../../validator/arb_validator.dart';

part 'notifier/project_notifier.dart';

class ProjectUsecase {
  const ProjectUsecase({required this.read});

  static final _localeFromFileNameRegExp = RegExp(r'^\w+_(\w\w).arb$');

  final Reader read;

  void initProject({required String projectPath}) => _projectNotifier._init(projectPath);

  void finishedLoading() => _projectNotifier._finishedLoading();

  void closeProject() => _projectNotifier._close();

  Future<void> saveConfiguration(L10nConfiguration conf) async {
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
    final file = File('${_project.path}/l10n.yaml');
    await file.writeAsString(content);
  }

  Future<void> loadPubspec() async {
    final file = File('${_project.path}/pubspec.yaml');
    try {
      if (file.existsSync()) {
        final content = await file.readAsString();
        _readPubspec(content);
      } else {
        throw const L10nMissingPubspecException();
      }
    } on L10nException catch (e) {
      _projectNotifier._l10nException(e);
      rethrow;
    } catch (e) {
      _projectNotifier._l10nException(L10nGenericError(e));
      rethrow;
    }
  }

  Future<void> defineConfiguration() async {
    final file = File('${_project.path}/l10n.yaml');
    late L10nConfiguration configuration;
    if (file.existsSync()) {
      try {
        final content = await file.readAsString();
        configuration = _readL10nConfiguration(content);
      } on L10nException catch (e) {
        _projectNotifier._l10nException(e);
        rethrow;
      } catch (e) {
        _projectNotifier._l10nException(L10nGenericError(e));
        rethrow;
      }
    } else {
      configuration = const L10nConfiguration(usingYamlFile: false);
    }
    _projectNotifier._configuration(configuration);
  }

  Future<void> readTemplateFile() async {
    final project = _project;
    final configuration = project.configuration;
    final dir = Directory('${project.path}/${configuration.effectiveArbDir}');
    try {
      if (!dir.existsSync()) {
        throwMissingArbFolder(configuration);
      }
      final file = File(
          '${project.path}/${configuration.effectiveArbDir}/${configuration.effectiveTemplateArbFile}');
      if (file.existsSync()) {
        final content = await file.readAsString();
        _readTemplateFile(configuration.effectiveTemplateArbFile, content);
      } else {
        throwMissingTemplateFile(configuration);
      }
    } on L10nException catch (e) {
      _projectNotifier._l10nException(e);
      rethrow;
    } catch (e) {
      _projectNotifier._l10nException(L10nGenericError(e));
      rethrow;
    }
  }

  Future<void> readTranslationFiles() async {
    final project = _project;
    final configuration = project.configuration;
    final dir = Directory('${project.path}/${configuration.effectiveArbDir}');
    try {
      if (dir.existsSync()) {
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
          await _readTranslationFile(file);
        }
      } else {
        throwMissingArbFolder(configuration);
      }
    } on L10nException catch (e) {
      _projectNotifier._l10nException(e);
      rethrow;
    } catch (e) {
      _projectNotifier._l10nException(L10nGenericError(e));
      rethrow;
    }
  }

  Project get _project => read(projectProvider);
  ProjectNotifier get _projectNotifier => read(projectProvider.notifier);

  void _readPubspec(String yaml) {
    final pubspec = Pubspec.parse(yaml);
    _projectNotifier._name(pubspec.name);

    const localizationsDepName = 'flutter_localizations';
    var dep = pubspec.dependencies[localizationsDepName];
    if (dep == null) {
      throwMissingDependency(localizationsDepName, isSDK: true);
    }
    if (dep is! SdkDependency) {
      throw const L10nIncompleteDependencyException(localizationsDepName);
    }

    const intlDepName = 'intl';
    dep = pubspec.dependencies[intlDepName];
    if (dep == null) {
      throwMissingDependency(intlDepName);
    }

    final generate = pubspec.flutter?['generate'] == true;
    _projectNotifier._generateFlag(generate);
  }

  L10nConfiguration _readL10nConfiguration(String content) {
    final yaml = loadYaml(content) ?? <String, dynamic>{};
    if (yaml is Map) {
      return L10nConfiguration(
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
    } else {
      throw const L10nInvalidConfigurationFileException();
    }
  }

  void _readTemplateFile(String fileName, String content) {
    final global = <String, String>{};
    final translations = <String, String>{};
    final definitions = <String, dynamic>{};
    final arb = jsonDecode(content);
    if (arb is Map<String, dynamic>) {
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
    } else {
      throw L10nArbFileFormatException(fileName);
    }

    final validator =
        ArbValidator(_project.configuration, translations: translations, definitions: definitions);
    validator.validate();

    final String locale = _locale(fileName, arb);
    _projectNotifier
        ._template(_arbTemplate(global: global, translations: translations, meta: definitions));
    _projectNotifier._localeTranslations(_localeTranslations(locale, translations));
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
      final desc = entry.value['description'] as String?;
      final example = entry.value['example'] as String?;
      if (type == null) {
        arbPlaceholders.add(ArbPlaceholder(key: key, description: desc, example: example));
      } else if (type == 'DateTime') {
        arbPlaceholders.add(
          ArbDateTimePlaceholder(
            key: key,
            description: desc,
            example: example,
            format: entry.value['format'] as String?,
            isCustomDateFormat: entry.value['isCustomDateFormat'] == "true",
          ),
        );
      } else if (type == 'num' || type == 'int' || type == 'double') {
        final formatName = entry.value['format'] as String?;
        final format = formatName == null ? null : ArbNumberPlaceholderFormat.forName(formatName);
        final optionalParamsMap = entry.value['optionalParameters'] as Map<String, dynamic>?;
        late final Map<String, String>? optionalParameters;
        if (format == null || optionalParamsMap == null) {
          optionalParameters = null;
        } else {
          optionalParameters = {};
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

  ArbLocaleTranslations _localeTranslations(String locale, Map<String, String> translationsMap) {
    final translations = <String, ArbTranslation>{};
    for (final entry in translationsMap.entries) {
      translations[entry.key] = ArbTranslation(key: entry.key, value: entry.value);
    }
    return ArbLocaleTranslations(locale: locale, translations: translations);
  }

  Future<void> _readTranslationFile(File file) async {
    final name = file.uri.pathSegments.last;
    final content = await file.readAsString();
    final arb = json.decode(content);
    if (arb is Map<String, dynamic>) {
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
      _projectNotifier._localeTranslations(_localeTranslations(locale, translationsMap));
    } else {
      throw L10nArbFileFormatException(name);
    }
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

  void throwMissingDependency(String depName, {bool isSDK = false}) {
    throw L10nMissingDependencyException(
      depName,
      fixActionLabel: 'Add Dependency',
      fixActionDescription: 'Add "$depName" dependecy.',
      fixActionInfo: 'Add required dependency to pubspec.yaml and reload this project.',
      fixActionCallback: () => _addDependency(depName, isSDK: isSDK),
    );
  }

  Future<void> _addDependency(
    String depName, {
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
      workingDirectory: _project.path,
      runInShell: true,
    );
    if (result.exitCode != 0) {
      final exception = L10nAddDependencyError(depName);
      _projectNotifier._l10nException(exception);
      throw exception;
    }
  }

  void throwMissingArbFolder(L10nConfiguration configuration) {
    throw L10nMissingArbFolderException(
      configuration.effectiveArbDir,
      fixActionLabel: 'Create Folder',
      fixActionDescription: 'Create ARB folder.',
      fixActionInfo: 'Create missing folder in this project structure.',
      fixActionCallback: () => _createFolder(configuration.effectiveArbDir),
    );
  }

  Future<void> _createFolder(String folder) async {
    final dir = Directory(folder);
    try {
      await dir.create(recursive: true);
    } catch (e) {
      final exception = L10nCreateFolderError(folder);
      _projectNotifier._l10nException(exception);
      throw exception;
    }
  }

  void throwMissingTemplateFile(L10nConfiguration configuration) {
    final path = '${configuration.effectiveArbDir}/${configuration.effectiveTemplateArbFile}';
    throw L10nMissingArbTemplateFileException(
      path,
      fixActionLabel: 'Create Template File',
      fixActionDescription: 'Create "${configuration.effectiveTemplateArbFile}" template file.',
      fixActionInfo:
          'Create missing "${configuration.effectiveTemplateArbFile}" template file inside this project ARB folder.',
      fixActionCallback: () => _createTemplateFile(
          configuration.effectiveArbDir, configuration.effectiveTemplateArbFile),
    );
  }

  Future<void> _createTemplateFile(String folder, String fileName) async {
    final dir = Directory(folder);
    if (!dir.existsSync()) {
      throw StateError('Could not find ARB folder');
    }
    final file = File('$folder/$fileName');
    late final String locale;
    try {
      locale = _matchLocaleFromFileName(fileName);
    } on L10nFileMissingLocaleException {
      final exception = L10nCreateTemplateFileWithoutLocaleSufixError(fileName);
      _projectNotifier._l10nException(exception);
      throw exception;
    }
    try {
      await file.writeAsString('{\n  "@@locale": "$locale"\n}\n');
    } catch (e) {
      final exception = L10nCreateTemplateFileError(fileName);
      _projectNotifier._l10nException(exception);
      throw exception;
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:riverpod/riverpod.dart';
import 'package:yaml/yaml.dart';

import '../entity/project/arb_locale_translations.dart';
import '../entity/project/arb_placeholder.dart';
import '../entity/project/arb_resource.dart';
import '../entity/project/arb_template.dart';
import '../entity/project/l10n_configuration.dart';
import '../entity/project/project.dart';
import '../exception/arb_exception.dart';
import '../exception/pubspec_exception.dart';
import '../provider/providers.dart';
import '../validator/arb_validator.dart';

class ProjectUsecase {
  const ProjectUsecase(this.read);

  final Reader read;

  static final _localeFromFileNameRegExp = RegExp(r'^\w+_(\w\w).arb$');

  void initProject({required String projectPath}) => _projectNotifier._init(projectPath);

  void closeProject() => _projectNotifier._close();

  Future<void> loadPubspec() async {
    final file = File('${_project.path}/pubspec.yaml');
    if (file.existsSync()) {
      final content = await file.readAsString();
      _readPubspec(content);
    } else {
      throw const MissingPubspecException();
    }
  }

  Future<void> defineConfiguration() async {
    final file = File('${_project.path}/l10n.yaml');
    late L10nConfiguration configuration;
    if (file.existsSync()) {
      final content = await file.readAsString();
      configuration = _readL10nConfiguration(content);
    } else {
      configuration = const L10nConfiguration(isFromYamlFile: false);
    }
    _projectNotifier._configuration(configuration);
  }

  Future<void> readTemplateFile() async {
    final project = _project;
    final configuration = project.configuration;
    final dir = Directory('${project.path}/${configuration.arbDir}');
    if (!dir.existsSync()) {
      throw MissingArbDir(configuration.arbDir);
    }
    final file = File('${project.path}/${configuration.arbDir}/${configuration.templateArbFile}');
    if (file.existsSync()) {
      final content = await file.readAsString();
      _readTemplateFile(configuration.templateArbFile, content);
    } else {
      throw MissingArbTemplateFile('${configuration.arbDir}/${configuration.templateArbFile}');
    }
  }

  Future<void> readTranslationFiles() async {
    final project = _project;
    final configuration = project.configuration;
    final dir = Directory('${project.path}/${configuration.arbDir}');
    if (dir.existsSync()) {
      final languageFiles = <File>[];
      final dirList = dir.listSync();
      for (final file in dirList) {
        if (file is File) {
          final name = file.uri.pathSegments.last;
          if (name.endsWith('.arb')) {
            if (name != configuration.templateArbFile) {
              languageFiles.add(file);
            }
          }
        }
      }
      for (final file in languageFiles) {
        await _readTranslationFile(file);
      }
    } else {
      throw MissingArbDir(configuration.arbDir);
    }
  }

  void confirmLoaded() {
    final project = _project;
    if (project.path.isEmpty || project.translations.isEmpty) {
      throw StateError('Project cannot be confirmed as loaded.');
    }
    _projectNotifier.confirmLoaded();
  }

  Project get _project => read(projectProvider);
  ProjectNotifier get _projectNotifier => read(projectProvider.notifier);

  void _readPubspec(String yaml) {
    final pubspec = Pubspec.parse(yaml);
    _projectNotifier.name(pubspec.name);

    const depName = 'flutter_localizations';
    final dep = pubspec.dependencies[depName];
    if (dep == null) {
      throw DependencyException.missing(depName);
    }
    if (dep is! SdkDependency) {
      throw DependencyException.incomplete(depName);
    }
  }

  L10nConfiguration _readL10nConfiguration(String content) {
    final yaml = loadYaml(content);
    final conf = yaml is Map ? yaml : <String, dynamic>{};
    return L10nConfiguration(
      isFromYamlFile: true,
      syntheticPackage: conf['synthetic-package'] ?? L10nConfiguration.defaultSyntheticPackage,
      arbDir: conf['arb-dir'] ?? L10nConfiguration.defaultArbDir,
      outputDir: conf['output-dir'] ?? L10nConfiguration.defaultOutputDir,
      templateArbFile: conf['template-arb-file'] ?? L10nConfiguration.defaultTemplateArbFile,
      outputLocalizationFile:
          conf['output-localization-file'] ?? L10nConfiguration.defaultOutputLocalizationFile,
      outputClass: conf['output-class'] ?? L10nConfiguration.defaultOutputClass,
      header: conf['header'] ?? L10nConfiguration.defaultHeader,
      requiredResourceAttributes: conf['required-resource-attributes'] ??
          L10nConfiguration.defaultRequiredResourceAttributes,
      nullableGetter: conf['nullable-getter'] ?? L10nConfiguration.defaultNullableGetter,
    );
  }

  void _readTemplateFile(String fileName, String content) {
    final global = <String, String>{};
    final resources = <String, String>{};
    final meta = <String, dynamic>{};
    final arb = jsonDecode(content);
    if (arb is Map<String, dynamic>) {
      for (final entry in arb.entries) {
        if (entry.key.startsWith('@@')) {
          if (entry.value is String) {
            global[entry.key] = entry.value;
          } else {
            throw ArbResourceDefinitionException.globalFormat(entry.key);
          }
        } else if (entry.key.startsWith('@')) {
          meta[entry.key] = entry.value;
        } else {
          if (entry.value is String) {
            resources[entry.key] = entry.value;
          } else {
            throw ArbResourceDefinitionException.format(entry.key);
          }
        }
      }
    } else {
      throw ArbFileFormatException(fileName);
    }

    final validator = ArbValidator(_project.configuration, resources: resources, meta: meta);
    validator.validate();

    final String locale = _locale(fileName, arb);
    _projectNotifier._template(_arbTemplate(global: global, resources: resources, meta: meta));
    _projectNotifier._localeTranslations(_localeTranslations(locale, resources));
  }

  ArbTemplate _arbTemplate({
    required Map<String, String> global,
    required Map<String, String> resources,
    required Map<String, dynamic> meta,
  }) {
    final globalResources = global.entries.map((e) => ArbResource(key: e.key, value: e.value));
    final resourceDefinitions = resources.keys.map((key) => _resourceDefinition(key, meta));
    return ArbTemplate(
      globalResources: globalResources.toList(growable: false),
      resourceDefinitions: resourceDefinitions.toList(growable: false),
    );
  }

  ArbResourceDefinition _resourceDefinition(String key, Map<String, dynamic> meta) {
    final attributeKey = '@$key';
    final attributes = meta[attributeKey];
    return ArbResourceDefinition(
      key: key,
      context: attributes?['context'] as String?,
      description: attributes?['description'] as String?,
      placeholders: _placeholders(attributes?['placeholders'] as Map<String, dynamic>?),
    );
  }

  List<ArbPlaceholderBase>? _placeholders(Map<String, dynamic>? placeholders) {
    if (placeholders == null) {
      return null;
    }
    final arbPlaceholders = <ArbPlaceholderBase>[];
    for (final entry in placeholders.entries) {
      if (entry.value is! Map<String, dynamic>) {
        throw ArbResourceDefinitionException.placeholdersFormat(entry.key, type: '');
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
              throw const ArbException();
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

  ArbLocaleTranslations _localeTranslations(String locale, Map<String, String> resources) {
    final arbResources = <ArbResource>[];
    for (final entry in resources.entries) {
      arbResources.add(ArbResource(key: entry.key, value: entry.value));
    }
    return ArbLocaleTranslations(locale: locale, translations: arbResources);
  }

  Future<void> _readTranslationFile(File file) async {
    final name = file.uri.pathSegments.last;
    final content = await file.readAsString();
    final arb = json.decode(content);
    if (arb is Map<String, dynamic>) {
      final locale = _locale(name, arb);
      final resources = <String, String>{};
      for (final entry in arb.entries) {
        if (!entry.key.startsWith('@')) {
          if (entry.value is String) {
            resources[entry.key] = entry.value;
          } else {
            throw ArbResourceDefinitionException.format(entry.key);
          }
        }
      }
      _projectNotifier._localeTranslations(_localeTranslations(locale, resources));
    } else {
      throw ArbFileFormatException(name);
    }
  }

  String _locale(String fileName, Map<String, dynamic> arb) =>
      arb['@@locale'] ?? _matchLocaleFromFileName(fileName);

  String _matchLocaleFromFileName(String name) {
    final match = _localeFromFileNameRegExp.firstMatch(name);
    if (match == null) {
      throw ArbFileMissingLocaleException(name);
    }
    return match.group(1)!;
  }
}

class ProjectNotifier extends StateNotifier<Project> {
  ProjectNotifier() : super(const Project());

  void _init(String path) {
    state = Project(path: path);
  }

  void _close() {
    state = const Project();
  }

  void name(String name) {
    state = state.copyWith(name: name);
  }

  void _configuration(L10nConfiguration configuration) {
    state = state.copyWith(configuration: configuration);
  }

  void _template(ArbTemplate template) {
    state = state.copyWith(template: template);
  }

  void _localeTranslations(ArbLocaleTranslations localeTranslations) {
    final locale = localeTranslations.locale;
    if (state.translations.containsKey(locale)) {
      throw ArbMultipleFilesWithSameLocationException(locale);
    }
    final translations = Map.of(state.translations);
    translations[locale] = localeTranslations;
    state = state.copyWith(translations: translations);
  }

  void confirmLoaded() {
    state = state.copyWith(loaded: true);
  }
}

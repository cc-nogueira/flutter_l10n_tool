import 'dart:convert';
import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:riverpod/riverpod.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../entity/project/arb_locale_translations.dart';
import '../entity/project/arb_placeholder.dart';
import '../entity/project/arb_resource.dart';
import '../entity/project/arb_template.dart';
import '../entity/project/l10n_configuration.dart';
import '../entity/project/project.dart';
import '../exception/l10n_arb_resource_definition_exception.dart';
import '../exception/l10n_exception.dart';
import '../exception/l10n_pubspec_exception.dart';
import '../provider/providers.dart';
import '../validator/arb_validator.dart';

class ProjectUsecase {
  const ProjectUsecase(this.read);

  final Reader read;

  static final _localeFromFileNameRegExp = RegExp(r'^\w+_(\w\w).arb$');

  void initProject({required String projectPath}) => _projectNotifier._init(projectPath);

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
      _projectNotifier._error(e);
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
        _projectNotifier._error(e);
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
        throw L10nMissingArbFolderException(configuration.effectiveArbDir);
      }
      final file = File(
          '${project.path}/${configuration.effectiveArbDir}/${configuration.effectiveTemplateArbFile}');
      if (file.existsSync()) {
        final content = await file.readAsString();
        _readTemplateFile(configuration.effectiveTemplateArbFile, content);
      } else {
        throw L10nMissingArbTemplateFileException(
            '${configuration.effectiveArbDir}/${configuration.effectiveTemplateArbFile}');
      }
    } on L10nException catch (e) {
      _projectNotifier._l10nException(e);
      rethrow;
    } catch (e) {
      _projectNotifier._error(e);
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
        throw L10nMissingArbFolderException(configuration.effectiveArbDir);
      }
    } on L10nException catch (e) {
      _projectNotifier._l10nException(e);
      rethrow;
    } catch (e) {
      _projectNotifier._error(e);
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
      throw const L10nMissingDependencyException(localizationsDepName);
    }
    if (dep is! SdkDependency) {
      throw const L10nIncompleteDependencyException(localizationsDepName);
    }

    const intlDepName = 'intl';
    dep = pubspec.dependencies[intlDepName];
    if (dep == null) {
      throw const L10nMissingDependencyException(intlDepName);
    }
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
    final resources = <String, String>{};
    final meta = <String, dynamic>{};
    final arb = jsonDecode(content);
    if (arb is Map<String, dynamic>) {
      for (final entry in arb.entries) {
        if (entry.key.startsWith('@@')) {
          if (entry.value is String) {
            global[entry.key] = entry.value;
          } else {
            throw L10nArbGlobalResourceDefinitionException(entry.key);
          }
        } else if (entry.key.startsWith('@')) {
          meta[entry.key] = entry.value;
        } else {
          if (entry.value is String) {
            resources[entry.key] = entry.value;
          } else {
            throw L10nArbResourceDefinitionException(entry.key);
          }
        }
      }
    } else {
      throw L10nArbFileFormatException(fileName);
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
    final resourceDefinitions = resources.entries
        .map((keyValue) => _resourceDefinition(keyValue.key, keyValue.value, meta));
    return ArbTemplate(
      globalResources: globalResources.toList(growable: false),
      resourceDefinitions: resourceDefinitions.toList(growable: false),
    );
  }

  ArbResourceDefinition _resourceDefinition(String key, String value, Map<String, dynamic> meta) {
    final attributeKey = '@$key';
    final attributes = meta[attributeKey];
    return ArbResourceDefinition(
      type: ArbResourceDefinition.typeForValue(value),
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
        throw L10nArbResourcePlaceholdersFormatException(entry.key);
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

  ArbLocaleTranslations _localeTranslations(String locale, Map<String, String> resources) {
    final arbResources = <String, ArbResource>{};
    for (final entry in resources.entries) {
      arbResources[entry.key] = ArbResource(key: entry.key, value: entry.value);
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
            throw L10nArbResourceDefinitionException(entry.key);
          }
        }
      }
      _projectNotifier._localeTranslations(_localeTranslations(locale, resources));
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
}

class ProjectNotifier extends StateNotifier<Project> {
  ProjectNotifier() : super(const Project());

  void _init(String path) {
    state = Project(path: path);
  }

  void _close() {
    state = const Project();
  }

  void _name(String name) {
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
      throw L10nMultipleFilesWithSameLocationException(locale);
    }
    final translations = Map.of(state.translations);
    translations[locale] = localeTranslations;
    state = state.copyWith(translations: translations);
  }

  void _l10nException(L10nException exception) {
    state = state.copyWith(l10nException: exception);
  }

  void _error(Object error) {
    state = state.copyWith(loadError: error);
  }
}

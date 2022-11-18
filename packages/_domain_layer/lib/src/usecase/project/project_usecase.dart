import 'dart:io';

import 'package:riverpod/riverpod.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_locale_translations.dart';
import '../../entity/project/l10n_configuration.dart';
import '../../entity/project/load_stage.dart';
import '../../entity/project/project.dart';
import '../../entity/project/recent_project.dart';
import '../../exception/l10n_exception.dart';
import '../../exception/l10n_fix_exception.dart';
import '../../exception/l10n_pubspec_exception.dart';
import '../../layer/domain_layer.dart';
import '../arb/arb_usecase.dart';
import '../recent_projects/recent_projects_usecase.dart';
import 'mixin/arb_mixin.dart';
import 'mixin/arb_template_mixin.dart';
import 'mixin/arb_validation_mixin.dart';
import 'mixin/l10n_configuration_mixin.dart';
import 'mixin/pubspec_mixin.dart';
import 'notifier/project_notifier.dart';
import 'project_scope.dart';

part 'project_providers.dart';

/// Use case for managing the project under edition.
///
/// Responsible for loading the localization for a Flutter project.
/// The configuration is extracted from the project's pubspec and from the optional l10n.yaml file.
///
/// The location of files defining the localization template and translation files is defined in this
/// loaded configuration.
///
/// The localization template is read into [ArbDefinition] objects, an union of possible types.
/// Translations are loaded for all translation files found in the above mentioned configuration dir.
///
/// The loading process fills a [Project] contains the [L10nConfiguration] and is stored in the
/// [ProjectScope] instance.
///
/// Later user edition of any [ArbDefinition] or [ArbTranslation] is performed by [ArbUsecase] and
/// stored at [ArbScope], preserving the [ProjectScope] for the original values loaded from disk.
/// These original values may be used to rollback changes performed by the user.
class ProjectUsecase
    with PubspecMixin, L10nConfigurationMixin, ArbMixin, ArbTemplateMixin, ArbValidationMixin {
  const ProjectUsecase({required this.ref, required this.recentProjectsUsecase});

  static const asyncDelay = Duration(milliseconds: 100);

  final Ref ref;
  final RecentProjectsUsecase recentProjectsUsecase;

  /// Creates a new [ProjectScope] to load a new project.
  /// Also triggers the creation of a new ArbScope through [ArbUsecase.initScope].
  void initScope() {
    ref.read(_projectScopeProvider.notifier).state = ProjectScope();
    ref.read(arbUsecaseProvider).initScope();
  }

  /// Closes the open project by re initializing execution scopes.
  void closeProject() {
    initScope();
  }

  /// Stops loading, leaving the project loading stage as canceled.
  void cancelLoading() {
    _projectNotifier().loadStage(LoadStage.canceled);
  }

  /// Loading of the whole project.
  ///
  /// The loading process is initializes a new [ProjectScope] and [ArbScope] for execution and
  /// goes through several async steps to load a project.
  ///
  /// After loading [ProjectScope] is changed only to retain changes in project configuration.
  /// All user editing on [ArbDefinition] and [ArbTranslation] is done through [ArbUsecase] changing
  /// its [ArbScope].
  ///
  /// The original definitions and translations kept in [ProjectScope] can be used to compare [ArbScope]
  /// values to their original or to allow user rollback actions.
  Future<void> loadProject({required String projectPath}) async {
    initScope();
    final projectNotifier = _projectNotifier();
    try {
      await _initProject(projectNotifier, projectPath: projectPath);
      if (ref.read(projectProvider).loadStage.isFinal) return;
      await _loadPubspec(projectNotifier);

      if (ref.read(projectProvider).loadStage.isFinal) return;
      await _defineConfiguration(projectNotifier);

      if (ref.read(projectProvider).loadStage.isFinal) return;
      await _readTemplateFile(projectNotifier);

      if (ref.read(projectProvider).loadStage.isFinal) return;
      await _readTranslationFiles(projectNotifier);

      if (ref.read(projectProvider).loadStage.isFinal) return;
      await _saveToRecentProjects(projectNotifier);

      if (ref.read(projectProvider).loadStage.isFinal) return;
      await _setLoaded(projectNotifier);
    } on L10nException catch (e) {
      projectNotifier.l10nException(e);
    } catch (e) {
      projectNotifier.l10nException(L10nGenericError(e));
    }
  }

  /// Internal - async method to init the loading process.
  ///
  /// Set the project load stage to [LoadStage.initial].
  /// Set the project path.
  Future<void> _initProject(ProjectNotifier projectNotifier, {required String projectPath}) async {
    projectNotifier.loadStage(LoadStage.initial);
    await Future.delayed(asyncDelay);

    ref.read(arbUsecaseProvider).clearSelection();
    projectNotifier.init(projectPath);
  }

  /// Internal - async method to load the pubspec file.
  ///
  /// - Set the project load stage to [LoadStage.readingPubspec].
  /// - Read the pubspec.yaml file.
  /// - Set project name.
  /// - Check required dependencies.
  /// - Set if the generate flag is set.
  ///   This flag is required if the configuration uses synthetic packages.
  Future<void> _loadPubspec(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.readingPubspec);
    await Future.delayed(asyncDelay);

    final project = ref.read(projectProvider);
    final pubspec = await readPubspec(project);
    projectNotifier.name(pubspec.name);

    try {
      checkPubspecDependency(project, pubspec, 'flutter_localizations', isSdk: true);
      checkPubspecDependency(project, pubspec, 'intl');
    } on L10nMissingDependencyError catch (e) {
      _throwMissingDependency(e.depName, projectPath: e.projectPath, isSDK: e.isSDK);
    }

    final generate = pubspec.flutter?['generate'] == true;
    projectNotifier.generateFlag(generate);
  }

  /// Internal - async method to define the localization configuration.
  ///
  /// - Set the project load stage to [LoadStage.definingConfiguration].
  /// - Read the l10n.yaml file if it exists.
  /// - Define the configuration from this file and the default values for Flutter localization.
  Future<void> _defineConfiguration(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.definingConfiguration);
    await Future.delayed(asyncDelay);

    final project = ref.read(projectProvider);
    final configuration = await readL10nConfiguration(project);
    projectNotifier.configuration(configuration);
  }

  /// Internal - async method to read the template file.
  ///
  /// The template file is the localization file for the main locale, as defined in the configuration.
  ///
  /// From this file it is read all global options, [ArbDefinition]s and the translations for this
  /// main locale.
  ///
  /// - Set the project load stage to [LoadStage.readingDefinitions].
  /// - Read the main locale localization file (as defined in the configuration).
  /// - Parse this file as Map with String keys and dynamic values.
  /// - Extract globals, definitions and translations from this file.
  /// - Validate these values in light of ARB rules.
  /// - Defines the locale from this main file (either from the content or from the name).
  /// - Define the [ArbTemplate] object in the [Project].
  /// - Define the first [ArbLocaleTranslations] object in the [Project].
  Future<void> _readTemplateFile(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.readingDefinitions);
    await Future.delayed(asyncDelay);

    final project = ref.read(projectProvider);
    final config = project.configuration;
    late final Map<String, dynamic> arb;
    try {
      arb = await readArbTemplateMap(project);
    } on L10nMissingArbFolderError catch (e) {
      _throwMissingArbFolder(e.dir, config);
    } on L10nMissingArbTemplateError catch (e) {
      _throwMissingTemplateFile(e.file, config);
    }

    final globals = <String, String>{};
    final definitions = <String, dynamic>{};
    final translations = <String, String>{};
    parseArbGlobalsDefinitionsAndTranslationsFromTemplateMap(
      arb,
      globals: globals,
      definitions: definitions,
      translations: translations,
    );

    arbValidation(
      configuration: config,
      translations: translations,
      definitions: definitions,
    );

    final locale = arbLocaleFromMap(config.effectiveTemplateArbFile, arb);
    final template = arbTemplateFromMap(
      globals: globals,
      meta: definitions,
      translations: translations,
    );
    final definitionsMap = <String, ArbDefinition>{};
    for (final definition in template.definitions) {
      definitionsMap[definition.key] = definition;
    }
    projectNotifier.template(template);
    projectNotifier.localeTranslations(arbLocaleTranslations(definitionsMap, locale, translations));
  }

  /// Internal - async method to read all remaining translation files.
  ///
  /// - Set the project load stage to [LoadStage.readingTranslations].
  /// - Read all locale translations, one for each translation file found in the ArbDirectory.
  /// - Store all [ArbLocaleTranslations] objects in the [Project].
  Future<void> _readTranslationFiles(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.readingTranslations);
    await Future.delayed(asyncDelay);

    final project = ref.read(projectProvider);
    late final List<ArbLocaleTranslations> allLocalesTranslations;
    try {
      allLocalesTranslations = await readArbTranslations(project);
    } on L10nMissingArbFolderError catch (e) {
      _throwMissingArbFolder(e.dir, project.configuration);
    }
    for (final localeTranslations in allLocalesTranslations) {
      projectNotifier.localeTranslations(localeTranslations);
    }
  }

  /// Save the current loading project to the list of [RecentProject]s.
  ///
  /// This list is saved to the repository store to be retrieved in a next application execution.
  ///
  /// - Set the project load stage to [LoadStage.savingToRecentProjects].
  /// - Set the current project as the first project in the recent list through
  ///   [RecentProjectsUsecase] that will also store the new list to storage.
  Future<void> _saveToRecentProjects(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.savingToRecentProjects);
    await Future.delayed(asyncDelay);

    final project = ref.read(projectProvider);
    final recentProject = RecentProject(name: project.name, path: project.path);
    recentProjectsUsecase.setFirst(recentProject);
  }

  /// Notifies the project is fully loaded.
  ///
  /// - Set the project load stage to [LoadStage.loaded].
  Future<void> _setLoaded(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.loaded);
    await Future.delayed(asyncDelay);

    ref.read(arbUsecaseProvider).initProjectAnalysis();
  }

  /// Save a user changed [L10nConfiguration].
  ///
  /// It is expected that the project will be reloaded after this configuration is saved to disk,
  /// and that the user interface will display the new loading process.
  ///
  /// - Generates a YAML content from this configuration.
  /// - Write to l10n.yaml file.
  Future<void> saveConfiguration(L10nConfiguration conf) async {
    final project = ref.read(projectProvider);
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

  /// Internal - thow the fixable exception [L10nMissingDependencyException].
  ///
  /// The fix action is defined in [_addDependency].
  void _throwMissingDependency(String depName, {required String projectPath, bool isSDK = false}) {
    throw L10nMissingDependencyException(
      depName,
      fixActionLabel: 'Add Dependency',
      fixActionDescription: 'Add "$depName" dependecy.',
      fixActionInfo: 'Add required dependency to pubspec.yaml and reload this project.',
      fixActionCallback: () => _addDependency(depName, projectPath: projectPath, isSDK: isSDK),
    );
  }

  /// Internal - thow the fixable exception [L10nMissingArbFolderException].
  ///
  /// The fix action is defined in [_createFolder].
  void _throwMissingArbFolder(Directory dir, L10nConfiguration configuration) {
    final folderName = configuration.effectiveArbDir;
    throw L10nMissingArbFolderException(
      folderName,
      fixActionLabel: 'Create Folder',
      fixActionDescription: 'Create ARB folder.',
      fixActionInfo: 'Create missing folder in this project structure.',
      fixActionCallback: () => _createFolder(dir, folderName),
    );
  }

  /// Internal - thow the fixable exception [L10nMissingArbTemplateFileException].
  ///
  /// The fix action is defined in [_createTemplateFile].
  void _throwMissingTemplateFile(File file, L10nConfiguration configuration) {
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

  /// Fix action for [L10nMissingDependencyException].
  ///
  /// See [_throwMissingDependency] above.
  Future<void> _addDependency(String depName, {required String projectPath, bool isSDK = false}) {
    try {
      return addPubspecDependency(depName, projectPath: projectPath, isSDK: isSDK);
    } on L10nException catch (e) {
      _projectNotifier().l10nException(e);
      rethrow;
    }
  }

  /// Fix action for [L10nMissingArbFolderException].
  ///
  /// See [_throwMissingArbFolder] above.
  Future<void> _createFolder(Directory dir, String folderName) async {
    try {
      await dir.create(recursive: true);
    } catch (e) {
      final exception = L10nCreateFolderError(folderName);
      _projectNotifier().l10nException(exception);
      throw exception;
    }
  }

  /// Fix action for [L10nMissingArbTemplateFileException].
  ///
  /// See [_throwMissingTemplateFile] above.
  Future<void> _createTemplateFile(File file, String fileName) async {
    late final String locale;
    try {
      locale = matchArbLocaleFromFileName(fileName);
    } on L10nFileMissingLocaleException {
      final exception = L10nCreateTemplateFileWithoutLocaleSufixError(fileName);
      _projectNotifier().l10nException(exception);
      throw exception;
    }
    try {
      await file.create(recursive: true);
      await file.writeAsString('{\n  "@@locale": "$locale"\n}\n');
    } catch (e) {
      final exception = L10nCreateTemplateFileError(fileName);
      _projectNotifier().l10nException(exception);
      throw exception;
    }
  }

  /// Internal - project notifier that updates the current project and notifies changes.
  ///
  /// This [ProjectNotifier] is part of this usecase [ProjectScope].
  ProjectNotifier _projectNotifier() {
    final scope = ref.read(_projectScopeProvider);
    return ref.read(scope.projectProvider.notifier);
  }
}

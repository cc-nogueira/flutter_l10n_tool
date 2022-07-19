import 'dart:io';

import 'package:riverpod/riverpod.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../../entity/arb/arb_locale_translations.dart';
import '../../entity/project/l10n_configuration.dart';
import '../../entity/project/load_stage.dart';
import '../../entity/project/project.dart';
import '../../entity/project/recent_project.dart';
import '../../exception/l10n_exception.dart';
import '../../exception/l10n_fix_exception.dart';
import '../../exception/l10n_pubspec_exception.dart';
import '../../provider/providers.dart';
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
/// [ProjectScope] contains all
///
class ProjectUsecase
    with PubspecMixin, L10nConfigurationMixin, ArbMixin, ArbTemplateMixin, ArbValidationMixin {
  const ProjectUsecase({required this.read, required this.recentProjectsUsecase});

  static const asyncDelay = Duration(milliseconds: 100);

  final Reader read;
  final RecentProjectsUsecase recentProjectsUsecase;

  void initScope() {
    read(_projectScopeProvider.notifier).state = ProjectScope();
    read(arbUsecaseProvider).initScope();
  }

  /// Creates a new [ProjectScope] for runtime execution.
  void closeProject() {
    initScope();
  }

  /// Stops loading, leaving the project loading state as canceled.
  void cancelLoading() {
    _projectNotifier().loadStage(LoadStage.canceled);
  }

  /// Loading of the whole project.
  ///
  /// The loading process is initializes a new [ProjectScope] for execution and
  /// goes through several async steps to load a project.
  ///
  /// The project and the project scope will then be edited (managed) by the user.
  Future<void> loadProject({required String projectPath}) async {
    initScope();
    final projectNotifier = _projectNotifier();
    try {
      await _initProject(projectNotifier, projectPath: projectPath);
      if (read(projectProvider).loadStage.isFinal) return;
      await _loadPubspec(projectNotifier);

      if (read(projectProvider).loadStage.isFinal) return;
      await _defineConfiguration(projectNotifier);

      if (read(projectProvider).loadStage.isFinal) return;
      await _readTemplateFile(projectNotifier);

      if (read(projectProvider).loadStage.isFinal) return;
      await _readTranslationFiles(projectNotifier);

      if (read(projectProvider).loadStage.isFinal) return;
      await _saveToRecentProjects(projectNotifier);

      if (read(projectProvider).loadStage.isFinal) return;
      await _setLoaded(projectNotifier);
    } on L10nException catch (e) {
      projectNotifier.l10nException(e);
    } catch (e) {
      projectNotifier.l10nException(L10nGenericError(e));
    }
  }

  Future<void> _initProject(ProjectNotifier projectNotifier, {required String projectPath}) async {
    projectNotifier.loadStage(LoadStage.initial);
    await Future.delayed(asyncDelay);

    read(arbUsecaseProvider).clearSelection();
    projectNotifier.init(projectPath);
  }

  Future<void> _loadPubspec(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.readingPubspec);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    final pubspec = await readPubspec(project);
    projectNotifier.name(pubspec.name);

    try {
      checkPubspecDependency(project, pubspec, 'flutter_localizations', isSdk: true);
      checkPubspecDependency(project, pubspec, 'intl');
    } on L10nMissingDependencyError catch (e) {
      throwMissingDependency(e.depName, projectPath: e.projectPath, isSDK: e.isSDK);
    }

    final generate = pubspec.flutter?['generate'] == true;
    projectNotifier.generateFlag(generate);
  }

  Future<void> _defineConfiguration(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.definingConfiguration);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    final configuration = await readL10nConfiguration(project);
    projectNotifier.configuration(configuration);
  }

  Future<void> _readTemplateFile(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.readingDefinitions);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    final config = project.configuration;
    late final Map<String, dynamic> arb;
    try {
      arb = await readArbTemplateMap(project);
    } on L10nMissingArbFolderError catch (e) {
      throwMissingArbFolder(e.dir, config);
    } on L10nMissingArbTemplateError catch (e) {
      throwMissingTemplateFile(e.file, config);
    }

    final globals = <String, String>{};
    final definitions = <String, dynamic>{};
    final translations = <String, String>{};
    parserArbGlobalsDefinitionsAndTranslationsFromTemplateMap(
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
    projectNotifier.template(template);
    projectNotifier.localeTranslations(arbLocaleTranslations(locale, translations));
  }

  Future<void> _readTranslationFiles(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.readingTranslations);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    late final List<ArbLocaleTranslations> allLocalesTranslations;
    try {
      allLocalesTranslations = await readArbTranslations(project);
    } on L10nMissingArbFolderError catch (e) {
      throwMissingArbFolder(e.dir, project.configuration);
    }
    for (final localeTranslations in allLocalesTranslations) {
      projectNotifier.localeTranslations(localeTranslations);
    }
  }

  Future<void> _saveToRecentProjects(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.savingToRecentProjects);
    await Future.delayed(asyncDelay);

    final project = read(projectProvider);
    final recentProject = RecentProject(name: project.name, path: project.path);
    recentProjectsUsecase.setFirst(recentProject);
  }

  Future<void> _setLoaded(ProjectNotifier projectNotifier) async {
    projectNotifier.loadStage(LoadStage.loaded);
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

  void throwMissingArbFolder(Directory dir, L10nConfiguration configuration) {
    final folderName = configuration.effectiveArbDir;
    throw L10nMissingArbFolderException(
      folderName,
      fixActionLabel: 'Create Folder',
      fixActionDescription: 'Create ARB folder.',
      fixActionInfo: 'Create missing folder in this project structure.',
      fixActionCallback: () => _createFolder(dir, folderName),
    );
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

  Future<void> _addDependency(String depName, {required String projectPath, bool isSDK = false}) {
    try {
      return addPubspecDependency(depName, projectPath: projectPath, isSDK: isSDK);
    } on L10nException catch (e) {
      _projectNotifier().l10nException(e);
      rethrow;
    }
  }

  Future<void> _createFolder(Directory dir, String folderName) async {
    try {
      await dir.create(recursive: true);
    } catch (e) {
      final exception = L10nCreateFolderError(folderName);
      _projectNotifier().l10nException(exception);
      throw exception;
    }
  }

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

  ProjectNotifier _projectNotifier() {
    final scope = read(_projectScopeProvider);
    return read(scope.projectProvider.notifier);
  }
}

part of '../project_usecase.dart';

class ProjectNotifier extends StateNotifier<Project> {
  ProjectNotifier() : super(const Project());

  void _loadStage(LoadStage stage) {
    state = state.copyWith(loadStage: stage);
  }

  void _init(String path) {
    state = Project(path: path, loadStage: LoadStage.initial);
  }

  void _name(String name) {
    state = state.copyWith(name: name, loadStage: LoadStage.readingPubspec);
  }

  void _generateFlag(bool value) {
    state = state.copyWith(generateFlag: value, loadStage: LoadStage.readingPubspec);
  }

  void _configuration(L10nConfiguration configuration) {
    state = state.copyWith(
      configuration: configuration,
      loadStage: LoadStage.definingConfiguration,
    );
  }

  void _template(ArbTemplate template) {
    state = state.copyWith(template: template, loadStage: LoadStage.readingDefinitions);
  }

  void _localeTranslations(ArbLocaleTranslations localeTranslations) {
    final locale = localeTranslations.locale;
    if (state.translations.containsKey(locale)) {
      throw L10nMultipleFilesWithSameLocationException(locale);
    }
    final translations = Map.of(state.translations);
    translations[locale] = localeTranslations;
    state = state.copyWith(translations: translations, loadStage: LoadStage.readingTranslations);
  }

  void _l10nException(L10nException exception) {
    state = state.copyWith(l10nException: exception, loadStage: LoadStage.error);
  }

  void _close() {
    state = const Project();
  }
}

part of '../project_usecase.dart';

class ProjectNotifier extends StateNotifier<Project> {
  ProjectNotifier() : super(const Project());

  void _init(String path) {
    state = Project(path: path);
  }

  void _finishedLoading() {
    state = state.copyWith(loading: false);
  }

  void _close() {
    state = const Project();
  }

  void _name(String name) {
    state = state.copyWith(name: name);
  }

  void _generateFlag(bool value) {
    state = state.copyWith(generateFlag: value);
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
}

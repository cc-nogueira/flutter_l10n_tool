part of '../project_usecase.dart';

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
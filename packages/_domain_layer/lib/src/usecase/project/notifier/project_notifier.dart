import 'package:riverpod/riverpod.dart';

import '../../../entity/arb/arb_locale_translations.dart';
import '../../../entity/arb/arb_template.dart';
import '../../../entity/project/l10n_configuration.dart';
import '../../../entity/project/load_stage.dart';
import '../../../entity/project/project.dart';
import '../../../exception/l10n_exception.dart';

class ProjectNotifier extends StateNotifier<Project> {
  ProjectNotifier() : super(const Project());

  void loadStage(LoadStage stage) {
    state = state.copyWith(loadStage: stage);
  }

  void init(String path) {
    state = Project(path: path, loadStage: LoadStage.initial);
  }

  void name(String name) {
    state = state.copyWith(name: name, loadStage: LoadStage.readingPubspec);
  }

  void generateFlag(bool value) {
    state = state.copyWith(generateFlag: value, loadStage: LoadStage.readingPubspec);
  }

  void configuration(L10nConfiguration configuration) {
    state = state.copyWith(
      configuration: configuration,
      loadStage: LoadStage.definingConfiguration,
    );
  }

  void template(ArbTemplate template) {
    state = state.copyWith(template: template, loadStage: LoadStage.readingDefinitions);
  }

  void localeTranslations(ArbLocaleTranslations localeTranslations) {
    final locale = localeTranslations.locale;
    if (state.translations.containsKey(locale)) {
      throw L10nMultipleFilesWithSameLocationException(locale);
    }
    final translations = Map.of(state.translations);
    translations[locale] = localeTranslations;
    state = state.copyWith(translations: translations, loadStage: LoadStage.readingTranslations);
  }

  void l10nException(L10nException exception) {
    state = state.copyWith(l10nException: exception, loadStage: LoadStage.error);
  }
}

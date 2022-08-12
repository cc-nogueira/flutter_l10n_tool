import 'package:_core_layer/notifiers.dart';
import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_locale_translations.dart';
import '../../entity/arb/arb_translation.dart';
import '../../entity/arb/arb_warning.dart';
import '../../entity/project/project.dart';
import '../project/project_usecase.dart';
import 'arb_usecase.dart';

typedef WarningState = EditionsOneToManyState<ArbDefinition, ArbWarning>;
typedef WarningsNotifier = EditionsOneToManyNotifier<ArbDefinition, ArbWarning>;

class ArbAnalysis {
  ArbAnalysis(this.read);

  final Reader read;
  final knownCasesPerSelectDefinition = <String, Set<String>>{};
  final warningsProvider =
      StateNotifierProvider<WarningsNotifier, WarningState>((_) => WarningsNotifier());

  void init() {
    final project = read(projectProvider);
    _initSelectCases(project);
  }

  void updataTranslationsAnalysis(ArbDefinition definition) {
    final project = read(projectProvider);
    final locales = project.translations.keys;
    final projectTrans = project.translations.values;
    final currentTrans = read(currentTranslationsProvider);
    final translations = _definitionTranslations(definition, projectTrans, currentTrans);
    _updateResourceWarnings(locales, definition, translations);
  }

  void _initSelectCases(Project project) {
    final locales = project.translations.keys;
    final allTranslations = project.translations.values;
    for (final definition in project.template.definitions) {
      final translations = _definitionTranslations(definition, allTranslations);
      _updateResourceWarnings(locales, definition, translations);
    }
  }

  List<ArbTranslation> _definitionTranslations(
    ArbDefinition definition,
    Iterable<ArbLocaleTranslations> allTranslations, [
    EditionsOneToMapState<ArbDefinition, String, ArbTranslation>? allCurrentTranslations,
  ]) {
    final currentTranslations = allCurrentTranslations?[definition];
    final translations = <ArbTranslation>[];
    for (final localeTranslations in allTranslations) {
      final currentLocaleTranslation = currentTranslations?[localeTranslations.locale];
      if (currentLocaleTranslation != null) {
        translations.add(currentLocaleTranslation);
      } else {
        final projTranslation = localeTranslations.translations[definition.key];
        if (projTranslation != null) {
          translations.add(projTranslation);
        }
      }
    }
    return translations;
  }

  void _updateResourceWarnings(
    Iterable<String> locales,
    ArbDefinition definition,
    List<ArbTranslation> translations,
  ) {
    _updateMissingTranslationWarnings(locales, definition, translations);
    if (definition is ArbPlaceholdersDefinition) {
      _updatePlaceholdersDefinitionWarnings(definition, translations);
    }
    if (definition is ArbSelectDefinition) {
      _updateSelectDefinitionCasesAndWarnings(definition, translations);
    }
  }

  void _updateMissingTranslationWarnings(
    Iterable<String> locales,
    ArbDefinition definition,
    List<ArbTranslation> translations,
  ) {
    final missingLocales = Set<String>.from(locales);
    for (final translation in translations) {
      final locale = translation.locale;
      final warn = ArbWarning(locale: locale, type: ArbWarningType.missingTranslation);
      missingLocales.remove(locale);
      _warningsNotifier().remove(definition, warn);
    }
    for (final locale in missingLocales) {
      final warn = ArbWarning(locale: locale, type: ArbWarningType.missingTranslation);
      _warningsNotifier().add(definition, warn);
    }
  }

  void _updatePlaceholdersDefinitionWarnings(
    ArbPlaceholdersDefinition definition,
    List<ArbTranslation> translations,
  ) {
    final definitionPlaceholders = {for (final ph in definition.placeholders) ph.key};
    for (final translation in translations) {
      if (translation is ArbPlaceholdersTranslation) {
        ArbWarning warn = ArbWarning(
          locale: translation.locale,
          type: ArbWarningType.translationUnknownPlaceholderKey,
        );
        final hasUnknown = !definitionPlaceholders.containsAll(translation.placeholderNames);
        if (hasUnknown) {
          _warningsNotifier().add(definition, warn);
        } else {
          _warningsNotifier().remove(definition, warn);
        }

        warn = ArbWarning(
          locale: translation.locale,
          type: ArbWarningType.translationUnusedPlaceholderKey,
        );
        final unused = Set.from(definitionPlaceholders)..removeAll(translation.placeholderNames);
        if (unused.isNotEmpty) {
          _warningsNotifier().add(definition, warn);
        } else {
          _warningsNotifier().remove(definition, warn);
        }
      }
    }
  }

  void _updateSelectDefinitionCasesAndWarnings(
    ArbSelectDefinition definition,
    List<ArbTranslation> translations,
  ) {
    final cases = <String>{};
    for (final translation in translations) {
      if (translation is ArbSelectTranslation) {
        for (final select in translation.options) {
          cases.add(select.option);
        }
      }
    }
    knownCasesPerSelectDefinition[definition.key] = cases;
    for (final translation in translations) {
      if (translation is ArbSelectTranslation) {
        final warn = ArbWarning(
          locale: translation.locale,
          type: ArbWarningType.translationMissingSelectCases,
        );
        if (translation.options.length < cases.length) {
          _warningsNotifier().add(definition, warn);
        } else {
          _warningsNotifier().remove(definition, warn);
        }
      }
    }
  }

  WarningsNotifier _warningsNotifier() => read(warningsProvider.notifier);
}

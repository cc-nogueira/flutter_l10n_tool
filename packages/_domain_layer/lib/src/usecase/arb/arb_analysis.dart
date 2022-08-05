import 'package:_core_layer/notifiers.dart';
import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_locale_translations.dart';
import '../../entity/arb/arb_translation.dart';
import '../../entity/project/project.dart';
import '../project/project_usecase.dart';
import 'arb_usecase.dart';

class ArbAnalysis {
  ArbAnalysis(this.read);

  final Reader read;
  final knownCasesPerSelectDefinition = <String, Set<String>>{};

  void init() {
    final project = read(projectProvider);
    _initSelectCases(project);
  }

  void updataTranslationsAnalysis(ArbDefinition definition) {
    if (definition is ArbSelectDefinition) {
      final projectTranslations = read(projectProvider).translations.values;
      final currentTranslations = read(currentTranslationsProvider);
      final translations =
          _definitionTranslations(definition, projectTranslations, currentTranslations);
      _updateSelectDefinitionCases(definition, translations);
    }
  }

  void _initSelectCases(Project project) {
    final allTranslations = project.translations.values;
    for (final definition in project.template.definitions) {
      if (definition is ArbSelectDefinition) {
        final translations = _definitionTranslations(definition, allTranslations);
        _updateSelectDefinitionCases(definition, translations);
      }
    }
  }

  void _updateSelectDefinitionCases(
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
}

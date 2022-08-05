import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_locale_translations.dart';
import '../../entity/arb/arb_translation.dart';
import '../../entity/project/project.dart';
import '../project/project_usecase.dart';

class ArbAnalysis {
  ArbAnalysis(this.read);

  final Reader read;
  final knownCasesPerSelectDefinition = <String, Set<String>>{};

  void init() {
    final project = read(projectProvider);
    _initSelectCases(project);
  }

  void _initSelectCases(Project project) {
    final allTranslations = project.translations.values;
    for (final definition in project.template.definitions) {
      if (definition.type == ArbDefinitionType.select) {
        for (final translation in _definitionTranslations(allTranslations, definition)) {
          if (translation is ArbSelectTranslation) {
            final cases = knownCasesPerSelectDefinition[definition.key] ?? <String>{};
            for (final select in translation.options) {
              cases.add(select.option);
            }
            knownCasesPerSelectDefinition[definition.key] = cases;
          }
        }
      }
    }
  }

  List<ArbTranslation> _definitionTranslations(
    Iterable<ArbLocaleTranslations> allTranslations,
    ArbDefinition definition,
  ) {
    final translations = <ArbTranslation>[];
    for (final localeTranslations in allTranslations) {
      final defTranslation = localeTranslations.translations[definition.key];
      if (defTranslation != null) {
        translations.add(defTranslation);
      }
    }
    return translations;
  }
}

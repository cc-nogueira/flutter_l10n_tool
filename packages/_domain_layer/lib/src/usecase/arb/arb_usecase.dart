import 'package:riverpod/riverpod.dart';

import '../../entity/project/arb_definition.dart';
import '../../entity/project/arb_translation.dart';
import '../../provider/providers.dart';

part 'notifier/definitions_notifier.dart';
part 'notifier/map_notifiers.dart';
part 'notifier/selected_definition_notifier.dart';
part 'notifier/translations_notifier.dart';

class ArbUsecase {
  ArbUsecase(this.read);

  final Reader read;

  void select(ArbDefinition? definition) {
    _selectedDefinitionNotifier()._select(definition);
  }

  void clearSelection() {
    _selectedDefinitionNotifier()._clearSelection();
  }

  void editDefinition({required ArbDefinition original, required ArbDefinition current}) {
    _beingEditedDefinitionsNotifier()._edit(original, current);
  }

  void discardDefinitionChanges({required ArbDefinition original}) {
    _beingEditedDefinitionsNotifier()._discardChanges(original);
  }

  void saveDefinition({required ArbDefinition original, required ArbDefinition value}) {
    _currentDefinitionsNotifier()._edit(original, value);
    discardDefinitionChanges(original: original);
  }

  void rollbackDefinition({required ArbDefinition original}) {
    _currentDefinitionsNotifier()._discardChanges(original);
  }

  void editTranslation({
    required String locale,
    required ArbDefinition definition,
    required ArbTranslation current,
  }) {
    _beingEditedTranslationsForLanguageNotifier(locale)._edit(definition, current);
    _beingEditedTranslationLocalesNotifier()._add(definition, locale);
  }

  void discardTranslationChanges({
    required String locale,
    required ArbDefinition definition,
  }) {
    _beingEditedTranslationsForLanguageNotifier(locale)._discardChanges(definition);
    _beingEditedTranslationLocalesNotifier()._remove(definition, locale);
  }

  void saveTranslation({
    required String locale,
    required ArbDefinition definition,
    required ArbTranslation value,
  }) {
    _currentTranslationsForLanguageNotifier(locale)._edit(definition, value);
    discardTranslationChanges(locale: locale, definition: definition);
  }

  SelectedDefinitionNotifier _selectedDefinitionNotifier() =>
      read(selectedDefinitionProvider.notifier);

  DefinitionsNotifier _beingEditedDefinitionsNotifier() =>
      read(beingEditedDefinitionsProvider.notifier);

  DefinitionsNotifier _currentDefinitionsNotifier() => read(currentDefinitionsProvider.notifier);

  TranslationLocalesNotifier _beingEditedTranslationLocalesNotifier() =>
      read(beingEditedTranslationLocalesProvider.notifier);

  TranslationsForLanguageNotifier _currentTranslationsForLanguageNotifier(String locale) =>
      read(currentTranslationsForLanguageProvider(locale).notifier);

  TranslationsForLanguageNotifier _beingEditedTranslationsForLanguageNotifier(String locale) =>
      read(beingEditedTranslationsForLanguageProvider(locale).notifier);
}

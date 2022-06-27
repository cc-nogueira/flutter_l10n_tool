import 'package:riverpod/riverpod.dart';

import '../entity/project/arb_definition.dart';
import '../entity/project/arb_translation.dart';
import '../provider/providers.dart';

part 'notifier/being_edited_notifiers.dart';
part 'notifier/selected_definition_notifier.dart';

class ArbUsecase {
  ArbUsecase(this.read);

  final Reader read;

  void select(ArbDefinition? definition) {
    _selectedDefinitionNotifier()._select(definition);
  }

  void clearSelection() {
    _selectedDefinitionNotifier()._clearSelection();
  }

  void editDefinition(ArbDefinition definition) {
    _beindEditedDefinitionsNotifier()._edit(definition);
  }

  void discardDefinitionChanges(ArbDefinition definition) {
    _beindEditedDefinitionsNotifier()._discardChanges(definition);
  }

  void changeTranslation(ArbTranslation translation) {}

  void editTranslation(String locale, ArbDefinition definition, ArbTranslation translation) {
    _beingEditedTranslationsForLanguageNotifier(locale)._edit(translation);
    _beingEditedTranslationsNotifier()._add(definition, translation);
  }

  void discardTranslationChanges(
      String locale, ArbDefinition definition, ArbTranslation translation) {
    _beingEditedTranslationsForLanguageNotifier(locale)._discardChanges(translation);
    _beingEditedTranslationsNotifier()._remove(definition, translation);
  }

  SelectedDefinitionNotifier _selectedDefinitionNotifier() =>
      read(selectedDefinitionProvider.notifier);

  BeingEditedTranslationsNotifier _beingEditedTranslationsNotifier() =>
      read(beingEditedTranslationsProvider.notifier);

  BeingEditedDefinitionsNotifier _beindEditedDefinitionsNotifier() =>
      read(beingEditedDefinitionsProvider.notifier);

  BeingEditedTranslationsForLanguageNotifier _beingEditedTranslationsForLanguageNotifier(
          String locale) =>
      read(beingEditedTranslationsForLanguageProvider(locale).notifier);
}

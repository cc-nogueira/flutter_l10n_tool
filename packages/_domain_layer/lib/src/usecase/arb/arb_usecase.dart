import 'package:riverpod/riverpod.dart';

import '../../entity/project/arb_definition.dart';
import '../../entity/project/arb_translation.dart';
import '../../provider/providers.dart';

part 'notifier/being_edited_notifiers.dart';
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
    _beingEditedDefinitionsNotifier()._discardChanges(original);
  }

  void rollbackDefinition({required ArbDefinition original}) {
    _currentDefinitionsNotifier()._discardChanges(original);
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

  DefinitionsNotifier _beingEditedDefinitionsNotifier() =>
      read(beingEditedDefinitionsProvider.notifier);

  DefinitionsNotifier _currentDefinitionsNotifier() => read(currentDefinitionsProvider.notifier);

  BeingEditedTranslationsNotifier _beingEditedTranslationsNotifier() =>
      read(beingEditedTranslationsProvider.notifier);

  BeingEditedTranslationsForLanguageNotifier _beingEditedTranslationsForLanguageNotifier(
          String locale) =>
      read(beingEditedTranslationsForLanguageProvider(locale).notifier);
}

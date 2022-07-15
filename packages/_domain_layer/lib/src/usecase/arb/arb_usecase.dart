import 'dart:collection';

import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_placeholder.dart';
import '../../entity/arb/arb_translation.dart';
import '../../provider/providers.dart';

part 'notifier/definitions_notifier.dart';
part 'notifier/map_notifiers.dart';
part 'notifier/placeholders_notifier.dart';
part 'notifier/selected_definition_notifier.dart';
part 'notifier/translations_notifier.dart';

class ArbUsecase {
  ArbUsecase(this.read);

  final Reader read;

  void select(ArbDefinition? definition) {
    _selectedDefinitionNotifier()._select(definition);
  }

  void toggle(ArbDefinition? definition) {
    _selectedDefinitionNotifier()._toggle(definition);
  }

  void clearSelection() {
    _selectedDefinitionNotifier()._clearSelection();
  }

  void editDefinition({required ArbDefinition original, required ArbDefinition current}) {
    _beingEditedDefinitionsNotifier()._edit(original, current);
  }

  void discardDefinitionChanges({required ArbDefinition original}) {
    _beingEditedDefinitionsNotifier()._discardChanges(original);
    _existingPlaceholdersBeingEditedNotifier()._discardChanges(original);
    _formPlaceholdersNotifier()._discardChanges(original);
  }

  void saveDefinition({required ArbDefinition original, required ArbDefinition value}) {
    if (original == value) {
      _currentDefinitionsNotifier()._discardChanges(original);
    } else {
      _currentDefinitionsNotifier()._edit(original, value);
    }
    discardDefinitionChanges(original: original);
  }

  void rollbackDefinition({required ArbDefinition original}) {
    _currentDefinitionsNotifier()._discardChanges(original);
  }

  /// Track the placeholder being edited.
  ///
  /// This method is called with an actual placeholder when the user starts editing an existing placeholder.
  /// This method is called with a null placeholder value when the user discard placeholder edition and
  /// no placeholders are currently being edited for the corresponding ArbDefinition.
  ///
  /// Note that this method is not invoked when a new placeholder is being edited.
  void trackExistingPlaceholderBeingEdited({
    required ArbDefinition definition,
    required ArbPlaceholder? placeholder,
  }) {
    if (placeholder == null) {
      _existingPlaceholdersBeingEditedNotifier()._discardChanges(definition);
    } else {
      _existingPlaceholdersBeingEditedNotifier()._edit(definition, placeholder);
    }
  }

  /// Update the form placeholder provider to reflect the placeholder being edited by the user.
  ///
  /// This method is invoded with a new generic placeholder when the user starts the creation of a
  /// new placeholder.
  ///
  /// This method is invoked with an existing placeholder when the user starts the edition of an
  /// existing placeholder.
  ///
  /// This method is called for all subsequent changes ih the placeholder being edited (such as
  /// typing on input fields or selecting options in the form).
  ///
  /// This method is invoked with a null value when the user discard changes in the placeholder form.
  void updateFormPlaceholder({
    required ArbDefinition definition,
    required ArbPlaceholder? placeholder,
  }) {
    if (placeholder == null) {
      _formPlaceholdersNotifier()._discardChanges(definition);
    } else {
      _formPlaceholdersNotifier()._edit(definition, placeholder);
    }
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

  /// Return the [existingPlaceholdersBeingEditedProvider] notifier.
  PlaceholdersNotifier _existingPlaceholdersBeingEditedNotifier() =>
      read(existingPlaceholdersBeingEditedProvider.notifier);

  ///Return the [formPlaceholdersProvider] notifier.
  PlaceholdersNotifier _formPlaceholdersNotifier() => read(formPlaceholdersProvider.notifier);

  ///Return the [currentDefinitionsProvider] notifier.
  DefinitionsNotifier _currentDefinitionsNotifier() => read(currentDefinitionsProvider.notifier);

  ///Return the [beingEditedTranslationLocalesProvider] notifier.
  TranslationLocalesNotifier _beingEditedTranslationLocalesNotifier() =>
      read(beingEditedTranslationLocalesProvider.notifier);

  TranslationsForLanguageNotifier _currentTranslationsForLanguageNotifier(String locale) =>
      read(currentTranslationsForLanguageProvider(locale).notifier);

  TranslationsForLanguageNotifier _beingEditedTranslationsForLanguageNotifier(String locale) =>
      read(beingEditedTranslationsForLanguageProvider(locale).notifier);
}

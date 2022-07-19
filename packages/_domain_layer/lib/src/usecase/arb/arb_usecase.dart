import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_placeholder.dart';
import '../../entity/arb/arb_translation.dart';
import 'arb_scope.dart';

part 'arb_providers.dart';

class ArbUsecase {
  ArbUsecase(this.read);

  final Reader read;

  void initScope() {
    read(_arbScopeProvider.notifier).state = ArbScope();
  }

  void select(ArbDefinition? definition) {
    _selectedDefinitionNotifier().select(definition);
  }

  void toggle(ArbDefinition? definition) {
    _selectedDefinitionNotifier().toggle(definition);
  }

  void clearSelection() {
    _selectedDefinitionNotifier().clear();
  }

  void editDefinition({required ArbDefinition original, required ArbDefinition current}) {
    _beingEditedDefinitionsNotifier().edit(original, current);
  }

  void discardDefinitionChanges({required ArbDefinition original}) {
    _beingEditedDefinitionsNotifier().discardChanges(original);
    _existingPlaceholdersBeingEditedNotifier().discardChanges(original);
    _formPlaceholdersNotifier().discardChanges(original);
  }

  void saveDefinition({required ArbDefinition original, required ArbDefinition value}) {
    if (original == value) {
      _currentDefinitionsNotifier().discardChanges(original);
    } else {
      _currentDefinitionsNotifier().edit(original, value);
    }
    discardDefinitionChanges(original: original);
  }

  void rollbackDefinition({required ArbDefinition original}) {
    _currentDefinitionsNotifier().discardChanges(original);
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
      _existingPlaceholdersBeingEditedNotifier().discardChanges(definition);
    } else {
      _existingPlaceholdersBeingEditedNotifier().edit(definition, placeholder);
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
      _formPlaceholdersNotifier().discardChanges(definition);
    } else {
      _formPlaceholdersNotifier().edit(definition, placeholder);
    }
  }

  void editTranslation({
    required String locale,
    required ArbDefinition definition,
    required ArbTranslation current,
  }) {
    _beingEditedTranslationsForLanguageNotifier(locale).edit(definition, current);
    _beingEditedTranslationLocalesNotifier().add(definition, locale);
  }

  void discardTranslationChanges({
    required String locale,
    required ArbDefinition definition,
  }) {
    _beingEditedTranslationsForLanguageNotifier(locale).discardChanges(definition);
    _beingEditedTranslationLocalesNotifier().remove(definition, locale);
  }

  void saveTranslation({
    required String locale,
    required ArbDefinition definition,
    required ArbTranslation value,
  }) {
    _currentTranslationsForLanguageNotifier(locale).edit(definition, value);
    discardTranslationChanges(locale: locale, definition: definition);
  }

  SelectedDefinitionNotifier _selectedDefinitionNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.selectedDefinitionProvider.notifier);
  }

  DefinitionsNotifier _beingEditedDefinitionsNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.beingEditedDefinitionsProvider.notifier);
  }

  /// Return the [existingPlaceholdersBeingEditedProvider] notifier.
  PlaceholdersNotifier _existingPlaceholdersBeingEditedNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.existingPlaceholdersBeingEditedProvider.notifier);
  }

  ///Return the [formPlaceholdersProvider] notifier.
  PlaceholdersNotifier _formPlaceholdersNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.formPlaceholdersProvider.notifier);
  }

  ///Return the [currentDefinitionsProvider] notifier.
  DefinitionsNotifier _currentDefinitionsNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.currentDefinitionsProvider.notifier);
  }

  ///Return the [beingEditedTranslationLocalesProvider] notifier.
  TranslationLocalesNotifier _beingEditedTranslationLocalesNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.beingEditedTranslationLocalesProvider.notifier);
  }

  TranslationsForLanguageNotifier _currentTranslationsForLanguageNotifier(String locale) {
    final scope = read(_arbScopeProvider);
    return read(scope.currentTranslationsForLanguageProvider(locale).notifier);
  }

  TranslationsForLanguageNotifier _beingEditedTranslationsForLanguageNotifier(String locale) {
    final scope = read(_arbScopeProvider);
    return read(scope.beingEditedTranslationsForLanguageProvider(locale).notifier);
  }
}

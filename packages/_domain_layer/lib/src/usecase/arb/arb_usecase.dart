import 'package:_core_layer/notifiers.dart';
import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_placeholder.dart';
import '../../entity/arb/arb_translation.dart';
import '../../entity/project/project.dart';
import '../project/project_usecase.dart';
import 'arb_scope.dart';

part 'arb_providers.dart';

/// Use case for [ArbDefinition] and [ArbTranlations] modified or being edited by the user.
///
/// All changes in localization performed by the user is processed through this use case and stored
/// in the [ArbScope]. This scope is private to the Usecase an only exported state is notified outside
/// through export providers that forward changes to the user interface listeners.
///
/// At any time this scope contains all definitions and translations saved and being edited,
/// allowing the comparisson of current, being edited and original versions (from the load [Project]).
///
/// When saved definitions or translations are discarded the effect is that we will know that only the
/// original (loaded) version exists.
/// It is thus possible to indicate in the user interface what definitions and translations are
/// currently being edited and witch have been modified by the user since the project was loaded.
class ArbUsecase {
  ArbUsecase(this.read);

  final Reader read;

  /// Creates a new [ArbScope] to load a project without any modifications.
  void initScope() {
    read(_arbScopeProvider.notifier).state = ArbScope();
  }

  void initProjectAnalysis() {
    read(analysisProvider).init();
  }

  /// Defines which [ArbDefinition] is currently being selected by the user.
  void select(ArbDefinition? definition) {
    _selectedDefinitionNotifier().select(definition);
  }

  /// Toggle the selection of a [ArbDefinition].
  void toggle(ArbDefinition? definition) {
    _selectedDefinitionNotifier().toggleSelect(definition);
  }

  /// Clear the current [ArbDefinition] selection.
  void clearSelection() {
    _selectedDefinitionNotifier().clearSelection();
  }

  /// Update the value of a [ArbDefinition] being edtited.
  void updateDefinitionBeingEdited({
    required ArbDefinition original,
    required ArbDefinition current,
  }) {
    _beingEditedDefinitionsNotifier().update(original, current);
  }

  /// Discard changes to an [ArbDefinition] that was being edited.
  ///
  /// This will remove this definition from edition tracking.
  /// Will remove any placeholder edition being held for this definition.
  /// Will remove the current edition of any placeholder for this definition.
  void discardDefinitionChanges({required ArbDefinition original}) {
    _beingEditedDefinitionsNotifier().remove(original);
    _existingPlaceholdersBeingEditedNotifier().remove(original);
    _formPlaceholdersNotifier().remove(original);
  }

  /// Makes this [ArbDefinition] the current value.
  ///
  /// Test this [ArbDefinition] agains the original definition (in the loaded [Project]).
  /// If it is equal to the original just remove any saved definition from
  /// [ArbScope.currentDefinitionsProvider].
  /// If it is different from the original then store it in [ArbScope.currentDefinitionsProvider].
  ///
  /// Will also remove this definition from the definitions being edited.
  void saveDefinition({required ArbDefinition original, required ArbDefinition value}) {
    if (original == value) {
      _currentDefinitionsNotifier().remove(original);
    } else {
      _currentDefinitionsNotifier().update(original, value);
    }
    discardDefinitionChanges(original: original);
  }

  /// Rollback a [ArbDefinition] to the original value.
  ///
  /// Just remove any [ArbDefinition] from [ArbScope.currentDefinitionsProvider] and the original
  /// one will become the available definition.
  ///
  /// Also trigger discarDefinitionChanges to clear any edition being made data.
  void rollbackDefinition({required ArbDefinition original}) {
    _currentDefinitionsNotifier().remove(original);
    discardDefinitionChanges(original: original);
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
      _existingPlaceholdersBeingEditedNotifier().remove(definition);
    } else {
      _existingPlaceholdersBeingEditedNotifier().update(definition, placeholder);
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
      _formPlaceholdersNotifier().remove(definition);
    } else {
      _formPlaceholdersNotifier().update(definition, placeholder);
    }
  }

  void editTranslation({
    required String locale,
    required ArbDefinition definition,
    required ArbTranslation current,
  }) {
    _beingEditedTranslationsForLanguageNotifier(locale).update(definition, current);
    _beingEditedTranslationLocalesNotifier().add(definition, locale);
  }

  void discardTranslationChanges({
    required String locale,
    required ArbDefinition definition,
  }) {
    _beingEditedTranslationsForLanguageNotifier(locale).remove(definition);
    _beingEditedTranslationLocalesNotifier().remove(definition, locale);
    _existingPluralsBeingEditedNotifier().remove(definition, locale);
    _formPluralsNotifier().remove(definition, locale);
  }

  void saveTranslation({
    required String locale,
    required ArbDefinition definition,
    required ArbTranslation value,
  }) {
    final translations = read(projectProvider).translations[locale];
    final original = translations?.translations[definition.key];
    if (value == original) {
      _currentTranslationsNotifier().remove(definition, locale);
    } else {
      _currentTranslationsNotifier().add(definition, locale, value);
    }
    discardTranslationChanges(locale: locale, definition: definition);
  }

  void rollbackTranslation({required String locale, required ArbDefinition definition}) {
    _currentTranslationsNotifier().remove(definition, locale);
    discardTranslationChanges(locale: locale, definition: definition);
  }

  /// Track plural being edited.
  ///
  /// This method is called with an actual plural when the user starts editing an existing translation plural.
  /// This method is called with a null String when the user discard plural edition and
  /// no plurals are currently being edited for the corresponding [ArbDefintion]/locale.
  ///
  /// Note that this method is not invoked when a new plural is being edited.
  void trackExistingPluralBeingEdited({
    required ArbDefinition definition,
    required String locale,
    required ArbPlural? plural,
  }) {
    if (plural == null) {
      _existingPluralsBeingEditedNotifier().remove(definition, locale);
    } else {
      _existingPluralsBeingEditedNotifier().add(definition, locale, plural);
    }
  }

  /// Update the form plural provider to reflect the plural being edited by the user.
  ///
  /// This method is invoded with an empty String when the user starts the creation of a
  /// new plural.
  ///
  /// This method is invoked with an existing plural when the user starts the edition of an
  /// existing plural.
  ///
  /// This method is called for all subsequent changes ih the plural being edited (such as
  /// typing on input field).
  ///
  /// This method is invoked with a null value when the user discard changes in the plural form.
  void updateFormPlural({
    required ArbDefinition definition,
    required String locale,
    required ArbPlural? plural,
  }) {
    if (plural == null) {
      _formPluralsNotifier().remove(definition, locale);
    } else {
      _formPluralsNotifier().add(definition, locale, plural);
    }
  }

  /// Track select being edited.
  ///
  /// This method is called with an actual select when the user starts editing an existing translation
  /// select option.
  /// This method is called with a null String when the user discard select edition and
  /// no select options are currently being edited for the corresponding [ArbDefintion]/locale.
  ///
  /// Note that this method is not invoked when a new select option is being edited.
  void trackExistingSelectBeingEdited({
    required ArbDefinition definition,
    required String locale,
    required ArbSelectCase? option,
  }) {
    if (option == null) {
      _existingSelectsBeingEditedNotifier().remove(definition, locale);
    } else {
      _existingSelectsBeingEditedNotifier().add(definition, locale, option);
    }
  }

  /// Update the form select provider to reflect the select being edited by the user.
  ///
  /// This method is invoded with an empty String when the user starts the creation of a
  /// new select option.
  ///
  /// This method is invoked with an existing select when the user starts the edition of an
  /// existing select option.
  ///
  /// This method is called for all subsequent changes ih the select option being edited (such as
  /// typing on input field).
  ///
  /// This method is invoked with a null value when the user discard changes in the select form.
  void updateFormSelect({
    required ArbDefinition definition,
    required String locale,
    required ArbSelectCase? option,
  }) {
    if (option == null) {
      _formSelectsNotifier().remove(definition, locale);
    } else {
      _formSelectsNotifier().add(definition, locale, option);
    }
  }

  SelectedDefinitionNotifier _selectedDefinitionNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.selectedDefinitionProvider.notifier);
  }

  ///Return the [currentDefinitionsProvider] notifier.
  DefinitionEditionsNotifier _currentDefinitionsNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.currentDefinitionsProvider.notifier);
  }

  DefinitionEditionsNotifier _beingEditedDefinitionsNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.beingEditedDefinitionsProvider.notifier);
  }

  /// Return the [existingPlaceholdersBeingEditedProvider] notifier.
  PlaceholderEditionsNotifier _existingPlaceholdersBeingEditedNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.existingPlaceholdersBeingEditedProvider.notifier);
  }

  ///Return the [formPlaceholdersProvider] notifier.
  PlaceholderEditionsNotifier _formPlaceholdersNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.formPlaceholdersProvider.notifier);
  }

  /// Return the [existingPluralsBeingEditedProvider] notifier.
  PluralEditionsNotifier _existingPluralsBeingEditedNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.existingPluralsBeingEditedProvider.notifier);
  }

  ///Return the [formPluralsProvider] notifier.
  PluralEditionsNotifier _formPluralsNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.formPluralsProvider.notifier);
  }

  /// Return the [existingPluralsBeingEditedProvider] notifier.
  SelectEditionsNotifier _existingSelectsBeingEditedNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.existingSelectsBeingEditedProvider.notifier);
  }

  ///Return the [formPluralsProvider] notifier.
  SelectEditionsNotifier _formSelectsNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.formSelectsProvider.notifier);
  }

  TranslationEditionsNotifier _currentTranslationsNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.currentTranslationsProvider.notifier);
  }

  ///Return the [beingEditedTranslationLocalesProvider] notifier.
  TranslationLocalesEditionsNotifier _beingEditedTranslationLocalesNotifier() {
    final scope = read(_arbScopeProvider);
    return read(scope.beingEditedTranslationLocalesProvider.notifier);
  }

  TranslationForLanguageEditionsNotifier _beingEditedTranslationsForLanguageNotifier(
      String locale) {
    final scope = read(_arbScopeProvider);
    return read(scope.beingEditedTranslationsForLocaleProvider(locale).notifier);
  }
}

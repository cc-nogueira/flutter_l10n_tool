import 'package:_core_layer/notifiers.dart';
import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_placeholder.dart';
import '../../entity/arb/arb_translation.dart';

typedef SelectedDefinitionNotifier = SelectionNotifier<ArbDefinition>;
typedef DefinitionsNotifier = MapNotifier<ArbDefinition, ArbDefinition>;
typedef PlaceholdersNotifier = MapNotifier<ArbDefinition, ArbPlaceholder>;
typedef TranslationsForLanguageNotifier = MapNotifier<ArbDefinition, ArbTranslation>;
typedef TranslationLocalesNotifier = MapOneToManyNotifier<ArbDefinition, String>;

/// Arb Scope is a collection of [StateNotificationProvider] internal to [ArbUsecase].
///
/// This scope is recreated when a new project is loaded.
///
/// All these notifiers are available as exported providers (simple providers that export the value
/// of each Notifier).
class ArbScope {
  /// Represents the current selected definition for the user interface.
  ///
  /// This value is changed when the user selects/deselects a resource in the list.
  final selectedDefinitionProvider =
      StateNotifierProvider<SelectedDefinitionNotifier, ArbDefinition?>(
          (_) => SelectedDefinitionNotifier());

  /// Represents the current [ArbDefinition] modified and saved by the user.
  ///
  /// It may differ from the original definition loaded from project files.
  /// It may also differ from the version being edited by the user (not saved).
  final currentDefinitionsProvider =
      StateNotifierProvider<DefinitionsNotifier, Map<ArbDefinition, ArbDefinition>>(
          (_) => DefinitionsNotifier());

  /// Represents a definition being edited by the user.
  ///
  /// This correnponds to the current form values for each definition currently being edited.
  /// The user interface may show one entry of this provider, and all definitions currently being
  /// edited are stored here.
  final beingEditedDefinitionsProvider =
      StateNotifierProvider<DefinitionsNotifier, Map<ArbDefinition, ArbDefinition>>(
          (_) => DefinitionsNotifier());

  /// Represents an existing placeholder currently being edited for a ArbDefinition.
  ///
  /// It will be the initial value of the corresponding value in [formPlaceholdersProvider] for an
  /// edit placeholder action.
  /// When the Form value changes by user interaction these two values may differ, representing
  /// pending changes in the form.
  ///
  /// The value for a ArbDefinition will be null when no placeholder is being edited or when a new
  /// placeholder is being edited in the user's form.
  final existingPlaceholdersBeingEditedProvider =
      StateNotifierProvider<PlaceholdersNotifier, Map<ArbDefinition, ArbPlaceholder>>(
          (_) => PlaceholdersNotifier());

  /// Form placeholders are the current value displayed and edited by the user for
  /// an [ArbDefinition].

  /// There is a max of one [ArbPlaceholder] being edited per [ArbDefinition].
  /// It is one of the markers of an [ArbDefinition] being edited.
  ///
  /// When editing a existing a placeholder this value starts with
  /// [existingPlaceholdersBeingEditedProvider] value.
  /// When creating a placeholder edition this value starts with a new generic placeholder.
  ///
  /// As the user form changes this provider is kept uptodate by the usecase,
  /// pending changes can be detected by comparintg with [existingPlaceholdersBeingEditedProvider] value.
  final formPlaceholdersProvider =
      StateNotifierProvider<PlaceholdersNotifier, Map<ArbDefinition, ArbPlaceholder>>(
          (_) => PlaceholdersNotifier());

  /// Represents the current [ArbTranslation] modified and saved by the user.
  /// This is a family provider to store all current ArbTranslations for each locale.
  ///
  /// It may differ from the original translation loaded from project files.
  /// It may also differ from the version being edited by the user (not saved).
  final currentTranslationsForLanguageProvider = StateNotifierProvider.family<
      TranslationsForLanguageNotifier,
      Map<ArbDefinition, ArbTranslation>,
      String>((_, locale) => TranslationsForLanguageNotifier());

  /// Represents a translation being edited by the user.
  /// This is a family provider to store all ArbTranslations being edited for each locale.
  ///
  /// This correnponds to the current form values for each translation currently being edited.
  /// The user interface may show entries for one locale of this provider, and all translations
  /// currently being edited are stored here.
  final beingEditedTranslationsForLocaleProvider = StateNotifierProvider.family<
      TranslationsForLanguageNotifier,
      Map<ArbDefinition, ArbTranslation>,
      String>((_, locale) => TranslationsForLanguageNotifier());

  /// Represents the list of locales currently being edited for each ArbDefinition.
  ///
  /// It is useful to be able to signal wich definitions are being edited by the user (either by
  /// a ArbDefintion being edited or having a locale translation being edited).
  final beingEditedTranslationLocalesProvider =
      StateNotifierProvider<TranslationLocalesNotifier, Map<ArbDefinition, Set<String>>>(
          (_) => TranslationLocalesNotifier());
}

import 'package:_core_layer/notifiers.dart';
import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_placeholder.dart';
import '../../entity/arb/arb_translation.dart';

typedef SelectedDefinitionNotifier = SelectionNotifier<ArbDefinition>;
typedef DefinitionEditionsNotifier = EditionsNotifier<ArbDefinition, ArbDefinition>;
typedef PlaceholderEditionsNotifier = EditionsNotifier<ArbDefinition, ArbPlaceholder>;
typedef TranslationEditionsNotifier
    = EditionsOneToMapNotifier<ArbDefinition, String, ArbTranslation>;
typedef TranslationForLanguageEditionsNotifier = EditionsNotifier<ArbDefinition, ArbTranslation>;
typedef TranslationLocalesEditionsNotifier = EditionsOneToManyNotifier<ArbDefinition, String>;
typedef PluralEditionsNotifier = EditionsOneToMapNotifier<ArbDefinition, String, ArbPlural>;

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
  final currentDefinitionsProvider = StateNotifierProvider<DefinitionEditionsNotifier,
      EditionsState<ArbDefinition, ArbDefinition>>((_) => DefinitionEditionsNotifier());

  /// Represents a definition being edited by the user.
  ///
  /// This correnponds to the current form values for each definition currently being edited.
  /// The user interface may show one entry of this provider, and all definitions currently being
  /// edited are stored here.
  final beingEditedDefinitionsProvider = StateNotifierProvider<DefinitionEditionsNotifier,
      EditionsState<ArbDefinition, ArbDefinition>>((_) => DefinitionEditionsNotifier());

  /// Represents an existing placeholder currently being edited for a ArbDefinition.
  ///
  /// It will be the initial value of the corresponding value in [formPlaceholdersProvider] for an
  /// edit placeholder action.
  /// When the Form value changes by user interaction these two values may differ, representing
  /// pending changes in the form.
  ///
  /// The value for a ArbDefinition will be null when no placeholder is being edited or when a new
  /// placeholder is being edited in the user's form.
  final existingPlaceholdersBeingEditedProvider = StateNotifierProvider<PlaceholderEditionsNotifier,
      EditionsState<ArbDefinition, ArbPlaceholder>>((_) => PlaceholderEditionsNotifier());

  /// Form placeholders are the current value displayed and edited by the user for
  /// an [ArbDefinition].
  ///
  /// There is a max of one [ArbPlaceholder] being edited per [ArbDefinition].
  ///
  /// When editing a existing a placeholder this value starts with
  /// [existingPlaceholdersBeingEditedProvider] value.
  /// When creating a placeholder edition this value starts with a new generic placeholder.
  ///
  /// As the user form changes this provider is kept uptodate by the usecase,
  /// pending changes can be detected by comparintg with [existingPlaceholdersBeingEditedProvider] value.
  final formPlaceholdersProvider = StateNotifierProvider<PlaceholderEditionsNotifier,
      EditionsState<ArbDefinition, ArbPlaceholder>>((_) => PlaceholderEditionsNotifier());

  /// Represents the current [ArbTranslation]s modified and saved by the user.
  ///
  /// It may differ from the original translation loaded from project files.
  /// It may also differ from the version being edited by the user (not saved).
  final currentTranslationsProvider = StateNotifierProvider<TranslationEditionsNotifier,
          EditionsOneToMapState<ArbDefinition, String, ArbTranslation>>(
      (_) => TranslationEditionsNotifier());

  /// Represents an existing plurals currently being edited for a [ArbDefinition]/locale.
  ///
  /// It will be the initial value of the corresponding value in [formPluralsProvider] for an
  /// edit plural action.
  /// When the Form value changes by user interaction these two values may differ, representing
  /// pending changes in the form.
  ///
  /// No entry will be found for an [ArbDefinition]/locale when no plurals are being edited or when a
  /// new plural is being edited in the user's form.
  final existingPluralsBeingEditedProvider = StateNotifierProvider<PluralEditionsNotifier,
      EditionsOneToMapState<ArbDefinition, String, ArbPlural>>((_) => PluralEditionsNotifier());

  /// Form plurals are the current plural value displayed and edited by the user for
  /// an [ArbDefinition]/locale.
  ///
  /// There is a max of one [ArbPlaceholder] being edited per [ArbDefinition]/locale.
  ///
  /// When editing a existing a plural this value starts with
  /// [existingPluralsBeingEditedProvider] value.
  /// When creating a plural this value starts empty.
  ///
  /// As the user form changes this provider is kept uptodate by the usecase,
  /// pending changes can be detected by comparintg with [existingPluralBeingEditedProvider] value.
  final formPluralsProvider = StateNotifierProvider<PluralEditionsNotifier,
      EditionsOneToMapState<ArbDefinition, String, ArbPlural>>((_) => PluralEditionsNotifier());

  /// Represents a translation being edited by the user.
  /// This is a family provider to store all ArbTranslations being edited for each locale.
  ///
  /// This correnponds to the current form values for each translation currently being edited.
  /// The user interface may show entries for one locale of this provider, and all translations
  /// currently being edited are stored here.
  final beingEditedTranslationsForLocaleProvider = StateNotifierProvider.family<
      TranslationForLanguageEditionsNotifier,
      EditionsState<ArbDefinition, ArbTranslation>,
      String>((_, locale) => TranslationForLanguageEditionsNotifier());

  /// Represents the list of locales currently being edited for each ArbDefinition.
  ///
  /// It is useful to be able to signal wich definitions are being edited by the user (either by
  /// a ArbDefintion being edited or having a locale translation being edited).
  final beingEditedTranslationLocalesProvider = StateNotifierProvider<
      TranslationLocalesEditionsNotifier,
      EditionsOneToManyState<ArbDefinition, String>>((_) => TranslationLocalesEditionsNotifier());
}

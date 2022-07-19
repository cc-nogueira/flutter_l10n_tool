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

/// Project Scope is a collection of [StateNotificationProvider] that are part of [ArbUsecase].
///
/// These scoped providers are all recreated when a new project is loaded.
/// All are available as exported providers - simple Providers that export value of these Notifiers.
class ArbScope {
  final selectedDefinitionProvider =
      StateNotifierProvider<SelectedDefinitionNotifier, ArbDefinition?>(
          (_) => SelectedDefinitionNotifier());

  final currentDefinitionsProvider =
      StateNotifierProvider<DefinitionsNotifier, Map<ArbDefinition, ArbDefinition>>(
          (_) => DefinitionsNotifier());

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

  final currentTranslationsForLanguageProvider = StateNotifierProvider.family<
      TranslationsForLanguageNotifier,
      Map<ArbDefinition, ArbTranslation>,
      String>((_, locale) => TranslationsForLanguageNotifier());

  final beingEditedTranslationLocalesProvider =
      StateNotifierProvider<TranslationLocalesNotifier, Map<ArbDefinition, Set<String>>>(
          (_) => TranslationLocalesNotifier());

  final beingEditedTranslationsForLanguageProvider = StateNotifierProvider.family<
      TranslationsForLanguageNotifier,
      Map<ArbDefinition, ArbTranslation>,
      String>((_, locale) => TranslationsForLanguageNotifier());
}

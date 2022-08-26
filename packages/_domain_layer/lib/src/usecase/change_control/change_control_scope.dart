import 'package:_core_layer/notifiers.dart';
import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import '../../entity/arb/arb_translation.dart';

typedef StagedDefinitionsNotifier = EditionsNotifier<ArbDefinition, ArbDefinition>;
typedef StagedTranslationsNotifier = EditionsOneToManyNotifier<ArbDefinition, ArbTranslation>;
typedef SelectedDefinitionNotifier = SelectionNotifier<ArbDefinition>;

class ChangeControlScope {
  /// Represents the current selected definition for the user interface.
  ///
  /// This value is changed when the user selects/deselects a resource in the list.
  final selectedChangeDefinitionProvider =
      StateNotifierProvider<SelectedDefinitionNotifier, ArbDefinition?>(
          (_) => SelectedDefinitionNotifier());

  final stagedDefinitionsProvider =
      StateNotifierProvider<StagedDefinitionsNotifier, EditionsState<ArbDefinition, ArbDefinition>>(
          (_) => StagedDefinitionsNotifier());

  final stagedTranslationsProvider = StateNotifierProvider<StagedTranslationsNotifier,
      EditionsOneToManyState<ArbDefinition, ArbTranslation>>((_) => StagedTranslationsNotifier());
}

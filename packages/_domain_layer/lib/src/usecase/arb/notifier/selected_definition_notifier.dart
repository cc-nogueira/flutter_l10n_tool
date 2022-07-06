part of '../arb_usecase.dart';

/// Arb usecase selected definition notifier.
///
/// This is a public notifier acessible through the [selectedDefinitionProvider] variable.
///
/// Changes are only possible through the [ArbUsecase] (private methods).
class SelectedDefinitionNotifier extends StateNotifier<ArbDefinition?> {
  /// Constructor that initializes the state to null (no selection).
  SelectedDefinitionNotifier() : super(null);

  /// Private method to change the current definition selection.
  ///
  /// Changing the current selection is only possible through the [ArbUsecase] API.
  void _select(ArbDefinition? definition) => state = definition;

  /// Private method to change the current definition selection.
  ///
  /// It will change to a definition if it is not already selected.
  /// It will deselect it if it is already selected.
  /// Changing the current selection is only possible through the [ArbUsecase] API.
  void _toggle(ArbDefinition? definition) {
    if (state == definition) {
      state = null;
    } else {
      state = definition;
    }
  }

  /// Private method to clear the current definition selection.
  ///
  /// Changing the current selection is only possible through the [ArbUsecase] API.
  void _clearSelection() => state = null;
}

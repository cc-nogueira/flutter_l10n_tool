part of '../resource_usecase.dart';

/// Resource usecase selected resource notifier.
///
/// This is a public notifier acessible through the [selectedResourceProvider] variable.
///
/// Changes are only possible through the [ResourceUsecase] (private methods).
class SelectedResourceNotifier extends StateNotifier<ArbResourceDefinition?> {
  /// Constructor that initializes the state to null (no selection).
  SelectedResourceNotifier() : super(null);

  /// Private method to change the current resource definition selection.
  ///
  /// Changing the current selection is only possible through the [ResourceUsecase] API.
  void _select(ArbResourceDefinition? resourceDifinition) => state = resourceDifinition;

  /// Private method to clear the current resource definition selection.
  ///
  /// Changing the current selection is only possible through the [ResourceUsecase] API.
  void _clearSelection() => state = null;
}

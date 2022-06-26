part of '../resource_usecase.dart';

class SelectedResourceNotifier extends StateNotifier<ArbResourceDefinition?> {
  SelectedResourceNotifier() : super(null);

  void _select(ArbResourceDefinition? resourceDifinition) => state = resourceDifinition;

  void _clearSelection() => state = null;
}

part of 'change_control_usecase.dart';

final changeControlUsecaseProvider =
    Provider<ChangeControlUsecase>((ref) => ChangeControlUsecase(ref));

final _changeControlScopeProvider = StateProvider((ref) => ChangeControlScope());

/// This is a exporting provider to forward [ChangeControlScope] instance internal provider.
/// See [ChangeControlScope.selectedChangeDefinitionProvider].
final selectedChangeDefinitionProvider = Provider((ref) {
  final scope = ref.watch(_changeControlScopeProvider);
  return ref.watch(scope.selectedChangeDefinitionProvider);
});

final stagedDefinitionsProvider = Provider((ref) {
  final scope = ref.watch(_changeControlScopeProvider);
  return ref.watch(scope.stagedDefinitionsProvider);
});

final stagedTranslationsProvider = Provider((ref) {
  final scope = ref.watch(_changeControlScopeProvider);
  return ref.watch(scope.stagedTranslationsProvider);
});

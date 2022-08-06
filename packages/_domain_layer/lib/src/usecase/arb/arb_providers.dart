part of 'arb_usecase.dart';

/// [ArbUsecase] singleton provider.
final arbUsecaseProvider = Provider<ArbUsecase>((ref) => ArbUsecase(ref.read));

/// Internal - provider of the current [ArbScope].
final _arbScopeProvider = StateProvider((ref) => ArbScope());

final analysisProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.analysisProvider);
});

final analysisWarningsProvider = Provider((ref) {
  final analysis = ref.watch(analysisProvider);
  return ref.watch(analysis.warningsProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.selectedDefinitionProvider].
final selectedDefinitionProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.selectedDefinitionProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.currentDefinitionsProvider].
final currentDefinitionsProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.currentDefinitionsProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.beingEditedDefinitionsProvider].
final beingEditedDefinitionsProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.beingEditedDefinitionsProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.existingPlaceholdersBeingEditedProvider].
final existingPlaceholdersBeingEditedProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.existingPlaceholdersBeingEditedProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.formPlaceholdersProvider].
final formPlaceholdersProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.formPlaceholdersProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.existingPluralsBeingEditedProvider].
final existingPluralsBeingEditedProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.existingPluralsBeingEditedProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.formPluralsProvider].
final formPluralsProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.formPluralsProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.existingSelectsBeingEditedProvider].
final existingSelectsBeingEditedProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.existingSelectsBeingEditedProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.formSelectsProvider].
final formSelectsProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.formSelectsProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.currentTranslationsProvider].
final currentTranslationsProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.currentTranslationsProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.beingEditedTranslationLocalesProvider].
final beingEditedTranslationLocalesProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.beingEditedTranslationLocalesProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.beingEditedTranslationsForLocaleProvider].
final beingEditedTranslationsForLocaleProvider =
    Provider.family<EditionsState<ArbDefinition, ArbTranslation>, String>((ref, locale) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.beingEditedTranslationsForLocaleProvider(locale));
});

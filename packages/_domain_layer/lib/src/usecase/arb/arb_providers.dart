part of 'arb_usecase.dart';

/// [ArbUsecase] singleton provider.
final arbUsecaseProvider = Provider<ArbUsecase>((ref) => ArbUsecase(ref.read));

/// Internal - provider of the current [ArbScope].
final _arbScopeProvider = StateProvider((ref) => ArbScope());

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
/// See [ArbScope.currentTranslationsForLanguageProvider].
final currentTranslationsForLanguageProvider =
    Provider.family<Map<ArbDefinition, ArbTranslation>, String>((ref, locale) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.currentTranslationsForLanguageProvider(locale));
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.beingEditedTranslationLocalesProvider].
final beingEditedTranslationLocalesProvider = Provider((ref) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.beingEditedTranslationLocalesProvider);
});

/// This is a exporting provider to forward [ArbScope] instance internal provider.
/// See [ArbScope.beingEditedTranslationsForLocaleProvider].
final beingEditedTranslationsForLanguageProvider =
    Provider.family<Map<ArbDefinition, ArbTranslation>, String>((ref, locale) {
  final scope = ref.watch(_arbScopeProvider);
  return ref.watch(scope.beingEditedTranslationsForLocaleProvider(locale));
});

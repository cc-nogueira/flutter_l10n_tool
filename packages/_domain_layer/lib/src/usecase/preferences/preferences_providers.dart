part of 'preferences_usecase.dart';

/// [PreferencesUsecase] singleton provider.
final preferencesUsecaseProvider =
    Provider<PreferencesUsecase>((ref) => ref.watch(domainLayerProvider).preferencesUsecase);

/// Internal - provider of the current [PreferencesScope].
final _preferencesScopeProvider = StateProvider<PreferencesScope>((_) => PreferencesScope());

/// This is a exporting provider to forward [PreferencesScope] instance internal provider.
/// See [PreferencesScope.displayOptionProvider].
final displayOptionProvider = Provider<DisplayOption>((ref) {
  final scope = ref.read(_preferencesScopeProvider);
  return ref.watch(scope.displayOptionProvider);
});

/// This is a exporting provider to forward [PreferencesScope] instance internal provider.
/// See [PreferencesScope.languageOptionProvider].
final languageOptionProvider = Provider<LanguageOption>((ref) {
  final scope = ref.read(_preferencesScopeProvider);
  return ref.watch(scope.languageOptionProvider);
});

/// This is a exporting provider to forward [PreferencesScope] instance internal provider.
/// See [PreferencesScope.themeModeProvider].
final themeModeProvider = Provider<ThemeMode>((ref) {
  final scope = ref.read(_preferencesScopeProvider);
  return ref.watch(scope.themeModeProvider);
});

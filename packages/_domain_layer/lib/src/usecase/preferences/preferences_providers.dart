part of 'preferences_usecase.dart';

/// PreferencesUsecase singleton provider
final preferencesUsecaseProvider =
    Provider<PreferencesUsecase>((ref) => ref.watch(domainLayerProvider).preferencesUsecase);

final _preferencesScopeProvider = StateProvider<PreferencesScope>((_) => PreferencesScope());

/// DisplayOption provider
final displayOptionProvider = Provider<DisplayOption>((ref) {
  final scope = ref.read(_preferencesScopeProvider);
  return ref.watch(scope.displayOptionProvider);
});

/// LanguageOption preference provider
final languageOptionProvider = Provider<LanguageOption>((ref) {
  final scope = ref.read(_preferencesScopeProvider);
  return ref.watch(scope.languageOptionProvider);
});

/// ThemeMode preference provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final scope = ref.read(_preferencesScopeProvider);
  return ref.watch(scope.themeModeProvider);
});

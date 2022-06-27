part of '../preferences_usecase.dart';

/// Preferences usecase theme mode notifier.
///
/// This is a public notifier acessible through the [themeModeProvider] variable.
///
/// Changes are only possible through the [PreferencesUsecase] (private methods).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  /// Constructor that initializes the state with a usecase private getter.
  ThemeModeNotifier(PreferencesUsecase usecase) : super(usecase._themeMode);

  /// Private setter to change the theme mode.
  ///
  /// Changing the theme mode is only possible through the [PreferencesUsecase] API.
  set _themeMode(ThemeMode themeMode) => state = themeMode;
}

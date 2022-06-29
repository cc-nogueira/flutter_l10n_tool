part of '../preferences_usecase.dart';

/// Preferences usecase display option notifier.
///
/// This is a public notifier acessible through the [displayOptionProvider] variable.
///
/// Changes are only possible through the [PreferencesUsecase] (private methods).
class DisplayOptionNotifier extends StateNotifier<DisplayOption> {
  /// Constructor that initializes the state with a usecase private getter.
  DisplayOptionNotifier(PreferencesUsecase usecase) : super(usecase._displayOption);

  /// Private setter to change the preference.
  ///
  /// Changing this preference is only possible through the [PreferencesUsecase] API.
  set _displayOption(DisplayOption themeMode) => state = themeMode;
}

part of '../preferences_usecase.dart';

/// Preferences usecase language option notifier.
///
/// This is a public notifier acessible through the [languageOptionProvider] variable.
///
/// Changes are only possible through the [PreferencesUsecase] (private methods).
class LanguageOptionNotifier extends StateNotifier<LanguageOption> {
  /// Constructor that initializes the state with a usecase private getter.
  LanguageOptionNotifier(PreferencesUsecase usecase) : super(usecase._languageOption);

  /// Private setter to change the language option.
  ///
  /// Changing the language option is only possible through the [PreferencesUsecase] API.
  set _languageOption(LanguageOption languageOption) => state = languageOption;
}

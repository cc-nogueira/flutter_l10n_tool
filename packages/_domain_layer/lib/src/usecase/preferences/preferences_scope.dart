part of 'preferences_usecase.dart';

typedef DisplayOptionNotifier = OptionNotifier<DisplayOption>;
typedef LanguageOptionNotifier = OptionNotifier<LanguageOption>;
typedef ThemeModeNotifier = OptionNotifier<ThemeMode>;

/// Preferences Scope is a collection of [StateNotifierProvider] internal to [PreferencesUsecase].
///
/// This scope is created on application load time and is updted after user interaction through
/// its use case.
///
/// All these notifiers are available as exported providers (simple providers that export the value
/// of each Notifier).
class PreferencesScope {
  /// Current selected [DisplayOption], either compact or expanded.
  ///
  /// This value is used to define the details and display format current presented to the user.
  ///
  /// The initial value is retrieved from the [PreferencesUsecase] from the repository store or
  /// from the default initial value.
  final displayOptionProvider = StateNotifierProvider<DisplayOptionNotifier, DisplayOption>((ref) {
    final usecase = ref.read(preferencesUsecaseProvider);
    return DisplayOptionNotifier(usecase._storedOrInitialDisplayOption);
  });

  /// Current selected [LanguageOption] with language and optional country.
  ///
  /// This value is used to define the language for user interface.
  ///
  /// The initial value is retrieved from the [PreferencesUsecase] from the repository store or
  /// from the default initial value.
  final languageOptionProvider =
      StateNotifierProvider<LanguageOptionNotifier, LanguageOption>((ref) {
    final usecase = ref.read(preferencesUsecaseProvider);
    return LanguageOptionNotifier(usecase._storedOrInitialLanguageOption);
  });

  /// Current selected [ThemeMode], either Dark or Light.
  ///
  /// This value is used to define the theme mode for the user interface.
  ///
  /// The initial value is retrieved from the [PreferencesUsecase] from the repository store or
  /// from the default initial value.
  final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
    final usecase = ref.read(preferencesUsecaseProvider);
    return ThemeModeNotifier(usecase._storedOrInitialThemeMode);
  });
}

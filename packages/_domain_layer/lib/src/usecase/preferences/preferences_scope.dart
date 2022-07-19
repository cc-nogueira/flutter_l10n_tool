part of 'preferences_usecase.dart';

typedef DisplayOptionNotifier = OptionNotifier<DisplayOption>;
typedef LanguageOptionNotifier = OptionNotifier<LanguageOption>;
typedef ThemeModeNotifier = OptionNotifier<ThemeMode>;

class PreferencesScope {
  /// DisplayOption provider
  final displayOptionProvider = StateNotifierProvider<DisplayOptionNotifier, DisplayOption>((ref) {
    final usecase = ref.read(preferencesUsecaseProvider);
    return DisplayOptionNotifier(usecase._displayOption);
  });

  /// LanguageOption preference provider
  final languageOptionProvider =
      StateNotifierProvider<LanguageOptionNotifier, LanguageOption>((ref) {
    final usecase = ref.read(preferencesUsecaseProvider);
    return LanguageOptionNotifier(usecase._languageOption);
  });

  /// ThemeMode preference provider
  final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
    final usecase = ref.read(preferencesUsecaseProvider);
    return ThemeModeNotifier(usecase._themeMode);
  });
}

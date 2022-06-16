import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../entity/preferences/language_option.dart';
import '../entity/preferences/preference.dart';
import '../provider/providers.dart';
import '../repository/preferences_repository.dart';

/// LanguageOption preference provider
final languageOptionProvider = Provider<LanguageOption>((ref) {
  final usecase = ref.watch(preferencesUsecaseProvider);
  return ref.watch(usecase._languageOptionProvider);
});

/// ThemeMode preference provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final usecase = ref.watch(preferencesUsecaseProvider);
  return ref.watch(usecase._themeProvider);
});

/// PreferencesUsecase manages a well defined domain of preferences.
///
/// All preferences are stored with well known keys defined as static variables.
/// Preferences values are stored as Strings and converted on its getter/setters to/from a variety
/// of classes such as ThemeMode and LanguageOption.
///
/// Preferences keys and initial values are private to the class.
///
/// All setter methods do save the preference to storage and updates the corresponding StateProvider,
/// making it very convenient to rely on providers and stay up to date with preferences state.
/// This strategy works combined with those public read only Providers available above in this file.
///
/// These providers are late initialized retrieving the storage state on first access with default
/// initial values.
///
/// Preferences allowed values are available through this usecase singleton instance API.
class PreferencesUsecase {
  /// Constructor requires the injection of [PreferencesRepository] implementation and a Riverpod
  /// [Reader].
  ///
  /// The repository is used for preferences persistence.
  /// The Reader is used to manipulate local StateProviders that store and notify changes for  all
  /// preferences.
  PreferencesUsecase({required this.read, required this.repository});

  static const _languageOptionKey = 'language';
  static const _themeKey = 'theme';

  static const _initialTheme = ThemeMode.dark;

  /// Internal Riverpod [Reader].
  @internal
  final Reader read;

  /// Internal [PreferencesRepositoty] implementation.
  @internal
  final PreferencesRepository repository;

  /// Available themes.
  final themes = const [ThemeMode.dark, ThemeMode.light];

  // Private prividers:
  late final _languageOptionProvider = StateProvider((_) => _languageOption);
  late final _themeProvider = StateProvider((_) => _theme);

  /// Setter to change the [LanguageOption] preference.
  ///
  /// This setter will trigger this preference change notification through the correpondent provider.
  set languageOption(LanguageOption languageOption) {
    final optionStr = '${languageOption.languageCode}_${languageOption.countryCode ?? ''}';
    repository.saveByKey(Preference(key: _languageOptionKey, value: optionStr));
    read(_languageOptionProvider.notifier).state = languageOption;
  }

  /// Internal getter for [LanguageOption] preference.
  ///
  /// This method reads the preference from the [PreferencesRepository] with a default initialValue.
  /// Use the correspondent public provider instead.
  LanguageOption get _languageOption {
    final pref = repository.getByKey(_languageOptionKey);
    if (pref == null) return LanguageOption.none;
    final split = pref.value.split('_');
    final languageCode = split[0];
    final countryCode = (split.length == 2) ? split[1] : null;
    return LanguageOption.matching(languageCode, countryCode);
  }

  /// Setter to change the [ThemeMode] preference.
  ///
  /// This setter will trigger this preference change notification through the correpondent provider.
  set theme(ThemeMode theme) {
    repository.saveByKey(Preference(key: _themeKey, value: theme.name));
    read(_themeProvider.notifier).state = theme;
  }

  /// Internal getter for [ThemeMode] preference.
  ///
  /// This method reads the preference from the [PreferencesRepository] with a default initialValue.
  /// Use the correspondent public provider instead.
  ThemeMode get _theme {
    final pref = repository.getByKey(_themeKey);
    if (pref?.value == ThemeMode.light.name) return ThemeMode.light;
    if (pref?.value == ThemeMode.dark.name) return ThemeMode.dark;
    return _initialTheme;
  }
}

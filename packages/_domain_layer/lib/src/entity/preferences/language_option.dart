import 'dart:ui';

import 'package:meta/meta.dart';

/// Languages enum.
///
/// Available languages, including a 'none' value.
/// This 'none' value is used for no match lookup and can signal no user selected language and
/// the desire to use the SystemLanguage of the device.
enum Language {
  none,
  en,
  pt;

  /// Find the enum corresponding to a language code or 'none'.
  static Language forLanguageCode(String languageCode) => values.firstWhere(
        (element) => element.name == languageCode,
        orElse: () => none,
      );

  /// Find the enum for a Locale language code or 'none'.
  static Language forLocale(Locale locale) => forLanguageCode(locale.languageCode);

  /// Return the language code for a enum value or empty for the enum 'none'.
  String get languageCode => this == none ? '' : name;
}

///
/// LanguageCountry enum.
///
/// Enumerates known Language Countries, each one with a two letter code, a flag and a list of
/// Language values valid for that country.
///
/// Also includes a 'none' value to signal a no match value for country lookup.
/// This 'none' value carries only the Language.none value in its list of valid languages.
enum LanguageCountry {
  none(null, '', [Language.none]),
  australia('AU', '🇦🇺', [Language.en]),
  canada('CA', '🇨🇦', [Language.en]),
  brazil('BR', '🇧🇷', [Language.pt]),
  india('IN', '🇮🇳', [Language.en]),
  portugal('PT', '🇵🇹', [Language.pt]),
  unitedKingdom('UK', '🇬🇧', [Language.en]),
  unitedStates('US', '🇺🇸', [Language.en]);

  /// Constructor with countryCode, flag and list of languages.
  const LanguageCountry(this.countryCode, this.flag, this.languages);

  /// Find the list of countries that support a given language.
  static List<LanguageCountry> forLanguage(Language language) =>
      values.where((each) => each.languages.contains(language)).toList();

  /// Country code if any.
  final String? countryCode;

  /// Country flag as a UNICODE char.
  /// Note that windows does not render these Flag chars as images, but rather as their corresponding
  /// country code.
  final String flag;

  /// List of languages valid for a country.
  final List<Language> languages;
}

/// LanguageOption entity.
///
/// Represents a language option the user can select for the system.
///
/// This class has a static API to tell the default language option for each language supported in
/// the system, and to find a valid LanguageOption for a combination of languageCode and an optional
/// countryCode.
///
/// It can also construct a list of language options combinining Language and LanguageCountry
/// that best suit the current system locales and the current saved LanguageOption.
///
/// This is also a 'none' value used for no match lookup and can signal no user selected language and
/// the desire to use the SystemLanguage of the device.
@immutable
class LanguageOption {
  /// Private constructor.
  const LanguageOption._(this.language, this.country);

  /// None option to signal the desire to use a system locale language.
  static const none = LanguageOption._(Language.none, LanguageCountry.none);

  /// Internal default options.
  static const _defaultLanguageOptions = [
    none,
    LanguageOption._(Language.en, LanguageCountry.unitedStates),
    LanguageOption._(Language.pt, LanguageCountry.brazil)
  ];

  /// Language value.
  final Language language;

  /// LanguageCountry value (can be 'none').
  final LanguageCountry country;

  /// Default LanguageOption for a language or none.
  static LanguageOption defaultLanguageOptionFor(Language language) =>
      _defaultLanguageOptions.firstWhere(
        (each) => each.language == language,
        orElse: () => none,
      );

  /// Find a matching LanguageOption for a languageCode and an optional countryCode.
  ///
  /// This is probably only used by the Preferences Usecase to load the last used LanguageOption.
  static LanguageOption matching(String languageCode, String? countryCode) {
    final language = Language.forLanguageCode(languageCode);
    if (language == Language.none) {
      return none;
    }
    if (countryCode == null) {
      return defaultLanguageOptionFor(language);
    }

    for (final country in LanguageCountry.forLanguage(language)) {
      if (country.countryCode == countryCode) {
        return LanguageOption._(language, country);
      }
    }

    return defaultLanguageOptionFor(language);
  }

  /// List of available LanguageOptions that best suit the combination of system locales and the
  /// current saved LanguageOption.
  ///
  /// This is list is constructed in the following order:
  /// - first is none.
  /// - second is currentOption.
  /// - then options is systemLocales.
  /// - last default options for each language
  static List<LanguageOption> languageOptions(
      List<Locale> systemLocales, LanguageOption currentOption) {
    final languagesInSystem = <Language>{};
    for (final locale in systemLocales) {
      final language = Language.forLocale(locale);
      if (language != Language.none) {
        languagesInSystem.add(language);
      }
    }

    // first is none
    final list = <LanguageOption>[none];
    final found = <Language>{Language.none};

    // second is currentOption
    if (currentOption != none) {
      list.add(currentOption);
      found.add(currentOption.language);
    }

    // then options is systemLocales
    for (final language in languagesInSystem) {
      if (found.contains(language)) {
        continue;
      }
      final option = _findOptionInSystemLocales(systemLocales, language);
      if (option != null) {
        list.add(option);
        found.add(option.language);
      }
    }

    // last default options for each language
    if (Language.values.length > list.length) {
      for (final language in Language.values) {
        if (found.contains(language)) {
          continue;
        }
        final defaultOption = defaultLanguageOptionFor(language);
        if (defaultOption != none) {
          list.add(defaultOption);
        }
      }
    }
    return list;
  }

  /// Private method to find the best combination of language and country using system locales.
  static LanguageOption? _findOptionInSystemLocales(List<Locale> systemLocales, Language language) {
    final countries = LanguageCountry.forLanguage(language);
    for (final locale in systemLocales) {
      if (locale.languageCode == language.name) {
        final countryCode = locale.countryCode;
        if (countryCode != null) {
          for (final country in countries) {
            if (country.countryCode == countryCode) {
              return LanguageOption._(language, country);
            }
          }
        }
      }
    }
    return null;
  }

  /// Is this a none option?
  bool get isNone => language == Language.none;

  /// Language code value.
  String get languageCode => language.languageCode;

  /// Optional country code value.
  String? get countryCode => country.countryCode;

  /// Corresponding Locale or null for the 'none' LanguageOption.
  Locale? get locale => isNone ? null : Locale(languageCode, countryCode);

  @override
  bool operator ==(Object other) =>
      other is LanguageOption && other.language == language && other.country == country;

  @override
  int get hashCode => language.hashCode & country.hashCode;
}

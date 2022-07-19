import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_translation.dart';

part 'arb_locale_translations.freezed.dart';

/// Entity with an [ArbDefinition] keys to [ArbTranslation] map for a locale.
@freezed
class ArbLocaleTranslations with _$ArbLocaleTranslations {
  /// Constructor receiving all translations for a locale.
  const factory ArbLocaleTranslations({
    required String locale,
    required Map<String, ArbTranslation> translations,
  }) = _ArbLocaleTranslations;
}

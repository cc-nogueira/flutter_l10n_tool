import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_translation.dart';

part 'arb_locale_translations.freezed.dart';

@freezed
class ArbLocaleTranslations with _$ArbLocaleTranslations {
  const factory ArbLocaleTranslations({
    required String locale,
    required Map<String, ArbTranslation> translations,
  }) = _ArbLocaleTranslations;
}

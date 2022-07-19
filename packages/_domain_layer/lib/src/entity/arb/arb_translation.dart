import 'package:freezed_annotation/freezed_annotation.dart';

part 'arb_translation.freezed.dart';

/// Entity for an ARB translation.
///
/// Maps a ARB key to its translation.
/// This object will be stored in a [ArbLocaleTranslations] entity.
@freezed
class ArbTranslation with _$ArbTranslation {
  const factory ArbTranslation({
    required String key,
    required String value,
  }) = _ArbTranslation;
}

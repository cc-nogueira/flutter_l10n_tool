import 'package:freezed_annotation/freezed_annotation.dart';

part 'arb_translation.freezed.dart';

@freezed
class ArbTranslation with _$ArbTranslation {
  const factory ArbTranslation({
    required String key,
    required String value,
  }) = _ArbTranslation;
}

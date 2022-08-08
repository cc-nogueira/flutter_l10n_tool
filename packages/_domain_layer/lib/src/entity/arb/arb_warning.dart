import 'package:freezed_annotation/freezed_annotation.dart';

part 'arb_warning.freezed.dart';

@freezed
class ArbWarning with _$ArbWarning {
  const factory ArbWarning({
    required ArbWarningType type,
    required String locale,
  }) = _ArbWarning;
}

enum ArbWarningType {
  missingTranslation,
  translationMissingSelectCases,
}

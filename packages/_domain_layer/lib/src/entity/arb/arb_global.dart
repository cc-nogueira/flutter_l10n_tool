import 'package:freezed_annotation/freezed_annotation.dart';

part 'arb_global.freezed.dart';

@freezed
class ArbGlobal with _$ArbGlobal {
  const factory ArbGlobal({
    required String key,
    required String value,
  }) = _ArbGlobal;
}

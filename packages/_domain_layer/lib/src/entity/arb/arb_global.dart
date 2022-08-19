import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_key_mixin.dart';

part 'arb_global.freezed.dart';

@freezed
class ArbGlobal with _$ArbGlobal {
  @With<ArbKeyMixin>()
  const factory ArbGlobal({
    required String key,
    required String value,
  }) = _ArbGlobal;
}

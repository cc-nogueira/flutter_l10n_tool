import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_placeholder.dart';

part 'arb_resource.freezed.dart';

@freezed
class ArbResource with _$ArbResource {
  const factory ArbResource({
    required String key,
    required String value,
  }) = _ArbResource;
}

@freezed
class ArbResourceDefinition with _$ArbResourceDefinition {
  const factory ArbResourceDefinition({
    required String key,
    String? context,
    String? description,
    List<ArbPlaceholderBase>? placeholders,
  }) = _ArbResourceDefinition;
}

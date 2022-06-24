import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_placeholder.dart';

part 'arb_resource.freezed.dart';

enum ArbResourceType {
  plural,
  text,
  select;

  bool get isPlural => this == plural;
  bool get isSelect => this == select;
  bool get isText => this == text;
}

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
    required ArbResourceType type,
    required String key,
    String? context,
    String? description,
    List<ArbPlaceholderBase>? placeholders,
  }) = _ArbResourceDefinition;

  static final pluralResourceRegExp = RegExp(r'{\s*(\w+)\s*,\s*plural\s*,.*}');
  static final selectResourceRegExp = RegExp(r'{\s*(\w+)\s*,\s*select\s*,.*}');
  static ArbResourceType typeForValue(String key) {
    if (pluralResourceRegExp.hasMatch(key)) {
      return ArbResourceType.plural;
    }
    if (selectResourceRegExp.hasMatch(key)) {
      return ArbResourceType.select;
    }
    return ArbResourceType.text;
  }
}

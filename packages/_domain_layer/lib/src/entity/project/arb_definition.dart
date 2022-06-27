import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_placeholder.dart';

part 'arb_definition.freezed.dart';

enum ArbDefinitionType {
  plural,
  text,
  select;

  bool get isPlural => this == plural;
  bool get isSelect => this == select;
  bool get isText => this == text;
}

@freezed
class ArbDefinition with _$ArbDefinition {
  const factory ArbDefinition({
    required ArbDefinitionType type,
    required String key,
    String? context,
    String? description,
    List<ArbPlaceholderBase>? placeholders,
  }) = _ArbDefinition;

  static final pluralRegExp = RegExp(r'{\s*(\w+)\s*,\s*plural\s*,.*}');
  static final selectRegExp = RegExp(r'{\s*(\w+)\s*,\s*select\s*,.*}');

  static ArbDefinitionType typeForValue(String key) {
    if (pluralRegExp.hasMatch(key)) {
      return ArbDefinitionType.plural;
    }
    if (selectRegExp.hasMatch(key)) {
      return ArbDefinitionType.select;
    }
    return ArbDefinitionType.text;
  }
}

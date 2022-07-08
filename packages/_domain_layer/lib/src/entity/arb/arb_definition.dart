import 'package:freezed_annotation/freezed_annotation.dart';

import '../../util/arb_util.dart';
import 'arb_placeholder.dart';

part 'arb_definition.freezed.dart';

abstract class ArbDefinition {
  factory ArbDefinition({
    required String key,
    required String value,
    String? context,
    String? description,
    List<ArbPlaceholder>? placeholders,
  }) {
    final type = ArbUtil.typeForValue(value);
    switch (type) {
      case ArbDefinitionType.plural:
        return ArbPluralDefinition(
            key: key,
            value: value,
            context: context,
            description: description,
            placeholders: placeholders);
      case ArbDefinitionType.select:
        return ArbSelectDefinition(
            key: key,
            value: value,
            context: context,
            description: description,
            placeholders: placeholders);
      default:
        return ArbTextDefinition(
            key: key,
            value: value,
            context: context,
            description: description,
            placeholders: placeholders);
    }
  }

  ArbDefinitionType get type;
  String get key;
  String get value;
  String? get context;
  String? get description;
  List<ArbPlaceholder>? get placeholders;
}

@freezed
class ArbTextDefinition with _$ArbTextDefinition implements ArbDefinition {
  const factory ArbTextDefinition({
    required String key,
    required String value,
    String? context,
    String? description,
    List<ArbPlaceholder>? placeholders,
  }) = _ArbTextDefinition;

  const ArbTextDefinition._();

  @override
  ArbDefinitionType get type => ArbDefinitionType.text;
}

@freezed
class ArbPluralDefinition with _$ArbPluralDefinition implements ArbDefinition {
  const factory ArbPluralDefinition({
    required String key,
    required String value,
    String? context,
    String? description,
    List<ArbPlaceholder>? placeholders,
  }) = _ArbPluralDefinition;

  const ArbPluralDefinition._();

  @override
  ArbDefinitionType get type => ArbDefinitionType.plural;

  String mainPlaceholder() => ArbUtil.mainPlaceholder(type, value);
}

@freezed
class ArbSelectDefinition with _$ArbSelectDefinition implements ArbDefinition {
  const factory ArbSelectDefinition({
    required String key,
    required String value,
    String? context,
    String? description,
    List<ArbPlaceholder>? placeholders,
  }) = _ArbSelectDefinition;

  const ArbSelectDefinition._();

  @override
  ArbDefinitionType get type => ArbDefinitionType.select;

  String mainPlaceholder() => ArbUtil.mainPlaceholder(type, value);
}

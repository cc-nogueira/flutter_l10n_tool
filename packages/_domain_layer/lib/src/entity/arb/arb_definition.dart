import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_placeholder.dart';

part 'arb_definition.freezed.dart';

@freezed
class ArbDefinition with _$ArbDefinition {
  factory ArbDefinition.placeholders({
    @Default('') String key,
    String? context,
    String? description,
    @Default([]) List<ArbPlaceholder> placeholders,
  }) = ArbPlaceholdersDefinition;

  factory ArbDefinition.plural({
    @Default('') String key,
    String? context,
    String? description,
    @Default('') String placeholder,
  }) = ArbPluralDefinition;

  factory ArbDefinition.select({
    @Default('') String key,
    String? context,
    String? description,
    @Default('') String placeholder,
  }) = ArbSelectDefinition;
}

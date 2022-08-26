import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_key_mixin.dart';
import 'arb_placeholder.dart';

part 'arb_definition.freezed.dart';

enum ArbDefinitionType {
  placeholders,
  plural,
  select;

  bool get isPlaceholder => this == placeholders;
  bool get isNotPlaceholder => !isPlaceholder;
  bool get isPlural => this == plural;
  bool get isNotPlural => !isPlural;
  bool get isSelect => this == select;
  bool get isNotSelect => !isSelect;
}

mixin ArbDefinitionWithParameter on ArbDefinition {
  String get parameterName;
}

/// An union of three possible ArbDefinitions as defined in the ICU spec.
///
/// - ArbPlaceholderDefinition
/// - ArbPluralDefinition
/// - ArbSelectDefinition
@freezed
class ArbDefinition with _$ArbDefinition, ArbKeyMixin {
  const ArbDefinition._();

  /// ArbPlaceholdersDefinition factory.
  ///
  /// It contains the common key, context and description.
  /// And it may contain a list of [ArbPlaceholder].
  const factory ArbDefinition.placeholders({
    @Default('') String key,
    String? context,
    String? description,
    @Default([]) List<ArbPlaceholder> placeholders,
  }) = ArbPlaceholdersDefinition;

  /// ArbPluralDefinition factory.
  ///
  /// It contains the common key, context and description.
  /// It also contains the name of the placeholder for the plural variable.
  @With<ArbDefinitionWithParameter>()
  const factory ArbDefinition.plural({
    @Default('') String key,
    String? context,
    String? description,
    @Default('') String parameterName,
  }) = ArbPluralDefinition;

  /// ArbSelectDefinition factory.
  ///
  /// It contains the common key, context and description.  ///
  /// It also contains the name of the placeholder for the select variable.
  @With<ArbDefinitionWithParameter>()
  const factory ArbDefinition.select({
    @Default('') String key,
    String? context,
    String? description,
    @Default('') String parameterName,
  }) = ArbSelectDefinition;

  ArbDefinitionType get type => map(
        placeholders: (_) => ArbDefinitionType.placeholders,
        plural: (_) => ArbDefinitionType.plural,
        select: (_) => ArbDefinitionType.select,
      );
}

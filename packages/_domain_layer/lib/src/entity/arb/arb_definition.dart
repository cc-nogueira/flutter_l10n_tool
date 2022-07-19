import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_key_mixin.dart';
import 'arb_placeholder.dart';

part 'arb_definition.freezed.dart';

/// An union of three possible ArbDefinitions as defined in the ICU spec.
///
/// - ArbPlaceholderDefinition
/// - ArbPluralDefinition
/// - ArbSelectDefinition
@freezed
class ArbDefinition with _$ArbDefinition {
  /// ArbPlaceholdersDefinition factory with [ArbKeyMixin].
  ///
  /// It contains the common key, context and description.
  /// And it may contain a list of [ArbPlaceholder].
  @With<ArbKeyMixin>()
  factory ArbDefinition.placeholders({
    @Default('') String key,
    String? context,
    String? description,
    @Default([]) List<ArbPlaceholder> placeholders,
  }) = ArbPlaceholdersDefinition;

  /// ArbPluralDefinition factory with [ArbKeyMixin].
  ///
  /// It contains the common key, context and description.
  /// It also contains the name of the placeholder for the plural variable.
  @With<ArbKeyMixin>()
  factory ArbDefinition.plural({
    @Default('') String key,
    String? context,
    String? description,
    @Default('') String placeholder,
  }) = ArbPluralDefinition;

  /// ArbSelectDefinition factory with [ArbKeyMixin].
  ///
  /// It contains the common key, context and description.  ///
  /// It also contains the name of the placeholder for the select variable.
  @With<ArbKeyMixin>()
  factory ArbDefinition.select({
    @Default('') String key,
    String? context,
    String? description,
    @Default('') String placeholder,
  }) = ArbSelectDefinition;
}

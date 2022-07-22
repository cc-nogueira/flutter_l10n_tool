import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_definition.dart';

part 'arb_translation.freezed.dart';

mixin ArbTranslationWithParameter {
  ArbDefinitionType get type;
  String get expression;
  String get parameterName;
  Map<String, String> get options;
  String get prefix;
  String get suffix;
}

/// Entity for an ARB translation.
///
/// Maps a ARB key to its translation.
/// This object will be stored in a [ArbLocaleTranslations] entity.
@freezed
class ArbTranslation with _$ArbTranslation {
  const ArbTranslation._();

  const factory ArbTranslation.placeholders({
    required String key,
    @Default('') String value,
    @Default([]) List<String> placeholderNames,
  }) = ArbPlaceholdersTranslation;

  @With<ArbTranslationWithParameter>()
  const factory ArbTranslation.plural({
    required String key,
    @Default('') String value,
    @Default('') String expression,
    @Default('') String parameterName,
    @Default({}) Map<String, String> options,
    @Default('') String prefix,
    @Default('') String suffix,
  }) = ArbPluralTranslation;

  @With<ArbTranslationWithParameter>()
  const factory ArbTranslation.select({
    required String key,
    @Default('') String value,
    @Default('') String expression,
    @Default('') String parameterName,
    @Default({}) Map<String, String> options,
    @Default('') String prefix,
    @Default('') String suffix,
  }) = ArbSelectTranslation;

  ArbDefinitionType get type => map(
        placeholders: (_) => ArbDefinitionType.placeholders,
        plural: (_) => ArbDefinitionType.plural,
        select: (_) => ArbDefinitionType.select,
      );
}

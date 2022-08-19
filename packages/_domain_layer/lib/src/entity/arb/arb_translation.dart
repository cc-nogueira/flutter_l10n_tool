import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_definition.dart';
import 'arb_key_mixin.dart';

part 'arb_translation.freezed.dart';

mixin ArbTranslationWithParameter<T> on ArbTranslation {
  String get prefix;
  String get expression;
  String get suffix;
  String get parameterName;
  List<T> get options;

  String get value => '$prefix$expression$suffix';
}

/// Entity for an ARB translation.
///
/// Maps a ARB key to its translation.
/// This object will be stored in a [ArbLocaleTranslations] entity.
@freezed
class ArbTranslation with _$ArbTranslation {
  const ArbTranslation._();

  @With<ArbKeyMixin>()
  const factory ArbTranslation.placeholders({
    required String locale,
    required String key,
    @Default('') String value,
    @Default([]) List<String> placeholderNames,
  }) = ArbPlaceholdersTranslation;

  @With<ArbKeyMixin>()
  @With<ArbTranslationWithParameter<ArbPlural>>()
  const factory ArbTranslation.plural({
    required String locale,
    required String key,
    @Default('') String prefix,
    @Default('') String expression,
    @Default('') String suffix,
    @Default('') String parameterName,
    @Default([ArbPlural(option: ArbPluralOption.other)]) List<ArbPlural> options,
  }) = ArbPluralTranslation;

  @With<ArbKeyMixin>()
  @With<ArbTranslationWithParameter<ArbSelectCase>>()
  const factory ArbTranslation.select({
    required String locale,
    required String key,
    @Default('') String prefix,
    @Default('') String expression,
    @Default('') String suffix,
    @Default('') String parameterName,
    @Default([]) List<ArbSelectCase> options,
  }) = ArbSelectTranslation;

  ArbDefinitionType get type => map(
        placeholders: (_) => ArbDefinitionType.placeholders,
        plural: (_) => ArbDefinitionType.plural,
        select: (_) => ArbDefinitionType.select,
      );
}

@freezed
class ArbPlural with _$ArbPlural {
  const factory ArbPlural({
    required ArbPluralOption option,
    @Default('') String value,
  }) = _ArbPlural;
}

enum ArbPluralOption {
  zero('=0'),
  one('=1'),
  two('=2'),
  few('few'),
  many('many'),
  other('other');

  const ArbPluralOption(this.expression);

  /// Enum factory to lookup for the right enum value for a named type.
  factory ArbPluralOption.forExpression(String expression) {
    return values.firstWhere(
      (element) => element.expression == expression,
      orElse: () => throw ArgumentError('Invalid match for ArbPlural with $expression'),
    );
  }

  final String expression;
}

@freezed
class ArbSelectCase with _$ArbSelectCase {
  const factory ArbSelectCase({
    required String option,
    @Default('') String value,
  }) = _ArbSelectCase;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'arb_placeholder.freezed.dart';

mixin ArbKeyMixin {
  String get key;

  /// Value of key must conform to /[_a-zA-z]\w*/ and will never contain spaces.
  bool get hasKey => key.isNotEmpty;
}

mixin ArbHasDetailsMixin {
  String get description;
  String get example;

  /// Test to see if any optional field is filled in.
  bool get hasDetails => description.trim().isNotEmpty || example.trim().isNotEmpty;
}

@freezed
abstract class ArbPlaceholder with _$ArbPlaceholder implements ArbHasDetailsMixin {
  @With<ArbKeyMixin>()
  @With<ArbHasDetailsMixin>()
  const factory ArbPlaceholder({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
  }) = ArbBasePlaceholder;

  @With<ArbKeyMixin>()
  @Assert('hasDetails')
  const factory ArbPlaceholder.string({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(true) bool hasDetails,
  }) = ArbStringPlaceholder;

  @With<ArbKeyMixin>()
  @Assert('hasDetails')
  const factory ArbPlaceholder.number({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(true) bool hasDetails,
    required ArbNumberPlaceholderType type,
    ArbNumberPlaceholderFormat? format,
    @Default(<String, String>{}) Map<String, String> optionalParameters,
  }) = ArbNumberPlaceholder;

  @With<ArbKeyMixin>()
  @Assert('hasDetails')
  const factory ArbPlaceholder.dateTime({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(true) bool hasDetails,
    @Default('') String format,
    @Default(false) bool isCustomDateFormat,
  }) = ArbDateTimePlaceholder;
}

enum ArbNumberPlaceholderType {
  numType('num'),
  intType('int'),
  doubleType('double');

  const ArbNumberPlaceholderType(this.type);

  factory ArbNumberPlaceholderType.forType(String type) {
    return values.firstWhere(
      (element) => element.name == type,
      orElse: () => throw ArgumentError('Invalid match for ArbPlaceholderType with $type'),
    );
  }

  final String type;
}

enum ArbNumberPlaceholderFormat {
  compact([]),
  compactCurrency([
    ArbNumberPlaceholderParameter.name,
    ArbNumberPlaceholderParameter.symbol,
    ArbNumberPlaceholderParameter.decimalDigits,
  ]),
  compactSimpleCurrency([
    ArbNumberPlaceholderParameter.name,
    ArbNumberPlaceholderParameter.decimalDigits,
  ]),
  compactLong([]),
  currency([
    ArbNumberPlaceholderParameter.name,
    ArbNumberPlaceholderParameter.symbol,
    ArbNumberPlaceholderParameter.decimalDigits,
    ArbNumberPlaceholderParameter.customPattern,
  ]),
  decimalPattern([]),
  decimalPercentPattern([ArbNumberPlaceholderParameter.decimalDigits]),
  percentPattern([]),
  scientificPattern([]),
  simpleCurrency([
    ArbNumberPlaceholderParameter.name,
    ArbNumberPlaceholderParameter.decimalDigits,
  ]);

  const ArbNumberPlaceholderFormat(this.optionalParameters);

  factory ArbNumberPlaceholderFormat.forName(String name) {
    return values.firstWhere(
      (element) => element.name == name,
      orElse: () => throw ArgumentError('Invalid match for ArbNumberPlaceholderFormat with $name'),
    );
  }

  final List<ArbNumberPlaceholderParameter> optionalParameters;
}

enum ArbNumberPlaceholderParameter {
  name,
  symbol,
  decimalDigits,
  customPattern;

  factory ArbNumberPlaceholderParameter.forName(String name) {
    return values.firstWhere(
      (element) => element.name == name,
      orElse: () =>
          throw ArgumentError('Invalid match for ArbNumberPlaceholderParameter with $name'),
    );
  }
}

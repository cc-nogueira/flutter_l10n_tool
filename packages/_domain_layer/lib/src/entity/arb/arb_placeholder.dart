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
  @Assert('type == ArbPlaceholderType.undefinedType')
  const factory ArbPlaceholder.generic({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(ArbPlaceholderType.genericType) ArbPlaceholderType type,
  }) = ArbGenericPlaceholder;

  @With<ArbKeyMixin>()
  @Assert('hasDetails')
  @Assert('type == ArbPlaceholderType.stringType')
  const factory ArbPlaceholder.string({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(true) bool hasDetails,
    @Default(ArbPlaceholderType.stringType) ArbPlaceholderType type,
  }) = ArbStringPlaceholder;

  @With<ArbKeyMixin>()
  @Assert('hasDetails')
  @Assert(
      'type == ArbPlaceholderType.numType || type == ArbPlaceholderType.intType || type == ArbPlaceholderType.doubleType')
  const factory ArbPlaceholder.number({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(true) bool hasDetails,
    required ArbPlaceholderType type,
    ArbNumberPlaceholderFormat? format,
    @Default(<String, String>{}) Map<String, String> optionalParameters,
  }) = ArbNumberPlaceholder;

  @With<ArbKeyMixin>()
  @Assert('hasDetails')
  @Assert('type == ArbPlaceholderType.dateTimeType')
  const factory ArbPlaceholder.dateTime({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(true) bool hasDetails,
    @Default(ArbPlaceholderType.dateTimeType) ArbPlaceholderType type,
    @Default('') String format,
    @Default(false) bool isCustomDateFormat,
  }) = ArbDateTimePlaceholder;
}

enum ArbPlaceholderType {
  genericType('generic'),
  stringType('String'),
  numType('num', true),
  intType('int', true),
  doubleType('double', true),
  dateTimeType('DateTime');

  const ArbPlaceholderType(this.type, [this.isNumberType = false]);

  factory ArbPlaceholderType.forType(String type) {
    return values.firstWhere(
      (element) => element.name == type,
      orElse: () => throw ArgumentError('Invalid match for ArbPlaceholderType with $type'),
    );
  }

  final String type;
  final bool isNumberType;
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

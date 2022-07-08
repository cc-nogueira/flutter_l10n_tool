import 'package:freezed_annotation/freezed_annotation.dart';

part 'arb_placeholder.freezed.dart';

mixin ArbKeyMixin {
  String get key;

  /// Value of key must conform to /[_a-zA-z]\w*/ and will never contain spaces.
  bool get hasKey => key.isNotEmpty;
}

abstract class ArbPlaceholderBase {
  const ArbPlaceholderBase();

  String get key;
  String get description;
  String get example;

  bool get hasKey;
  bool get hasDetails;
}

@freezed
class ArbPlaceholder with _$ArbPlaceholder, ArbKeyMixin implements ArbPlaceholderBase {
  const factory ArbPlaceholder({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
  }) = _ArbPlaceholder;

  const ArbPlaceholder._();

  /// Test to see if any optional field is filled in.
  @override
  bool get hasDetails => description.trim().isNotEmpty || example.trim().isNotEmpty;
}

@freezed
class ArbStringPlaceholder with _$ArbStringPlaceholder, ArbKeyMixin implements ArbPlaceholderBase {
  const factory ArbStringPlaceholder({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
  }) = _ArbStringPlaceholder;

  const ArbStringPlaceholder._();

  ArbPlaceholderType get type => ArbPlaceholderType.stringType;

  /// Always true since it defines its type.
  @override
  bool get hasDetails => true;
}

@freezed
class ArbNumberPlaceholder with _$ArbNumberPlaceholder, ArbKeyMixin implements ArbPlaceholderBase {
  const factory ArbNumberPlaceholder({
    @Default('') String key,
    required ArbPlaceholderType type,
    @Default('') String description,
    @Default('') String example,
    ArbNumberPlaceholderFormat? format,
    @Default(<String, String>{}) Map<String, String> optionalParameters,
  }) = _ArbNumberPlaceholder;

  const ArbNumberPlaceholder._();

  /// Always true since it defines its type.
  @override
  bool get hasDetails => true;
}

@freezed
class ArbDateTimePlaceholder
    with _$ArbDateTimePlaceholder, ArbKeyMixin
    implements ArbPlaceholderBase {
  const factory ArbDateTimePlaceholder({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default('') String format,
    @Default(false) bool isCustomDateFormat,
  }) = _ArbDateTimePlaceholder;

  const ArbDateTimePlaceholder._();

  ArbPlaceholderType get type => ArbPlaceholderType.dateTimeType;

  /// Always true since it defines its type.
  @override
  bool get hasDetails => true;
}

enum ArbPlaceholderType {
  stringType('String'),
  numType('num'),
  intType('int'),
  doubleType('double'),
  dateTimeType('DateTime');

  const ArbPlaceholderType(this.type);

  factory ArbPlaceholderType.forType(String type) {
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

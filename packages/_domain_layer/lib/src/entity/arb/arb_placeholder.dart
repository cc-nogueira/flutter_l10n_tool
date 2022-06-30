import 'package:freezed_annotation/freezed_annotation.dart';

part 'arb_placeholder.freezed.dart';

abstract class ArbPlaceholderBase {
  const ArbPlaceholderBase();

  String get key;
  String? get description;
  String? get example;
}

@freezed
class ArbPlaceholder with _$ArbPlaceholder implements ArbPlaceholderBase {
  const factory ArbPlaceholder({
    required String key,
    String? description,
    String? example,
  }) = _ArbPlaceholder;
}

@freezed
class ArbNumberPlaceholder with _$ArbNumberPlaceholder implements ArbPlaceholderBase {
  const factory ArbNumberPlaceholder({
    required String key,
    required ArbPlaceholderType type,
    String? description,
    String? example,
    ArbNumberPlaceholderFormat? format,
    Map<String, dynamic>? optionalParameters,
  }) = _ArbNumberPlaceholder;
}

@freezed
class ArbDateTimePlaceholder with _$ArbDateTimePlaceholder implements ArbPlaceholderBase {
  const factory ArbDateTimePlaceholder({
    required String key,
    String? description,
    String? example,
    String? format,
    @Default(false) bool isCustomDateFormat,
  }) = _ArbDateTimePlaceholder;

  const ArbDateTimePlaceholder._();

  ArbPlaceholderType get type => ArbPlaceholderType.dateTimeType;
}

enum ArbPlaceholderType {
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

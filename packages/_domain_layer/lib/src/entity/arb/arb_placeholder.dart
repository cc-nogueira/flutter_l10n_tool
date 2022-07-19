import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_key_mixin.dart';

part 'arb_placeholder.freezed.dart';

/// An union of possible ArbPlaceholders as defined in ICU and Flutter projects.
///
/// - ArbGenericPlaceholder
/// - ArbStringPlaceholder
/// - ArbNumberPlaceholder
/// = ArbDateTimePlaceholder
@freezed
class ArbPlaceholder with _$ArbPlaceholder {
  /// ArbGenericPlaceholder factory with [ArbKeyMixin].
  /// Represents a placeholder with no specific type defined in the template file.
  ///
  /// It contains the common key, description and example fields.
  /// It has the fixed type [ArbPlaceholderType.genericType].
  @With<ArbKeyMixin>()
  @Assert('type == ArbPlaceholderType.genericType')
  const factory ArbPlaceholder.generic({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(ArbPlaceholderType.genericType) ArbPlaceholderType type,
  }) = ArbGenericPlaceholder;

  /// ArbStringPlaceholder factory with [ArbKeyMixin].
  ///
  /// It contains the common key, description and example fields.
  /// It has the fixed type [ArbPlaceholderType.stringType].
  @With<ArbKeyMixin>()
  @Assert('type == ArbPlaceholderType.stringType')
  const factory ArbPlaceholder.string({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(ArbPlaceholderType.stringType) ArbPlaceholderType type,
  }) = ArbStringPlaceholder;

  /// ArbNumberPlaceholder factory with [ArbKeyMixin].
  ///
  /// It contains the common key, description and example fields.
  /// It may have one of the numeric types:
  /// - [ArbPlaceholderType.numType]
  /// - [ArbPlaceholderType.intType]
  /// - [ArbPlaceholderType.doubleType]
  /// It mau contain a [ArbNumberPlaceholderFormat] format and that format associated optional
  /// parameters.
  @With<ArbKeyMixin>()
  @Assert(
      'type == ArbPlaceholderType.numType || type == ArbPlaceholderType.intType || type == ArbPlaceholderType.doubleType')
  const factory ArbPlaceholder.number({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    required ArbPlaceholderType type,
    ArbNumberPlaceholderFormat? format,
    @Default(<String, String>{}) Map<String, String> optionalParameters,
  }) = ArbNumberPlaceholder;

  /// ArbDateTimePlaceholder factory with [ArbKeyMixin].
  ///
  /// It contains the common key, description and example fields.
  /// It has the fixed type [ArbPlaceholderType.dateTimeType].
  ///
  /// It may use an predefined ICU data format (from DateTime predefined constructors)
  /// or use a custom format. When the useCustomFormat flag is set the value in icuFormat is
  /// irrelevant.
  @With<ArbKeyMixin>()
  @Assert('type == ArbPlaceholderType.dateTimeType')
  const factory ArbPlaceholder.dateTime({
    @Default('') String key,
    @Default('') String description,
    @Default('') String example,
    @Default(ArbPlaceholderType.dateTimeType) ArbPlaceholderType type,
    required ArbIcuDateTimePlaceholderFormat icuFormat,
    @Default(false) bool useCustomFormat,
    @Default('') String customFormat,
  }) = ArbDateTimePlaceholder;
}

/// Possible ArbPlaceholder types.
enum ArbPlaceholderType {
  genericType('generic'),
  stringType('String'),
  numType('num', true),
  intType('int', true),
  doubleType('double', true),
  dateTimeType('DateTime');

  /// Enum constructor
  const ArbPlaceholderType(this.type, [this.isNumberType = false]);

  /// Enum factory to lookup for the right enum value for a named type.
  factory ArbPlaceholderType.forType(String type) {
    return values.firstWhere(
      (element) => element.name == type,
      orElse: () => throw ArgumentError('Invalid match for ArbPlaceholderType with $type'),
    );
  }

  final String type;
  final bool isNumberType;
}

/// Possible ArbNumberPlaceholder formats.
///
/// Each format specifies valid optional parameters.
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

  /// Enum constructor.
  const ArbNumberPlaceholderFormat(this.optionalParameters);

  /// Enum factory to lookup for a right enum value for a named type.
  factory ArbNumberPlaceholderFormat.forName(String name) {
    return values.firstWhere(
      (element) => element.name == name,
      orElse: () => throw ArgumentError('Invalid match for ArbNumberPlaceholderFormat with $name'),
    );
  }

  /// Optional parameters valid for each enum value.
  final List<ArbNumberPlaceholderParameter> optionalParameters;
}

/// Possible ArbNumberPlaceholder optional parameters.
///
/// These valid options for each Format are mapped by [ArbNumberPlaceholderFormat] enum.
enum ArbNumberPlaceholderParameter {
  name,
  symbol,
  decimalDigits,
  customPattern;

  /// Enum factory to lookup the right enum value for a named type.
  factory ArbNumberPlaceholderParameter.forName(String name) {
    return values.firstWhere(
      (element) => element.name == name,
      orElse: () =>
          throw ArgumentError('Invalid match for ArbNumberPlaceholderParameter with $name'),
    );
  }
}

/// Possible ICU Date formats.
///
/// These are the DateTime formats supported by Dart DateTime constructor.
enum ArbIcuDateTimePlaceholderFormat {
  day('DAY', 'd'),
  abbrWeekday('ABBR_WEEKDAY', 'E'),
  weekday('WEEKDAY', 'EEEE'),
  abbrStandaloneMonth('ABBR_STANDALONE_MONTH', 'LLL'),
  standaloneMonth('STANDALONE_MONTH', 'LLLL'),
  numMonth('NUM_MONTH', 'M'),
  numMonthDay('NUM_MONTH_DAY', 'Md'),
  numMonthWeekdayDay('NUM_MONTH_WEEKDAY_DAY', 'MEd'),
  abbrMonth('ABBR_MONTH', 'MMM'),
  abbrMonthDay('ABBR_MONTH_DAY', 'MMMd'),
  abbrMonthWeekdayDay('ABBR_MONTH_WEEKDAY_DAY', 'MMMEd'),
  month('MONTH', 'MMMM'),
  monthDay('MONTH_DAY', 'MMMMd'),
  monthWeekdayDay('MONTH_WEEKDAY_DAY', 'MMMMEEEEd'),
  abbrQuarter('ABBR_QUARTER', 'QQQ'),
  quarter('QUARTER', 'QQQQ'),
  year('YEAR', 'y'),
  yearNumMonth('YEAR_NUM_MONTH', 'yM'),
  yearNumMonthDay('YEAR_NUM_MONTH_DAY', 'yMd'),
  yearNumMonthWeekdayDay('YEAR_NUM_MONTH_WEEKDAY_DAY', 'yMEd'),
  yearAbbrMonth('YEAR_ABBR_MONTH', 'yMMM'),
  yearAbbrMonthDay('YEAR_ABBR_MONTH_DAY', 'yMMMd'),
  yearAbbrMonthWeekDay('YEAR_ABBR_MONTH_WEEKDAY_DAY', 'yMMMEd'),
  yearMonth('YEAR_MONTH', 'yMMMM'),
  yearMonthDay('YEAR_MONTH_DAY', 'yMMMMd'),
  yearMonthWeekdayDay('YEAR_MONTH_WEEKDAY_DAY', 'yMMMMEEEEd'),
  yearAbbrQuarter('YEAR_ABBR_QUARTER', 'yQQQ'),
  yearQuarter('YEAR_QUARTER', 'yQQQQ'),
  hour24('HOUR24', 'H'),
  hour24Minute('HOUR24_MINUTE', 'Hm'),
  hour24MinuteSecond('HOUR24_MINUTE_SECOND', 'Hms'),
  hour('HOUR', 'j'),
  hourMinute('HOUR_MINUTE', 'jm'),
  hourMinuteSecond('HOUR_MINUTE_SECOND', 'jms'),
  minute('MINUTE', 'm'),
  minuteSecond('MINUTE_SECOND', 'ms'),
  second('SECOND', 's');

  /// Enum constructor.
  const ArbIcuDateTimePlaceholderFormat(this.icuName, this.skeleton);

  /// Enum lookup by a provided constructor skeleton.
  /// This is not defined as a Factory method because we want to be able to return null
  /// signaling that a skeleton could represent a custom format.
  static ArbIcuDateTimePlaceholderFormat? forSkeleton(String skeleton) {
    for (final value in values) {
      if (value.skeleton == skeleton) return value;
    }
    return null;
  }

  /// ICU name for a format.
  final String icuName;

  /// Dart constructor skeleton for a format.
  final String skeleton;
}

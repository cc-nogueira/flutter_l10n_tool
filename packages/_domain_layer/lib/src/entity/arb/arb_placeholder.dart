import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_key_mixin.dart';

part 'arb_placeholder.freezed.dart';

mixin ArbHasDetailsMixin {
  String get description;
  String get example;

  /// Test to see if any optional field is filled in.
  bool get hasDetails => description.trim().isNotEmpty || example.trim().isNotEmpty;
}

@freezed
class ArbPlaceholder with _$ArbPlaceholder {
  @With<ArbKeyMixin>()
  @With<ArbHasDetailsMixin>()
  @Assert('type == ArbPlaceholderType.genericType')
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
    required ArbIcuDatePlaceholderFormat icuFormat,
    @Default(false) bool useCustomFormat,
    @Default('') String customFormat,
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

enum ArbIcuDatePlaceholderFormat {
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

  const ArbIcuDatePlaceholderFormat(this.icuName, this.skeleton);

  static ArbIcuDatePlaceholderFormat? forSkeleton(String skeleton) {
    for (final value in values) {
      if (value.skeleton == skeleton) return value;
    }
    return null;
  }

  final String icuName;
  final String skeleton;
}

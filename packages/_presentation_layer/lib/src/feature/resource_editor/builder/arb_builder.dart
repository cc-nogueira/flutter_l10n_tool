import 'package:flutter/material.dart';

import '../../../common/theme/warning_theme_extension.dart';

class ArbBuilder {
  ArbBuilder();

  static const leadingSize = 40.0;
  static const leadingSeparation = 12.0;
  static const leadingSeparator = SizedBox(width: leadingSeparation);

  bool _initPending = true;
  late final TextTheme textTheme;
  late final ColorScheme colors;
  late final WarningTheme? warning;

  void init(BuildContext context) {
    if (_initPending) {
      textTheme = Theme.of(context).textTheme;
      colors = Theme.of(context).colorScheme;
      warning = Theme.of(context).extension<WarningTheme>();
      _initPending = false;
    }
  }

  TextStyle get titleStyle => textTheme.titleMedium!;
  TextStyle get subtitleStyle => textTheme.bodyMedium!.copyWith(color: textTheme.bodySmall?.color);
  TextStyle get markingStyle => subtitleStyle;
  TextStyle get valueStyle => textTheme.bodyMedium!;
  TextStyle get optionStyle => textTheme.bodyMedium!.copyWith(color: colors.primary);
  TextStyle get invalidOptionStyle => textTheme.bodyMedium!.copyWith(color: colors.error);
  TextStyle get warningStyle => textTheme.bodyMedium!.copyWith(color: warning?.backgroundColor);
}

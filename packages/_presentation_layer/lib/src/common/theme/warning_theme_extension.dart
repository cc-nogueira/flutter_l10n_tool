import 'package:flutter/material.dart';

class WarningTheme extends ThemeExtension<WarningTheme> {
  const WarningTheme({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.iconColor,
  });

  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  ThemeExtension<WarningTheme> copyWith(
      {Color? foregroundColor, Color? backgroundColor, Color? iconColor}) {
    return WarningTheme(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  @override
  ThemeExtension<WarningTheme> lerp(ThemeExtension<WarningTheme>? other, double t) {
    if (other is! WarningTheme) {
      return this;
    }
    return WarningTheme(
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
    );
  }
}

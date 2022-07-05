import 'package:flutter/material.dart';

mixin TranslationTileMixin {
  static const leadingIcon = Icon(Icons.translate);
  static const leadingSize = 40.0;
  static const leadingSeparation = 12.0;
  static const leadingSeparator = SizedBox(width: leadingSeparation);

  Widget tileTitle(TextTheme theme,
      {required String title, String? subtitle, required Widget trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: leadingSize, height: leadingSize, child: Center(child: leadingIcon)),
        leadingSeparator,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle(theme)),
              if (subtitle != null) Text(subtitle, style: subtitleStyle(theme)),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  TextStyle titleStyle(TextTheme theme) => theme.titleMedium!;

  TextStyle subtitleStyle(TextTheme theme) =>
      theme.bodyMedium!.copyWith(color: theme.caption?.color);

  TextStyle markingStyle(TextTheme theme) => subtitleStyle(theme);

  TextStyle valueStyle(TextTheme theme) => theme.bodyMedium!;

  TextStyle optionStyle(TextTheme theme, ColorScheme colors) =>
      theme.bodyMedium!.copyWith(color: colors.primary);
}

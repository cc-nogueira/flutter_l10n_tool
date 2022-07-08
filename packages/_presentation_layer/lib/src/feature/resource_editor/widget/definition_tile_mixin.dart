import 'package:flutter/material.dart';

mixin DefinitionTileMixin {
  static const leadingIcon = Icon(Icons.key);
  static const leadingSize = 40.0;
  static const leadingSeparation = 12.0;
  static const leadingSeparator = SizedBox(width: leadingSeparation);
  static const verticalSeparator = SizedBox(height: 16);

  Widget tileIcon() =>
      const SizedBox(width: leadingSize, height: leadingSize, child: Center(child: leadingIcon));

  Widget definitionTile({
    required Widget content,
    required Widget trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tileIcon(),
        leadingSeparator,
        Expanded(child: content),
        trailing,
      ],
    );
  }

  TextStyle markingStyle(TextTheme theme) => subtitleStyle(theme);

  TextStyle optionStyle(TextTheme theme, ColorScheme colors) =>
      theme.bodyMedium!.copyWith(color: colors.primary);

  TextStyle subtitleStyle(TextTheme theme) =>
      theme.bodyMedium!.copyWith(color: theme.caption?.color);

  TextStyle titleStyle(TextTheme theme) => theme.titleMedium!;

  TextStyle valueStyle(TextTheme theme) => theme.bodyMedium!;
}

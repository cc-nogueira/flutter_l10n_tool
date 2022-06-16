import 'package:flutter/material.dart';

ButtonStyle filledButtonStyle(ColorScheme colors) => ElevatedButton.styleFrom(
      onPrimary: colors.onPrimary,
      primary: colors.primary,
      //textStyle: const TextStyle(fontWeight: FontWeight.normal),
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

ButtonStyle filledTonalButtonStyle(ColorScheme colors) => ElevatedButton.styleFrom(
      onPrimary: colors.onSecondaryContainer,
      primary: colors.secondaryContainer,
      //textStyle: const TextStyle(fontWeight: FontWeight.normal),
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

TextButton textButton({required String text, required VoidCallback? onPressed}) =>
    TextButton(onPressed: onPressed, child: Text(text));

OutlinedButton outlinedButton({
  required String text,
  required VoidCallback? onPressed,
}) =>
    OutlinedButton(onPressed: onPressed, child: Text(text));

ElevatedButton filledButton({
  required ColorScheme colors,
  required String text,
  required VoidCallback? onPressed,
}) =>
    ElevatedButton(style: filledButtonStyle(colors), onPressed: onPressed, child: Text(text));

ElevatedButton filledTonalButton({
  required ColorScheme colors,
  required String text,
  required VoidCallback? onPressed,
}) =>
    ElevatedButton(style: filledTonalButtonStyle(colors), onPressed: onPressed, child: Text(text));

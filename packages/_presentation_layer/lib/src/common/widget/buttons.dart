import 'package:flutter/material.dart';

ButtonStyle segmentedButtonStyle(
  ColorScheme colors,
  MainAxisAlignment align, {
  bool selected = false,
  Size? minimumSize,
}) {
  final isLeft = align == MainAxisAlignment.start;
  final isRight = align == MainAxisAlignment.end;
  return OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: isLeft ? const Radius.circular(30) : Radius.zero,
        bottomLeft: isLeft ? const Radius.circular(30) : Radius.zero,
        topRight: isRight ? const Radius.circular(30) : Radius.zero,
        bottomRight: isRight ? const Radius.circular(30) : Radius.zero,
      ),
    ),
    backgroundColor: selected ? colors.secondaryContainer : null,
    primary: selected ? colors.onSecondaryContainer : colors.onSurface,
    minimumSize: minimumSize,
  );
}

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

OutlinedButton segmentedButton({
  required ColorScheme colors,
  required MainAxisAlignment align,
  required String text,
  TextStyle? style,
  double checkSize = 16.0,
  Size? minimumSize,
  required VoidCallback? onPressed,
  bool selected = false,
}) {
  assert(align == MainAxisAlignment.start ||
      align == MainAxisAlignment.center ||
      align == MainAxisAlignment.end);
  return selected
      ? OutlinedButton.icon(
          style: segmentedButtonStyle(colors, align, selected: selected, minimumSize: minimumSize),
          onPressed: onPressed,
          icon: Icon(Icons.check, size: checkSize),
          label: Text(text, style: style),
        )
      : OutlinedButton(
          style: segmentedButtonStyle(colors, align, selected: selected, minimumSize: minimumSize),
          onPressed: onPressed,
          child: Text(text, style: style),
        );
}

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

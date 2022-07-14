import 'package:flutter/material.dart';

ButtonStyle segmentedButtonStyle(
  ColorScheme colors,
  MainAxisAlignment align, {
  bool selected = false,
  Size? minimumSize,
  Color? backgroundColor,
  Color? color,
  Color? selectedBackgroundColor,
  Color? selectedColor,
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
    backgroundColor:
        selected ? selectedBackgroundColor ?? colors.secondaryContainer : backgroundColor,
    primary: selected ? selectedColor ?? colors.onSecondaryContainer : color ?? colors.onSurface,
    minimumSize: minimumSize,
  );
}

ButtonStyle chipButtonStyle(
  ColorScheme colors, {
  EdgeInsets? padding,
  bool selected = false,
  Size? minimumSize,
  Color? backgroundColor,
  Color? color,
  Color? selectedBackgroundColor,
  Color? selectedColor,
  Alignment? align,
}) {
  return OutlinedButton.styleFrom(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    padding: padding,
    backgroundColor:
        selected ? selectedBackgroundColor ?? colors.secondaryContainer : backgroundColor,
    primary:
        selected ? selectedColor ?? colors.onSecondaryContainer : color ?? colors.onSurfaceVariant,
    minimumSize: minimumSize,
    alignment: align,
  );
}

ButtonStyle filledButtonStyle(ColorScheme colors) => ElevatedButton.styleFrom(
      onPrimary: colors.onPrimary,
      primary: colors.primary,
      //textStyle: const TextStyle(fontWeight: FontWeight.normal),
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

ButtonStyle filledTonalButtonStyle(ColorScheme colors) => ElevatedButton.styleFrom(
      onPrimary: colors.onSecondary,
      primary: colors.secondary,
      // textStyle: const TextStyle(fontWeight: FontWeight.normal),
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

TextButton textButton({required String text, required VoidCallback? onPressed}) =>
    TextButton(onPressed: onPressed, child: Text(text, overflow: TextOverflow.ellipsis));

OutlinedButton outlinedButton({
  required String text,
  required VoidCallback? onPressed,
  TextOverflow? overflow,
}) =>
    OutlinedButton(onPressed: onPressed, child: Text(text, overflow: overflow));

OutlinedButton segmentedButton({
  required ColorScheme colors,
  required MainAxisAlignment align,
  required String text,
  TextStyle? style,
  double checkSize = 16.0,
  Size? minimumSize,
  required VoidCallback? onPressed,
  bool selected = false,
  Color? backgroundColor,
  Color? color,
  Color? selectedBackgroundColor,
  Color? selectedColor,
}) {
  assert(align == MainAxisAlignment.start ||
      align == MainAxisAlignment.center ||
      align == MainAxisAlignment.end);
  return selected
      ? OutlinedButton.icon(
          style: segmentedButtonStyle(
            colors,
            align,
            selected: selected,
            minimumSize: minimumSize,
            backgroundColor: backgroundColor,
            color: color,
            selectedBackgroundColor: selectedBackgroundColor,
            selectedColor: selectedColor,
          ),
          onPressed: onPressed,
          icon: Icon(Icons.check, size: checkSize),
          label: Text(text, style: style),
        )
      : OutlinedButton(
          style: segmentedButtonStyle(
            colors,
            align,
            selected: selected,
            minimumSize: minimumSize,
            backgroundColor: backgroundColor,
            color: color,
            selectedBackgroundColor: selectedBackgroundColor,
            selectedColor: selectedColor,
          ),
          onPressed: onPressed,
          child: Text(text, style: style),
        );
}

OutlinedButton inputChip({
  Key? key,
  required ColorScheme colors,
  required String text,
  TextStyle? style,
  double deleteSize = 18.0,
  Size? minimumSize,
  VoidCallback? onPressed,
  VoidCallback? onDelete,
  bool selected = false,
  Color? backgroundColor,
  Color? color,
  Color? selectedBackgroundColor,
  Color? selectedColor,
  Alignment? align,
}) {
  final child = onDelete == null
      ? Text(text, style: style)
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: style),
            const SizedBox(width: 8),
            InkWell(onTap: onDelete, child: Icon(Icons.close, size: deleteSize)),
          ],
        );
  return OutlinedButton(
    key: key,
    style: chipButtonStyle(
      colors,
      padding: EdgeInsets.only(left: 12, right: onDelete == null ? 12 : 8, top: 4, bottom: 6),
      selected: selected,
      minimumSize: minimumSize,
      backgroundColor: backgroundColor,
      color: color,
      selectedBackgroundColor: selectedBackgroundColor,
      selectedColor: selectedColor,
      align: align,
    ),
    onPressed: onPressed,
    child: child,
  );
}

ElevatedButton filledButton({
  Key? key,
  required ColorScheme colors,
  required String text,
  required VoidCallback? onPressed,
  TextOverflow? overflow,
}) =>
    ElevatedButton(
      key: key,
      style: filledButtonStyle(colors),
      onPressed: onPressed,
      child: Text(text, overflow: overflow),
    );

ElevatedButton filledTonalButton({
  Key? key,
  required ColorScheme colors,
  required String text,
  required VoidCallback? onPressed,
  TextOverflow? overflow,
}) =>
    ElevatedButton(
      key: key,
      style: filledTonalButtonStyle(colors),
      onPressed: onPressed,
      child: Text(text, overflow: overflow),
    );

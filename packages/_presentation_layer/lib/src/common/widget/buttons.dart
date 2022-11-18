import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

ButtonStyle segmentedButtonStyle(ColorScheme colors, MainAxisAlignment align,
    {bool selected = false,
    Size? minimumSize,
    Color? backgroundColor,
    Color? color,
    Color? selectedBackgroundColor,
    Color? selectedColor,
    InteractiveInkFeatureFactory? splashFactory}) {
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
    foregroundColor:
        selected ? selectedColor ?? colors.onSecondaryContainer : color ?? colors.onSurface,
    minimumSize: minimumSize,
    splashFactory: splashFactory,
  );
}

ButtonStyle chipButtonStyle(
  ColorScheme colors, {
  EdgeInsets? padding,
  bool selected = false,
  bool hideBorder = false,
  Size? minimumSize,
  Color? borderColor,
  Color? backgroundColor,
  Color? color,
  Color? selectedBackgroundColor,
  Color? selectedColor,
  Alignment? align,
}) {
  return OutlinedButton.styleFrom(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    padding: padding,
    side: (hideBorder || borderColor != null)
        ? BorderSide(
            color: borderColor ?? colors.onSurface.withOpacity(0.12),
            style: hideBorder ? BorderStyle.none : BorderStyle.solid)
        : null,
    backgroundColor:
        selected ? selectedBackgroundColor ?? colors.secondaryContainer : backgroundColor,
    foregroundColor:
        selected ? selectedColor ?? colors.onSecondaryContainer : color ?? colors.onSurfaceVariant,
    minimumSize: minimumSize,
    alignment: align,
  );
}

ButtonStyle filledButtonStyle(ColorScheme colors) => ElevatedButton.styleFrom(
      foregroundColor: colors.onPrimary,
      backgroundColor: colors.primary,
      //textStyle: const TextStyle(fontWeight: FontWeight.normal),
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

ButtonStyle filledTonalButtonStyle(ColorScheme colors) => ElevatedButton.styleFrom(
      foregroundColor: colors.onSecondary,
      backgroundColor: colors.secondary,
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

OutlinedButton segmentedTextButton({
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
  bool showSelectedMark = true,
  bool noSplash = false,
}) {
  return segmentedButton(
    colors: colors,
    align: align,
    child: Text(text, style: style),
    checkSize: checkSize,
    minimumSize: minimumSize,
    onPressed: onPressed,
    selected: selected,
    backgroundColor: backgroundColor,
    color: color,
    selectedBackgroundColor: selectedBackgroundColor,
    selectedColor: selectedColor,
    showSelectedMark: showSelectedMark,
    noSplash: noSplash,
  );
}

OutlinedButton segmentedButton({
  required ColorScheme colors,
  required MainAxisAlignment align,
  required Widget child,
  double checkSize = 16.0,
  Size? minimumSize,
  required VoidCallback? onPressed,
  bool selected = false,
  Color? backgroundColor,
  Color? color,
  Color? selectedBackgroundColor,
  Color? selectedColor,
  bool showSelectedMark = true,
  bool noSplash = false,
}) {
  assert(align == MainAxisAlignment.start ||
      align == MainAxisAlignment.center ||
      align == MainAxisAlignment.end);
  return selected && showSelectedMark
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
            splashFactory: noSplash ? NoSplash.splashFactory : null,
          ),
          onPressed: onPressed,
          icon: Icon(Icons.check, size: checkSize),
          label: child,
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
            splashFactory: noSplash ? NoSplash.splashFactory : null,
          ),
          onPressed: onPressed,
          child: child,
        );
}

OutlinedButton textInputChip({
  Key? key,
  required ColorScheme colors,
  required String text,
  TextStyle? style,
  double deleteSize = 18.0,
  Size? minimumSize,
  VoidCallback? onPressed,
  VoidCallback? onDelete,
  bool selected = false,
  Icon? icon,
  Color? backgroundColor,
  Color? color,
  Color? selectedBackgroundColor,
  Color? selectedColor,
  Alignment? align,
}) =>
    inputChip(
      key: key,
      colors: colors,
      child: Text(text, style: style),
      deleteSize: deleteSize,
      minimumSize: minimumSize,
      onPressed: onPressed,
      onDelete: onDelete,
      selected: selected,
      icon: icon,
      backgroundColor: backgroundColor,
      color: color,
      selectedBackgroundColor: selectedBackgroundColor,
      selectedColor: selectedColor,
      align: align,
    );

OutlinedButton inputChip({
  Key? key,
  required ColorScheme colors,
  required Widget child,
  double deleteSize = 18.0,
  Size? minimumSize,
  VoidCallback? onPressed,
  VoidCallback? onDelete,
  bool selected = false,
  bool dotted = false,
  Widget? icon,
  Color? borderColor,
  Color? backgroundColor,
  Color? color,
  Color? selectedBackgroundColor,
  Color? selectedColor,
  Alignment? align,
}) {
  final padding =
      EdgeInsets.only(left: 12, right: onDelete == null ? 12 : 8, top: dotted ? 6 : 4, bottom: 6);
  final basicChild = onDelete == null && (!dotted || icon == null)
      ? child
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotted && icon != null) ...[
              icon,
              const SizedBox(width: 8),
            ],
            child,
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              InkWell(onTap: onDelete, child: Icon(Icons.close, size: deleteSize)),
            ],
          ],
        );
  final chipChild = dotted
      ? DottedBorder(
          padding: padding,
          borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          color: borderColor ?? colors.outline,
          child: basicChild,
        )
      : basicChild;
  return icon == null || dotted
      ? OutlinedButton(
          key: key,
          style: chipButtonStyle(
            colors,
            padding: dotted ? EdgeInsets.zero : padding,
            selected: selected,
            minimumSize: minimumSize,
            hideBorder: dotted,
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            color: color,
            selectedBackgroundColor: selectedBackgroundColor,
            selectedColor: selectedColor,
            align: align,
          ),
          onPressed: onPressed,
          child: chipChild,
        )
      : OutlinedButton.icon(
          key: key,
          style: chipButtonStyle(
            colors,
            padding: dotted ? EdgeInsets.zero : padding,
            selected: selected,
            hideBorder: dotted,
            borderColor: borderColor,
            minimumSize: minimumSize,
            backgroundColor: backgroundColor,
            color: color,
            selectedBackgroundColor: selectedBackgroundColor,
            selectedColor: selectedColor,
            align: align,
          ),
          onPressed: onPressed,
          icon: icon,
          label: chipChild,
        );
}

ElevatedButton filledButton({
  Key? key,
  required ColorScheme colors,
  required String text,
  required VoidCallback? onPressed,
  TextOverflow? overflow,
  bool fitText = false,
}) {
  assert(overflow == null || fitText == false);
  final child = fitText ? FittedBox(child: Text(text)) : Text(text, overflow: overflow);
  return ElevatedButton(
    key: key,
    style: filledButtonStyle(colors),
    onPressed: onPressed,
    child: child,
  );
}

ElevatedButton filledTonalButton({
  Key? key,
  required ColorScheme colors,
  required String text,
  required VoidCallback? onPressed,
  TextOverflow? overflow,
  bool fitText = false,
}) {
  assert(overflow == null || fitText == false);
  final child = fitText ? FittedBox(child: Text(text)) : Text(text, overflow: overflow);
  return ElevatedButton(
    key: key,
    style: filledTonalButtonStyle(colors),
    onPressed: onPressed,
    child: child,
  );
}

Widget clearFiltersButton(ColorScheme colors, VoidCallback onPressed) => IconButton(
      icon: const Icon(Icons.backspace_outlined, size: 20),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      splashRadius: 20,
      color: colors.secondary,
    );

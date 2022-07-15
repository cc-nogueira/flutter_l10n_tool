import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';

class PlaceholderButton extends StatelessWidget {
  const PlaceholderButton({
    super.key,
    required this.colors,
    required this.text,
    required this.onPressed,
    this.tonal = false,
    this.overflow,
    this.fitText = false,
    this.hide = false,
    this.opacity = 1.0,
  }) : assert(overflow == null || !fitText);

  final ColorScheme colors;
  final String text;
  final bool tonal;
  final TextOverflow? overflow;
  final bool fitText;
  final VoidCallback? onPressed;
  final bool hide;
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        ignoring: hide || opacity < 1.0 || onPressed == null,
        child: _buttonWidget,
      );

  Widget get _buttonWidget {
    final resolvedOpacity = hide ? 0.0 : opacity;
    return Opacity(opacity: resolvedOpacity, child: _button);
  }

  Widget get _button => tonal
      ? filledTonalButton(
          colors: colors, text: text, overflow: overflow, fitText: fitText, onPressed: onPressed)
      : filledButton(
          colors: colors, text: text, overflow: overflow, fitText: fitText, onPressed: onPressed);
}

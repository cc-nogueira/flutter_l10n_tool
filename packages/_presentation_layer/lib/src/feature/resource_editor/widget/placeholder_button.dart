import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';

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

  factory PlaceholderButton.newPlaceholder({
    Key? key,
    required AppLocalizations loc,
    required ColorScheme colors,
    bool hide = false,
    double opacity = 1.0,
    VoidCallback? onPressed,
  }) =>
      PlaceholderButton(
        key: key,
        colors: colors,
        text: loc.label_new,
        tonal: true,
        hide: hide,
        opacity: opacity,
        onPressed: onPressed ?? () {},
      );

  factory PlaceholderButton.add({
    Key? key,
    required AppLocalizations loc,
    required ColorScheme colors,
    bool tonal = false,
    bool hide = false,
    double opacity = 1.0,
    VoidCallback? onPressed,
  }) =>
      PlaceholderButton(
        key: key,
        colors: colors,
        text: loc.label_add_placeholder,
        tonal: tonal,
        hide: hide,
        opacity: opacity,
        fitText: true,
        onPressed: onPressed,
      );

  factory PlaceholderButton.update({
    Key? key,
    required AppLocalizations loc,
    required ColorScheme colors,
    bool tonal = false,
    bool hide = false,
    double opacity = 1.0,
    VoidCallback? onPressed,
  }) =>
      PlaceholderButton(
        key: key,
        colors: colors,
        text: loc.label_update_placeholder,
        tonal: tonal,
        hide: hide,
        opacity: opacity,
        onPressed: onPressed,
      );

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

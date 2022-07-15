import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';

abstract class PlaceholderButton extends StatelessWidget {
  const PlaceholderButton(
      {super.key,
      required this.loc,
      required this.colors,
      this.onPressed,
      this.hide = false,
      this.opacity = 1.0});

  final AppLocalizations loc;
  final ColorScheme colors;
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

  Widget get _button;
}

class NewPlaceholderButton extends PlaceholderButton {
  const NewPlaceholderButton({
    super.key,
    required super.loc,
    required super.colors,
    super.onPressed,
    super.hide,
    super.opacity,
  });

  @override
  Widget get _button => filledTonalButton(
      colors: colors,
      text: loc.label_new,
      overflow: TextOverflow.ellipsis,
      onPressed: onPressed ?? () {});
}

class AddPlaceholderButton extends PlaceholderButton {
  const AddPlaceholderButton({
    super.key,
    required super.loc,
    required super.colors,
    super.onPressed,
    super.hide,
    super.opacity,
    this.tonal = false,
  });

  final bool tonal;

  @override
  Widget get _button => tonal
      ? filledTonalButton(
          colors: colors,
          text: loc.label_add_placeholder,
          fitText: true,
          onPressed: onPressed,
        )
      : filledButton(
          colors: colors,
          text: loc.label_add_placeholder,
          fitText: true,
          onPressed: onPressed,
        );
}

class UpdatePlaceholderButton extends PlaceholderButton {
  const UpdatePlaceholderButton({
    super.key,
    required super.loc,
    required super.colors,
    super.onPressed,
    super.hide,
    super.opacity,
    this.tonal = false,
  });

  final bool tonal;

  @override
  Widget get _button => tonal
      ? filledTonalButton(
          colors: colors,
          text: loc.label_update_placeholder,
          overflow: TextOverflow.ellipsis,
          onPressed: onPressed,
        )
      : filledButton(
          colors: colors,
          text: loc.label_update_placeholder,
          overflow: TextOverflow.ellipsis,
          onPressed: onPressed,
        );
}

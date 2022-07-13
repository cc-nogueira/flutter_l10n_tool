import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';

abstract class PlaceholderButton extends StatelessWidget {
  const PlaceholderButton(
      {super.key, required this.loc, required this.colors, this.onPressed, this.hide = false});

  final AppLocalizations loc;
  final ColorScheme colors;
  final VoidCallback? onPressed;
  final bool hide;

  @override
  Widget build(BuildContext context) =>
      (hide || onPressed == null) ? IgnorePointer(child: _buttonWidget) : _button;

  Widget get _buttonWidget => hide ? Opacity(opacity: 0.3, child: _button) : _button;

  Widget get _button;
}

class NewPlaceholderButton extends PlaceholderButton {
  const NewPlaceholderButton(
      {super.key, required super.loc, required super.colors, super.onPressed, super.hide});

  @override
  Widget get _button => filledTonalButton(
      colors: colors,
      text: loc.label_new,
      overflow: TextOverflow.ellipsis,
      onPressed: onPressed ?? () {});
}

class SavePlaceholderButton extends PlaceholderButton {
  const SavePlaceholderButton(
      {super.key, required super.loc, required super.colors, super.onPressed, super.hide});

  @override
  Widget get _button => filledButton(
      colors: colors,
      text: loc.label_save_placeholder,
      overflow: TextOverflow.ellipsis,
      onPressed: onPressed);
}

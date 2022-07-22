import 'package:flutter/material.dart';

mixin DefinitionTileMixin {
  static const leadingIcon = Icon(Icons.key);
  static const leadingSize = 40.0;
  static const leadingSeparation = 12.0;
  static const leadingSeparator = SizedBox(width: leadingSeparation);

  Widget tileIcon() =>
      const SizedBox(width: leadingSize, height: leadingSize, child: Center(child: leadingIcon));

  Widget definitionTile({
    CrossAxisAlignment align = CrossAxisAlignment.center,
    required Widget content,
    required Widget trailing,
  }) {
    return Row(
      crossAxisAlignment: align,
      children: [
        tileIcon(),
        leadingSeparator,
        Expanded(child: content),
        trailing,
      ],
    );
  }
}

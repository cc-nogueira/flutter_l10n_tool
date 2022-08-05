import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import 'buttons.dart';

class ArbPlaceholderChip extends StatelessWidget {
  const ArbPlaceholderChip(
    this.placeholder, {
    super.key,
    this.onPressed,
    this.onDelete,
    this.selected = false,
  });

  final ArbPlaceholder placeholder;
  final bool selected;
  final ValueChanged<ArbPlaceholder>? onPressed;
  final ValueChanged<ArbPlaceholder>? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = selected ? colors.onSecondaryContainer : colors.onPrimaryContainer;
    final icon = placeholder.maybeMap(
      dateTime: (_) => Icon(Icons.calendar_month_outlined, color: iconColor),
      number: (_) => Icon(Icons.onetwothree_outlined, color: iconColor),
      string: (_) => Icon(Icons.abc, color: iconColor),
      orElse: () => null,
    );
    return IgnorePointer(
      ignoring: selected || (onPressed == null && onDelete == null),
      child: textInputChip(
        colors: colors,
        icon: icon,
        text: placeholder.key,
        selected: selected,
        onPressed: () => onPressed?.call(placeholder),
        onDelete: onDelete == null ? null : () => onDelete!(placeholder),
      ),
    );
  }
}

class ArbChip extends StatelessWidget {
  const ArbChip(
    this.child, {
    super.key,
    this.onPressed,
    this.onDelete,
    this.selected = false,
    this.missing = false,
  });

  final Widget child;
  final bool selected;
  final bool missing;
  final VoidCallback? onPressed;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: selected || (onPressed == null && onDelete == null),
      child: inputChip(
        colors: colors,
        child: child,
        selected: selected,
        dotted: missing,
        borderColor: missing ? Colors.amberAccent : null,
        icon: missing
            ? const Tooltip(
                message: 'Missing case.',
                child: Icon(Icons.error_outline, size: 20, color: Colors.amber),
              )
            : null,
        onPressed: () => onPressed?.call(),
        onDelete: onDelete == null ? null : () => onDelete!(),
      ),
    );
  }
}

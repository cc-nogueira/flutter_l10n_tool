import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import 'definition_tile_mixin.dart';

abstract class DefinitionTile<T extends ArbDefinition> extends StatelessWidget
    with DefinitionTileMixin {
  const DefinitionTile({super.key, required this.definition, required this.onEdit});

  final T definition;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    final content = bodyContent(theme.textTheme, theme.colorScheme);
    return Container(
      decoration: BoxDecoration(color: colors.primaryContainer),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          definitionTile(content: titleContent(textTheme), trailing: titleTrailing()),
          if (content != null) content,
        ],
      ),
    );
  }

  Widget titleContent(TextTheme theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(definition.key, style: titleStyle(theme)),
          if (definition.description != null)
            SelectableText(definition.description!, style: subtitleStyle(theme)),
        ],
      );

  Widget titleTrailing() =>
      IconButton(icon: const Icon(Icons.edit), iconSize: 20, onPressed: onEdit);

  Widget? bodyContent(TextTheme theme, ColorScheme colors) => null;
}

class TextDefinitionTile extends DefinitionTile<ArbTextDefinition> {
  const TextDefinitionTile({
    super.key,
    required super.definition,
    required super.onEdit,
  });
}

class PluralDefinitionTile extends DefinitionTile<ArbPluralDefinition> {
  const PluralDefinitionTile({
    super.key,
    required super.definition,
    required super.onEdit,
  });
}

class SelectDefinitionTile extends DefinitionTile<ArbSelectDefinition> {
  const SelectDefinitionTile({
    super.key,
    required super.definition,
    required super.onEdit,
  });
}

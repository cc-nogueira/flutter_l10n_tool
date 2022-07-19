import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import 'definition_tile_mixin.dart';

abstract class DefinitionTile<T extends ArbDefinition> extends StatelessWidget
    with DefinitionTileMixin {
  const DefinitionTile({
    super.key,
    required this.definition,
    required this.isOriginal,
    required this.onEdit,
  });

  final T definition;
  final bool isOriginal;
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
          definitionTile(content: titleContent(textTheme), trailing: titleTrailing(context)),
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

  Widget titleTrailing(BuildContext context) => isOriginal
      ? _editButton()
      : Row(
          children: [_rollbackButton(context), _editButton()],
        );

  Widget _editButton() => IconButton(icon: const Icon(Icons.edit), iconSize: 20, onPressed: onEdit);

  Widget _rollbackButton(BuildContext context) => Tooltip(
        message: 'Definition modified. Click to rollback!',
        child: IconButton(
          icon: const Icon(Icons.restore),
          iconSize: 20,
          onPressed: () => _rollbackDefinition(context),
        ),
      );

  Widget? bodyContent(TextTheme theme, ColorScheme colors) => null;

  void _rollbackDefinition(BuildContext context) async {
    final confirmRollback = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Please confirm'),
        content: const Text(
          'Definition has been modified.\n'
          'Please confirm rollback or dismiss this dialog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Rollback Definition'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Dismiss'),
          )
        ],
      ),
    );
    if (confirmRollback == true) {
      return;
    }
  }
}

class PlaceholdersDefinitionTile extends DefinitionTile<ArbPlaceholdersDefinition> {
  const PlaceholdersDefinitionTile({
    super.key,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
  });

  @override
  Widget? bodyContent(TextTheme theme, ColorScheme colors) {
    final placeholders = definition.placeholders;
    if (placeholders.isEmpty) {
      return null;
    }
    return null;
  }
}

class PluralDefinitionTile extends DefinitionTile<ArbPluralDefinition> {
  const PluralDefinitionTile({
    super.key,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
  });
}

class SelectDefinitionTile extends DefinitionTile<ArbSelectDefinition> {
  const SelectDefinitionTile({
    super.key,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
  });
}

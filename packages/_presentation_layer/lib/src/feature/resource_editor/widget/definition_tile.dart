import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/arb_chip.dart';
import '../builder/arb_builder.dart';

abstract class DefinitionTile<T extends ArbDefinition> extends StatelessWidget {
  DefinitionTile({
    super.key,
    required this.displayOption,
    required this.definition,
    required this.isOriginal,
    required this.onEdit,
    required this.onRollback,
  }) : builder = ArbDefinitionBuilder(displayOption: displayOption, definition: definition);

  final ArbDefinitionBuilder builder;

  final DisplayOption displayOption;
  final T definition;
  final bool isOriginal;
  final VoidCallback onEdit;
  final VoidCallback onRollback;

  @override
  Widget build(BuildContext context) {
    builder.init(context);
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
          builder.definitionTile(
              content: titleContent(textTheme, colors), trailing: titleTrailing(context)),
          if (content != null) content,
        ],
      ),
    );
  }

  Widget titleContent(TextTheme theme, ColorScheme colors) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(definition.key, style: builder.titleStyle),
          if (definition.description != null && definition.description!.isNotEmpty)
            SelectableText(definition.description!, style: builder.subtitleStyle),
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
          'Please confirm rollback to origial value or dismiss this dialog.',
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
      onRollback();
    }
  }
}

class NewDefinitionTile extends DefinitionTile<ArbNewDefinition> {
  NewDefinitionTile({
    super.key,
    required super.displayOption,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
    required super.onRollback,
  });
}

class PlaceholdersDefinitionTile extends DefinitionTile<ArbPlaceholdersDefinition> {
  PlaceholdersDefinitionTile({
    super.key,
    required super.displayOption,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
    required super.onRollback,
  });

  @override
  Widget? bodyContent(TextTheme theme, ColorScheme colors) {
    final placeholders = definition.placeholders;
    if (placeholders.isEmpty) {
      return null;
    }
    final wrap = Wrap(
      spacing: 8.0,
      children: [for (final each in definition.placeholders) ArbPlaceholderChip(each)],
    );
    const leftPadding = ArbBuilder.leadingSize + ArbBuilder.leadingSeparation;
    return Padding(
      padding: const EdgeInsets.only(left: leftPadding, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayOption == DisplayOption.expanded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Placeholders:'),
            ),
          wrap,
        ],
      ),
    );
  }
}

abstract class DefinitionWithParameterTile<T extends ArbDefinition> extends DefinitionTile<T> {
  DefinitionWithParameterTile({
    super.key,
    required super.displayOption,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
    required super.onRollback,
  }) : assert(definition is ArbDefinitionWithParameter);

  @override
  Widget? bodyContent(TextTheme theme, ColorScheme colors) {
    const leftPadding = ArbBuilder.leadingSize + ArbBuilder.leadingSeparation;
    return Padding(
      padding: const EdgeInsets.only(left: leftPadding, top: 8.0),
      child: builder.descriptorWidget(),
    );
  }
}

class PluralDefinitionTile extends DefinitionWithParameterTile<ArbPluralDefinition> {
  PluralDefinitionTile({
    super.key,
    required super.displayOption,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
    required super.onRollback,
  });
}

class SelectDefinitionTile extends DefinitionWithParameterTile<ArbSelectDefinition> {
  SelectDefinitionTile({
    super.key,
    required super.displayOption,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
    required super.onRollback,
  });
}

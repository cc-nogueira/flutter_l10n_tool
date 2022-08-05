import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/form_mixin.dart';
import '../builder/arb_builder.dart';

class MissingTranslationTile extends StatelessWidget with ArbTranslationBuilderMixin {
  MissingTranslationTile({
    super.key,
    required this.locale,
    required this.onEdit,
  }) : builder = ArbBuilder();

  final String locale;
  final VoidCallback? onEdit;
  final ArbBuilder builder;

  @override
  Widget build(BuildContext context) {
    builder.init(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: tileIcons()),
        ArbBuilder.leadingSeparator,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tileTitle(
                title: Text(locale, style: builder.titleStyle),
                subtitle: subtitle(textTheme, colors),
                trailing: _editButton(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? subtitle(TextTheme theme, ColorScheme colors) =>
      Text('Missing translation', style: theme.bodyMedium!.copyWith(color: colors.error));

  Widget _editButton() => IconButton(icon: const Icon(Icons.edit), iconSize: 20, onPressed: onEdit);
}

abstract class TranslationTile<D extends ArbDefinition, T extends ArbTranslation>
    extends StatelessWidget {
  TranslationTile({
    super.key,
    required this.displayOption,
    required this.locale,
    required this.translation,
    required this.definition,
    required this.isOriginal,
    required this.onEdit,
    required this.onRollback,
  }) : builder = ArbTranslationBuilder.forArgs(
            displayOption: displayOption, definition: definition, translation: translation);

  final ArbTranslationBuilder builder;

  final DisplayOption displayOption;
  final String locale;
  final T translation;
  final D definition;
  final bool isOriginal;
  final VoidCallback? onEdit;
  final VoidCallback onRollback;

  @override
  Widget build(BuildContext context) {
    builder.init(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    final content = tileContent(textTheme, colors);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: builder.tileIcons()),
        ArbBuilder.leadingSeparator,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              builder.tileTitle(
                title: Text(locale, style: builder.titleStyle),
                subtitle: builder.descriptorWidget(),
                trailing: titleTrailing(context),
              ),
              if (content != null) content,
            ],
          ),
        ),
      ],
    );
  }

  Widget titleTrailing(BuildContext context) => isOriginal
      ? _editButton()
      : Row(
          children: [_rollbackButton(context), _editButton()],
        );

  Widget _editButton() => IconButton(icon: const Icon(Icons.edit), iconSize: 20, onPressed: onEdit);

  Widget _rollbackButton(BuildContext context) => Tooltip(
        message: 'Translation modified. Click to rollback!',
        child: IconButton(
          icon: const Icon(Icons.restore),
          iconSize: 20,
          onPressed: () => _rollbackTranslation(context),
        ),
      );

  void _rollbackTranslation(BuildContext context) async {
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

  Widget? tileContent(TextTheme theme, ColorScheme colors) => null;
}

class PlaceholdersTranslationTile
    extends TranslationTile<ArbPlaceholdersDefinition, ArbPlaceholdersTranslation> {
  PlaceholdersTranslationTile({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
    required super.onRollback,
  });
}

abstract class TranslationWithParameterTile<D extends ArbDefinitionWithParameter,
    T extends ArbTranslationWithParameter> extends TranslationTile<D, T> with ArbMixin {
  TranslationWithParameterTile({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
    required super.onRollback,
  });

  @override
  Widget? tileContent(TextTheme theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(right: ArbBuilder.leadingSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormMixin.verticalSeparator,
          ...builder.optionsWidgets(),
          FormMixin.verticalSeparator,
        ],
      ),
    );
  }
}

class PluralTranslationTile
    extends TranslationWithParameterTile<ArbPluralDefinition, ArbPluralTranslation> {
  PluralTranslationTile({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
    required super.onRollback,
  });
}

class SelectTranslationTile
    extends TranslationWithParameterTile<ArbSelectDefinition, ArbSelectTranslation> {
  SelectTranslationTile({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.isOriginal,
    required super.onEdit,
    required super.onRollback,
    required this.knownCases,
  });

  final Set<String> knownCases;

  @override
  ArbSelectTranslationBuilder get builder => super.builder as ArbSelectTranslationBuilder;

  @override
  Widget build(BuildContext context) {
    builder.knownCases = knownCases;
    return super.build(context);
  }
}

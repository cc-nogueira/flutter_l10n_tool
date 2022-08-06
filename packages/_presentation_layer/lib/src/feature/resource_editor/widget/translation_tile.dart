import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/form_mixin.dart';
import '../builder/arb_builder.dart';

abstract class BasicTranslationTile<D extends ArbDefinition> extends StatelessWidget {
  const BasicTranslationTile({
    super.key,
    required this.displayOption,
    required this.locale,
    required this.definition,
    required this.builder,
    required this.onEdit,
  });

  final DisplayOption displayOption;
  final String locale;
  final D definition;
  final ArbTranslationBuilderBase builder;
  final VoidCallback? onEdit;

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
        Column(children: builder.tileLeadingIcons()),
        ArbBuilder.leadingSeparator,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              builder.tileTitle(
                title: Text(locale, style: builder.titleStyle),
                subtitle: builder.descriptorWidget(),
              ),
              if (content != null) content,
            ],
          ),
        ),
        ArbBuilder.leadingSeparator,
        Column(children: tileTrailingIcons(context))
      ],
    );
  }

  List<Widget> tileTrailingIcons(BuildContext context);

  Widget? tileContent(TextTheme theme, ColorScheme colors) => null;

  Widget editButton() => IconButton(icon: const Icon(Icons.edit), iconSize: 20, onPressed: onEdit);
}

class MissingTranslationTile extends BasicTranslationTile<ArbDefinition> {
  MissingTranslationTile({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.definition,
    required super.onEdit,
  }) : super(
          builder: ArbMissingTranslationBuilder(
            displayOption: displayOption,
            definition: definition,
          ),
        );

  @override
  List<Widget> tileTrailingIcons(BuildContext context) {
    return <Widget>[editButton()];
  }
}

abstract class TranslationTile<D extends ArbDefinition, T extends ArbTranslation>
    extends BasicTranslationTile<D> {
  TranslationTile({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.definition,
    required super.onEdit,
    required this.translation,
    required this.isOriginal,
    required this.onRollback,
  }) : super(
          builder: ArbTranslationBuilder.forArgs(
            displayOption: displayOption,
            definition: definition,
            translation: translation,
          ),
        );

  @override
  ArbTranslationBuilder get builder => super.builder as ArbTranslationBuilder;

  final T translation;
  final bool isOriginal;
  final VoidCallback onRollback;

  @override
  List<Widget> tileTrailingIcons(BuildContext context) {
    return <Widget>[
      if (!isOriginal) _rollbackButton(context),
      editButton(),
    ];
  }

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

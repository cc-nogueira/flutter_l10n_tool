import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import 'translation_tile_mixin.dart';

abstract class TranslationTile<T extends ArbDefinition> extends StatelessWidget
    with TranslationTileMixin {
  const TranslationTile({
    super.key,
    required this.displayOption,
    required this.locale,
    required this.translation,
    required this.definition,
    required this.onEdit,
  });

  final DisplayOption displayOption;
  final String locale;
  final ArbTranslation? translation;
  final T definition;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = tileContent(theme.textTheme, theme.colorScheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tileTitle(theme.textTheme, title: locale, subtitle: subtitle, trailing: titleTrailing),
        if (content != null) content,
      ],
    );
  }

  String? get subtitle => null;

  Widget get titleTrailing =>
      IconButton(icon: const Icon(Icons.edit), iconSize: 20, onPressed: onEdit);

  Widget? tileContent(TextTheme theme, ColorScheme colors) => null;
}

class TextTranslationTile extends TranslationTile<ArbPlaceholdersDefinition> {
  const TextTranslationTile({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.onEdit,
  });

  @override
  String? get subtitle => translation?.value;
}

class PluralTranslationTile extends TranslationTile<ArbPluralDefinition> {
  const PluralTranslationTile({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.onEdit,
  });
}

class SelectTranslationTile extends TranslationTile<ArbSelectDefinition> with ArbMixin {
  const SelectTranslationTile({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.onEdit,
  });

  @override
  String? get subtitle => displayOption.isCompact ? translation?.value : null;

  @override
  Widget? tileContent(TextTheme theme, ColorScheme colors) {
    if (displayOption.isCompact) {
      return null;
    }
    final mStyle = markingStyle(theme);
    final vStyle = valueStyle(theme);
    final oStyle = optionStyle(theme, colors);
    return Padding(
      padding: const EdgeInsets.only(
        left: TranslationTileMixin.leadingSize + TranslationTileMixin.leadingSeparation,
        right: TranslationTileMixin.leadingSize,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('{ ', style: mStyle),
            Text(definition.placeholder, style: vStyle),
            Text(', ', style: mStyle),
            Text('select', style: oStyle),
            Text(', ', style: mStyle),
            Text('...', style: vStyle),
            Text(' }', style: mStyle),
          ]),
          const SizedBox(height: 8),
          ...options(theme, colors),
        ],
      ),
    );
  }

  List<Widget> options(TextTheme theme, ColorScheme colors) {
    final mStyle = markingStyle(theme);
    final vStyle = valueStyle(theme);
    final oStyle = optionStyle(theme, colors);
    final value = translation?.value ?? '';
    const hSpace = SizedBox(width: 4);
    if (value.trim().isEmpty) {
      return const [Text('empty')];
    }
    final options = inferArbOptionsFrom(ArbDefinitionType.select, value);
    return [
      for (final option in options.entries)
        Row(children: [
          const Icon(
            Icons.swap_horiz,
            size: 20,
          ),
          hSpace,
          Text(option.key, style: vStyle),
          Text('{', style: mStyle),
          hSpace,
          Text(option.value, style: oStyle),
          hSpace,
          Text('}', style: mStyle),
        ]),
    ];
  }
}

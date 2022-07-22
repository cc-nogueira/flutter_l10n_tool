part of 'arb_builder.dart';

mixin ArbTranslationBuilderMixin {
  static const tileIcon = SizedBox(
      width: ArbBuilder.leadingSize,
      height: ArbBuilder.leadingSize,
      child: Center(child: Icon(Icons.translate)));

  Widget tileTitle({required Widget title, Widget? subtitle, required Widget trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
            width: ArbBuilder.leadingSize,
            height: ArbBuilder.leadingSize,
            child: Center(child: tileIcon)),
        ArbBuilder.leadingSeparator,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              if (subtitle != null) subtitle,
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

abstract class ArbTranslationBuilder extends ArbBuilder with ArbTranslationBuilderMixin {
  factory ArbTranslationBuilder({
    required DisplayOption displayOption,
    required ArbDefinition definition,
    required ArbTranslation translation,
  }) {
    return translation.maybeMap(
        placeholders: (trans) => _ArbPlaceholdersTranslationBuilder(
              displayOption: displayOption,
              definition: definition as ArbPlaceholdersDefinition,
              translation: trans,
            ),
        orElse: () => _ArbTranslationWithParameterBuilder(
              displayOption: displayOption,
              definition: definition,
              translation: translation,
            ));
  }

  ArbTranslationBuilder._({
    required this.displayOption,
    required this.definition,
    required this.translation,
  });

  final DisplayOption displayOption;
  final ArbDefinition definition;
  final ArbTranslation translation;

  Widget descriptorWidget();
  List<Widget> optionsWidgets() => [];
}

class _ArbPlaceholdersTranslationBuilder extends ArbTranslationBuilder {
  _ArbPlaceholdersTranslationBuilder({
    required super.displayOption,
    required ArbPlaceholdersDefinition definition,
    required ArbPlaceholdersTranslation translation,
  }) : super._(definition: definition, translation: translation);

  @override
  ArbPlaceholdersTranslation get translation => super.translation as ArbPlaceholdersTranslation;

  @override
  ArbPlaceholdersDefinition get definition => super.definition as ArbPlaceholdersDefinition;

  @override
  Widget descriptorWidget() {
    if (translation.placeholderNames.isNotEmpty) {
      final namesBuffer = StringBuffer();
      for (final name in translation.placeholderNames) {
        namesBuffer
          ..write('{')
          ..write(name)
          ..write('}|');
      }
      final names = namesBuffer.toString().substring(0, namesBuffer.length - 1);
      final rx = RegExp('(.*?)($names)');
      final matches = rx.allMatches(translation.value);
      if (matches.isNotEmpty) {
        final validPlaceholders = {
          for (final ph in definition.placeholders) '{${ph.key}}',
        };
        final children = <InlineSpan>[];
        for (final match in matches) {
          if (match.group(1)!.isNotEmpty) {
            children.add(TextSpan(text: match.group(1)!, style: subtitleStyle));
          }
          final placeholder = match.group(2)!;
          final style = validPlaceholders.contains(placeholder) ? optionStyle : invalidOptionStyle;
          children.add(TextSpan(text: placeholder, style: style));
        }
        final idx = matches.last.end;
        if (idx < translation.value.length) {
          children.add(TextSpan(text: translation.value.substring(idx), style: subtitleStyle));
        }
        final textSpan = TextSpan(children: children);
        return SelectableText.rich(textSpan);
      }
    }
    return SelectableText(translation.value, style: subtitleStyle);
  }
}

class _ArbTranslationWithParameterBuilder extends ArbTranslationBuilder {
  _ArbTranslationWithParameterBuilder({
    required super.translation,
    required super.definition,
    required super.displayOption,
  })  : assert(definition is ArbDefinitionWithParameter),
        assert(translation is ArbTranslationWithParameter),
        super._();

  static const hSpace = SizedBox(width: 4);

  ArbTranslationWithParameter get transWithParam => translation as ArbTranslationWithParameter;

  @override
  Widget descriptorWidget() {
    return Wrap(
      children: [
        if (transWithParam.prefix.isNotEmpty) Text(transWithParam.prefix, style: subtitleStyle),
        Text('{ ', style: markingStyle),
        Text(transWithParam.parameterName.ifEmpty('??'), style: valueStyle),
        Text(', ', style: markingStyle),
        Text(translation.type.name, style: optionStyle),
        Text(', ', style: markingStyle),
        Text('...', style: valueStyle),
        Text(' }', style: markingStyle),
        if (transWithParam.suffix.isNotEmpty) Text(transWithParam.suffix, style: subtitleStyle),
      ],
    );
  }

  @override
  List<Widget> optionsWidgets() {
    if (transWithParam.options.isEmpty) {
      return const [Text('empty')];
    }
    final options = [
      for (final option in transWithParam.options.entries)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (displayOption.isExpanded) ...[
              const Icon(Icons.swap_horiz, size: 20),
              hSpace,
            ],
            Text(option.key, style: valueStyle),
            Text('{', style: markingStyle),
            hSpace,
            Text(option.value, style: optionStyle),
            hSpace,
            Text('}', style: markingStyle),
          ],
        ),
    ];
    if (displayOption.isExpanded) {
      return options;
    } else {
      final optionsWithSpaces = [
        for (final option in options) ...[option, hSpace],
      ];
      return [Wrap(children: optionsWithSpaces)];
    }
  }
}

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
    return translation.map(
      placeholders: (trans) => _ArbPlaceholdersTranslationBuilder(
        displayOption: displayOption,
        definition: definition as ArbPlaceholdersDefinition,
        translation: trans,
      ),
      plural: (trans) => ArbPluralTranslationBuilder(
        displayOption: displayOption,
        definition: definition as ArbPluralDefinition,
        translation: trans,
      ),
      select: (trans) => ArbSelectTranslationBuilder(
        displayOption: displayOption,
        translation: trans,
        definition: definition as ArbSelectDefinition,
      ),
    );
  }

  ArbTranslationBuilder._({
    required this.displayOption,
    required this.definition,
    required this.translation,
  });

  final DisplayOption displayOption;
  final ArbDefinition definition;
  ArbTranslation translation;

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
      final rx = RegExp('([\\s\\S]*?)($names)');
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
        return SelectableText.rich(textSpan, maxLines: null);
      }
    }
    return SelectableText(
      translation.value,
      style: subtitleStyle,
      maxLines: null,
    );
  }
}

abstract class _ArbTranslationWithParameterBuilder extends ArbTranslationBuilder {
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
      runSpacing: 12.0,
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

  List<Widget> _optionsWidgets(List<Widget> options) {
    if (options.isEmpty) {
      return const [Text('empty')];
    }

    if (displayOption.isExpanded) {
      return options;
    } else {
      final optionsWithSpaces = [
        for (final option in options) ...[option, _ArbTranslationWithParameterBuilder.hSpace],
      ];
      return [Wrap(runSpacing: 12.0, children: optionsWithSpaces)];
    }
  }

  Widget _arbOptionWidget(String name, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (displayOption.isExpanded) ...[
          const Icon(Icons.swap_horiz, size: 20),
          hSpace,
        ],
        Text(name, style: valueStyle),
        Text('{', style: markingStyle),
        hSpace,
        Text(value, style: optionStyle),
        hSpace,
        Text('}', style: markingStyle),
      ],
    );
  }
}

class ArbPluralTranslationBuilder extends _ArbTranslationWithParameterBuilder {
  ArbPluralTranslationBuilder({
    required ArbPluralTranslation translation,
    required ArbPluralDefinition definition,
    required super.displayOption,
  }) : super(translation: translation, definition: definition);

  @override
  ArbPluralTranslation get translation => super.translation as ArbPluralTranslation;

  @override
  List<Widget> optionsWidgets() => _optionsWidgets([
        for (final option in translation.options) arbOptionWidget(option),
      ]);

  Widget arbOptionWidget(ArbPlural plural) => _arbOptionWidget(plural.option.name, plural.value);
}

class ArbSelectTranslationBuilder extends _ArbTranslationWithParameterBuilder {
  ArbSelectTranslationBuilder({
    required ArbSelectTranslation translation,
    required ArbSelectDefinition definition,
    required super.displayOption,
  }) : super(translation: translation, definition: definition);

  @override
  ArbSelectTranslation get translation => super.translation as ArbSelectTranslation;

  @override
  List<Widget> optionsWidgets() => _optionsWidgets([
        for (final option in translation.options) arbOptionWidget(option),
      ]);

  Widget arbOptionWidget(ArbSelection selection) =>
      _arbOptionWidget(selection.option, selection.value);
}

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
    required ArbTranslation translation,
  }) {
    return translation.maybeMap(
        placeholders: (trans) => _ArbPlaceholdersTranslationBuilder(
              displayOption: displayOption,
              translation: trans,
            ),
        orElse: () => _ArbTranslationWithParameterBuilder(
              displayOption: displayOption,
              translation: translation,
            ));
  }

  ArbTranslationBuilder._({required this.displayOption, required this.translation});

  final DisplayOption displayOption;
  final ArbTranslation translation;

  Widget descriptorWidget();
  List<Widget> optionsWidgets() => [];
}

class _ArbPlaceholdersTranslationBuilder extends ArbTranslationBuilder {
  _ArbPlaceholdersTranslationBuilder({
    required super.displayOption,
    required ArbPlaceholdersTranslation translation,
  }) : super._(translation: translation);

  @override
  Widget descriptorWidget() {
    return const Text('TODO');
  }
}

class _ArbTranslationWithParameterBuilder extends ArbTranslationBuilder {
  _ArbTranslationWithParameterBuilder({
    required super.translation,
    required super.displayOption,
  })  : assert(translation is ArbTranslationWithParameter),
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

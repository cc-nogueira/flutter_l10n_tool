part of 'arb_builder.dart';

/// This mixin externalize common functionality used by separate hierarchies.
///
/// Used by [ArbTranslationBuilder] and [MissingTranslationTile].
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

/// Translation builders are usually instantiated with this class factory constructor.
///
/// The factory constructor will deliver the proper ArbTranslationBuilder sublass implementation.
/// It is expected that provided implementatios of ArbDefinition ArbTranslation do match.
abstract class ArbTranslationBuilder extends ArbBuilder with ArbTranslationBuilderMixin {
  /// Factory constructor to instantiate the corresponding builder for the given translation type.
  ///
  /// Required that [definition] and [translation] are of the same type.
  factory ArbTranslationBuilder({
    required DisplayOption displayOption,
    required ArbDefinition definition,
    required ArbTranslation translation,
  }) {
    assert(definition.type == translation.type);
    return translation.map(
      placeholders: (trans) => ArbPlaceholdersTranslationBuilder(
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

  /// Private constructor
  ArbTranslationBuilder._({
    required this.displayOption,
    required this.definition,
    required this.translation,
  });

  /// Current display option ([DisplayOption.compact] or [DisplayOption.expanded]).
  final DisplayOption displayOption;

  /// Arb definition (final)
  final ArbDefinition definition;

  /// Arb translation may be updated during the lifetime of this builder.
  ArbTranslation translation;

  /// API for sublasses to display a descriptor to present the translation in a tile.
  Widget descriptorWidget();

  /// Options are only meaninful for [ArbPluralTranslation] and [ArbSelectTranslation].
  List<Widget> optionsWidgets() => [];
}

/// Widget builder for [ArbPlaceholdersTranslation].
///
/// Defines the [descriptorWidget] for this specific type of translation.
class ArbPlaceholdersTranslationBuilder extends ArbTranslationBuilder {
  /// Constructor usually used by the super class factory.
  ArbPlaceholdersTranslationBuilder({
    required super.displayOption,
    required ArbPlaceholdersDefinition definition,
    required ArbPlaceholdersTranslation translation,
  }) : super._(definition: definition, translation: translation);

  @override
  ArbPlaceholdersTranslation get translation => super.translation as ArbPlaceholdersTranslation;

  @override
  ArbPlaceholdersDefinition get definition => super.definition as ArbPlaceholdersDefinition;

  /// Generate the SelectableText widget with [ArbBuilder.subtitleStyle] and corolized placeholders.
  ///
  /// Valid placeholders are painted with [ArbBuilder.optionStyle] and invalid ones with
  /// [ArbBuilder.invalidOptionStyle].
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

/// Common Abstract class for builders with parameters [ArbPluralTranslation] and [ArbSelectTranslation].
///
/// Defines the [descriptorWidget] for sublasses and common layout for plurals and select options.
abstract class _ArbTranslationWithParameterBuilder extends ArbTranslationBuilder {
  _ArbTranslationWithParameterBuilder({
    required super.translation,
    required super.definition,
    required super.displayOption,
  })  : assert(definition is ArbDefinitionWithParameter),
        assert(translation is ArbTranslationWithParameter),
        super._();

  /// Horizonta spacing constant
  static const hSpace = SizedBox(width: 4);

  /// Getter to return the common interface (mixin) of Plural and Select translations.
  ArbTranslationWithParameter get transWithParam => translation as ArbTranslationWithParameter;

  ArbDefinitionWithParameter get defWithParam => definition as ArbDefinitionWithParameter;

  /// Generate the translation type string representation widget with colored segments.
  @override
  Widget descriptorWidget() {
    final paramName = transWithParam.parameterName;
    final paramNameOK = paramName == defWithParam.parameterName;
    final paramStyle = paramNameOK ? valueStyle : warningStyle;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 42.0,
      children: [
        if (transWithParam.prefix.isNotEmpty) Text(transWithParam.prefix, style: subtitleStyle),
        Text('{ ', style: markingStyle),
        Text(transWithParam.parameterName.ifEmpty('??'), style: paramStyle),
        Text(', ', style: markingStyle),
        Text(translation.type.name, style: optionStyle),
        Text(', ', style: markingStyle),
        Text('...', style: valueStyle),
        Text(' }', style: markingStyle),
        if (transWithParam.suffix.isNotEmpty) Text(transWithParam.suffix, style: subtitleStyle),
        if (!paramNameOK)
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              message: 'Current param name does not match param definition.\n'
                  'This does not break Flutter L10N generation.\n'
                  'It may be be fixed on file generation (configurable in options).',
              child: Icon(Icons.error_outline, size: 20, color: Colors.amber),
            ),
          ),
      ],
    );
  }

  /// Private helper method to layout sublass list of options.
  ///
  /// Returns a Wrap with all options.
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

  /// Private helper method to layout each sublass option.
  ///
  /// Returns a SelectableText colorized with [ArbBuilder] styles.
  Widget _arbOptionWidget(String name, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (displayOption.isExpanded) ...[
          const Icon(Icons.swap_horiz, size: 20),
          hSpace,
        ],
        SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(text: name, style: valueStyle),
              TextSpan(text: '{', style: markingStyle),
              TextSpan(text: value, style: optionStyle),
              TextSpan(text: '}', style: markingStyle),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget builder for [ArbPluralTranslation].
///
/// Defines optionsWidgets using the common superclass layout methods.
class ArbPluralTranslationBuilder extends _ArbTranslationWithParameterBuilder {
  /// Constructor usually used by the super class factory.
  ArbPluralTranslationBuilder({
    required ArbPluralTranslation translation,
    required ArbPluralDefinition definition,
    required super.displayOption,
  }) : super(translation: translation, definition: definition);

  @override
  ArbPluralTranslation get translation => super.translation as ArbPluralTranslation;

  /// Generate option widgets for this type of translation using the common superclass layout methods.
  @override
  List<Widget> optionsWidgets() => _optionsWidgets([
        for (final option in translation.options) arbOptionWidget(option),
      ]);

  /// Generate the widget for one plural argument using common superclass layout method.
  Widget arbOptionWidget(ArbPlural plural) => _arbOptionWidget(plural.option.name, plural.value);
}

/// Widget builder for [ArbSelectTranslation].
///
/// Defines optionsWidgets using the common superclass layout methods.
class ArbSelectTranslationBuilder extends _ArbTranslationWithParameterBuilder {
  /// Constructor usually used by the super class factory.
  ArbSelectTranslationBuilder({
    required ArbSelectTranslation translation,
    required ArbSelectDefinition definition,
    required super.displayOption,
  }) : super(translation: translation, definition: definition);

  @override
  ArbSelectTranslation get translation => super.translation as ArbSelectTranslation;

  /// Generate option widgets for this type of translation using the common superclass layout methods.
  @override
  List<Widget> optionsWidgets() => _optionsWidgets([
        for (final option in translation.options) arbOptionWidget(option),
      ]);

  /// Generate the widget for one selection argument using common superclass layout method.
  Widget arbOptionWidget(ArbSelection selection) =>
      _arbOptionWidget(selection.option, selection.value);
}

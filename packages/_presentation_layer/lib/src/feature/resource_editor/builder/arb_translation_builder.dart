part of 'arb_builder.dart';

abstract class ArbTranslationBuilderBase<D extends ArbDefinition> extends ArbBuilder {
  ArbTranslationBuilderBase({required this.displayOption, required this.definition});

  static const tileIcon = SizedBox(
      width: ArbBuilder.leadingSize,
      height: ArbBuilder.leadingSize,
      child: Center(child: Icon(Icons.translate)));

  /// Current display option ([DisplayOption.compact] or [DisplayOption.expanded]).
  final DisplayOption displayOption;

  /// Arb definition (final)
  final D definition;

  List<Widget> tileLeadingIcons() {
    return <Widget>[tileIcon];
  }

  Widget tileTitle({required Widget title, Widget? subtitle, Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              if (subtitle != null) subtitle,
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  /// API for sublasses to display a descriptor to present the translation in a tile.
  Widget descriptorWidget();
}

class ArbMissingTranslationBuilder extends ArbTranslationBuilderBase<ArbDefinition> {
  ArbMissingTranslationBuilder({required super.displayOption, required super.definition});

  static const missingTranslationIcon = SizedBox(
      width: ArbBuilder.leadingSize,
      height: ArbBuilder.leadingSize,
      child: Center(child: Icon(Icons.warning_amber, color: Colors.amberAccent)));

  @override
  List<Widget> tileLeadingIcons() {
    return const [
      IconTheme(
        data: IconThemeData(color: Colors.amberAccent),
        child: ArbTranslationBuilderBase.tileIcon,
      )
    ];
  }

  @override
  Widget descriptorWidget() =>
      Text('Missing translation', style: textTheme.bodyMedium!.copyWith(color: Colors.amberAccent));
}

/// Translation builders are usually instantiated with this class factory constructor.
///
/// The factory constructor will deliver the proper ArbTranslationBuilder sublass implementation.
/// It is expected that provided implementatios of ArbDefinition ArbTranslation do match.
abstract class ArbTranslationBuilder<D extends ArbDefinition, T extends ArbTranslation>
    extends ArbTranslationBuilderBase<D> {
  /// Constructor
  ArbTranslationBuilder({
    required super.displayOption,
    required super.definition,
    required this.translation,
  });

  /// Static method like a factory constructor to instantiate the corresponding builder for the
  /// given translation type.
  ///
  /// Required that [definition] and [translation] are of the same type.
  static ArbTranslationBuilder forArgs<D extends ArbDefinition, T extends ArbTranslation>({
    required DisplayOption displayOption,
    required D definition,
    required T translation,
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

  /// Arb translation may be updated during the lifetime of this builder.
  T translation;

  /// Options are only meaninful for [ArbPluralTranslation] and [ArbSelectTranslation].
  List<Widget> optionsWidgets() => [];
}

/// Widget builder for [ArbPlaceholdersTranslation].
///
/// Defines the [descriptorWidget] for this specific type of translation.
class ArbPlaceholdersTranslationBuilder
    extends ArbTranslationBuilder<ArbPlaceholdersDefinition, ArbPlaceholdersTranslation> {
  /// Constructor usually used by the super class static method.
  ArbPlaceholdersTranslationBuilder({
    required super.displayOption,
    required super.definition,
    required super.translation,
  });

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
abstract class _ArbTranslationWithParameterBuilder<D extends ArbDefinitionWithParameter,
    T extends ArbTranslationWithParameter> extends ArbTranslationBuilder<D, T> {
  _ArbTranslationWithParameterBuilder({
    required super.displayOption,
    required super.definition,
    required super.translation,
  });

  /// Horizonta spacing constant
  static const hSpace = SizedBox(width: 4);

  /// Generate the translation type string representation widget with colored segments.
  @override
  Widget descriptorWidget() {
    final paramName = translation.parameterName;
    final paramNameOK = paramName == definition.parameterName;
    final paramStyle = paramNameOK ? valueStyle : warningStyle;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 42.0,
      children: [
        if (translation.prefix.isNotEmpty) Text(translation.prefix, style: subtitleStyle),
        Text('{ ', style: markingStyle),
        Text(translation.parameterName.ifEmpty('??'), style: paramStyle),
        Text(', ', style: markingStyle),
        Text(translation.type.name, style: optionStyle),
        Text(', ', style: markingStyle),
        Text('...', style: valueStyle),
        Text(' }', style: markingStyle),
        if (translation.suffix.isNotEmpty) Text(translation.suffix, style: subtitleStyle),
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
  /// Returns a colorized text with [ArbBuilder] styles.
  Widget _arbOptionWidget(String name, String value, {bool missing = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (displayOption.isExpanded) ...[
          const Icon(Icons.swap_horiz, size: 20),
          hSpace,
        ],
        Text(name, style: missing ? warningStyle : valueStyle),
        Text('{', style: markingStyle),
        Text(value, style: missing ? invalidOptionStyle : optionStyle),
        Text('}', style: markingStyle),
      ],
    );
  }
}

/// Widget builder for [ArbPluralTranslation].
///
/// Defines optionsWidgets using the common superclass layout methods.
class ArbPluralTranslationBuilder
    extends _ArbTranslationWithParameterBuilder<ArbPluralDefinition, ArbPluralTranslation> {
  /// Constructor usually used by the super static method.
  ArbPluralTranslationBuilder({
    required super.displayOption,
    required super.definition,
    required super.translation,
  });

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
class ArbSelectTranslationBuilder
    extends _ArbTranslationWithParameterBuilder<ArbSelectDefinition, ArbSelectTranslation> {
  /// Constructor usually used by the super class static method.
  ArbSelectTranslationBuilder({
    required super.definition,
    required super.translation,
    required super.displayOption,
  });

  var knownCases = <String>{};

  static const missingCasesIcon = SizedBox(
      width: ArbBuilder.leadingSize,
      height: ArbBuilder.leadingSize,
      child: Center(child: Icon(Icons.warning_amber, color: Colors.amberAccent)));

  @override
  List<Widget> tileLeadingIcons() {
    if (hasMissingCases) {
      return [
        ...super.tileLeadingIcons(),
        const Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          message: 'Missing select cases.',
          child: missingCasesIcon,
        ),
      ];
    }
    return super.tileLeadingIcons();
  }

  bool get hasMissingCases => missingCases(onlyDetect: true).isNotEmpty;

  Set<String> missingCases({bool onlyDetect = false}) {
    final missing = <String>{};
    if (knownCases.isEmpty) {
      return missing;
    }
    final existingCases = <String>{};
    for (final arbSelect in translation.options) {
      existingCases.add(arbSelect.option);
    }
    for (final known in knownCases) {
      if (!existingCases.contains(known)) {
        missing.add(known);
        if (onlyDetect) {
          return missing;
        }
      }
    }
    return missing;
  }

  /// Generate option widgets for this type of translation using the common superclass layout methods.
  @override
  List<Widget> optionsWidgets() => _optionsWidgets([
        for (final option in translation.options) arbOptionWidget(option),
        for (final missing in missingCases()) _arbOptionWidget(missing, 'missing', missing: true),
      ]);

  /// Generate the widget for one selection argument using common superclass layout method.
  Widget arbOptionWidget(ArbSelectCase selection) =>
      _arbOptionWidget(selection.option, selection.value);
}

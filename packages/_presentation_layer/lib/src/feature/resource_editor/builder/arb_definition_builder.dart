part of 'arb_builder.dart';

abstract class ArbDefinitionBuilder extends ArbBuilder {
  factory ArbDefinitionBuilder({
    required DisplayOption displayOption,
    required ArbDefinition definition,
  }) {
    return definition.maybeMap(
        placeholders: (def) => _ArbPlaceholdersDefinitionBuilder(
              displayOption: displayOption,
              definition: def,
            ),
        orElse: () => _ArbDefinitionWithParameterBuilder(
              displayOption: displayOption,
              definition: definition,
            ));
  }

  ArbDefinitionBuilder._({required this.displayOption, required this.definition});

  static const tileIcon = SizedBox(
      width: ArbBuilder.leadingSize,
      height: ArbBuilder.leadingSize,
      child: Center(child: Icon(Icons.key)));

  final DisplayOption displayOption;
  ArbDefinition definition;

  Widget descriptorWidget();

  Widget definitionTile({
    CrossAxisAlignment align = CrossAxisAlignment.center,
    required Widget content,
    required Widget trailing,
  }) {
    return Row(
      crossAxisAlignment: align,
      children: [
        tileIcon,
        ArbBuilder.leadingSeparator,
        Expanded(child: content),
        trailing,
      ],
    );
  }
}

class _ArbPlaceholdersDefinitionBuilder extends ArbDefinitionBuilder {
  _ArbPlaceholdersDefinitionBuilder({
    required super.displayOption,
    required ArbPlaceholdersDefinition definition,
  }) : super._(definition: definition);

  @override
  Widget descriptorWidget() {
    return const Text('TODO');
  }
}

class _ArbDefinitionWithParameterBuilder extends ArbDefinitionBuilder {
  _ArbDefinitionWithParameterBuilder({
    required super.displayOption,
    required super.definition,
  })  : assert(definition is ArbDefinitionWithParameter),
        super._();

  ArbDefinitionWithParameter get defWithParameter => definition as ArbDefinitionWithParameter;

  @override
  Widget descriptorWidget() {
    return Row(children: [
      Text('{ ', style: markingStyle),
      Text(defWithParameter.parameterName.ifEmpty('??'), style: valueStyle),
      Text(', ', style: markingStyle),
      Text(definition.type.name, style: optionStyle),
      Text(', ', style: markingStyle),
      Text('...', style: valueStyle),
      Text(' }', style: markingStyle),
    ]);
  }
}

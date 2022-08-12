import 'package:_core_layer/string_utils.dart';
import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import 'arb_builder.dart';

class ArbDefinitionBuilder extends ArbBuilder {
  ArbDefinitionBuilder({this.definition});

  factory ArbDefinitionBuilder.of({required ArbDefinition definition}) {
    return definition.map(
      placeholders: (def) => ArbDefinitionBuilder(),
      plural: (def) => ArbDefinitionWithParameterBuilder(definition: def),
      select: (def) => ArbDefinitionWithParameterBuilder(definition: def),
    );
  }

  static const tileIcon = SizedBox(
      width: ArbBuilder.leadingSize,
      height: ArbBuilder.leadingSize,
      child: Center(child: Icon(Icons.key)));

  ArbDefinition? definition;

  Widget descriptorWidget() => Container();

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

class ArbDefinitionWithParameterBuilder extends ArbDefinitionBuilder {
  ArbDefinitionWithParameterBuilder({
    required ArbDefinitionWithParameter definition,
  }) : super(definition: definition);

  ArbDefinitionWithParameter get defWithParam => super.definition as ArbDefinitionWithParameter;

  @override
  Widget descriptorWidget() {
    return Row(children: [
      Text('{ ', style: markingStyle),
      Text(defWithParam.parameterName.ifEmpty('??'), style: valueStyle),
      Text(', ', style: markingStyle),
      Text(defWithParam.type.name, style: optionStyle),
      Text(', ', style: markingStyle),
      Text('...', style: valueStyle),
      Text(' }', style: markingStyle),
    ]);
  }
}

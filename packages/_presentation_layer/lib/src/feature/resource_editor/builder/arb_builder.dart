import 'package:_core_layer/string_utils.dart';
import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

part 'arb_definition_builder.dart';
part 'arb_translation_builder.dart';

class ArbBuilder {
  ArbBuilder();

  static const leadingSize = 40.0;
  static const leadingSeparation = 12.0;
  static const leadingSeparator = SizedBox(width: leadingSeparation);

  bool _initPending = true;
  late final TextTheme textTheme;
  late final ColorScheme colors;

  void init(BuildContext context) {
    if (_initPending) {
      textTheme = Theme.of(context).textTheme;
      colors = Theme.of(context).colorScheme;
      _initPending = false;
    }
  }

  TextStyle get titleStyle => textTheme.titleMedium!;
  TextStyle get subtitleStyle => textTheme.bodyMedium!.copyWith(color: textTheme.caption?.color);
  TextStyle get markingStyle => subtitleStyle;
  TextStyle get valueStyle => textTheme.bodyMedium!;
  TextStyle get optionStyle => textTheme.bodyMedium!.copyWith(color: colors.primary);
}

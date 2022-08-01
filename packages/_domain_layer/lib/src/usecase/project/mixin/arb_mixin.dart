import 'package:tuple/tuple.dart';

import '../../../entity/arb/arb_definition.dart';
import '../../../entity/arb/arb_translation.dart';

mixin ArbMixin {
  static final _pluralRegExp =
      RegExp(r'([^{]*)({\s*([a-zA-Z]\w*)\s*,\s*plural\s*,([\s\S]*}))([^}]*)');
  static final _pluralOptionsRegExp = RegExp(r'(=0|=1|=2|few|many|other){([^}]*)}');
  static final _selectRegExp =
      RegExp(r'([^{]*)({\s*([a-zA-Z]\w*)\s*,\s*select\s*,([\s\S]*)})([^}]*)');
  static final _selectOptionsRegExp = RegExp(r'([a-zA-Z]\w*){([^}]*)}');
  static final _placeholderNamesRegExp = RegExp(r'{([a-zA-Z]\w*)}');

  RegExp _translationRegExpFor(ArbDefinitionType type) {
    if (type.isPlural) return _pluralRegExp;
    if (type.isSelect) return _selectRegExp;
    throw ArgumentError('Expecting a Plural or Select ArbDefinition.');
  }

  ArbDefinitionType arbDefinitionTypeForValue(String value) {
    if (_pluralRegExp.hasMatch(value)) {
      return ArbDefinitionType.plural;
    }
    if (_selectRegExp.hasMatch(value)) {
      return ArbDefinitionType.select;
    }
    return ArbDefinitionType.placeholders;
  }

  List<String> arbTranslationPlaceholderNames(String value) {
    final matches = _placeholderNamesRegExp.allMatches(value);
    return [
      for (final each in matches) each.group(1)!,
    ];
  }

  Tuple4 arbTranslationExpressionParameterPrefixAndSuffix(ArbDefinitionType type, String value) {
    final rx = _translationRegExpFor(type);
    final match = rx.firstMatch(value);
    if (match == null) {
      throw ArgumentError('Invalid value "$value" for ArbDefinition of type $type');
    }
    return Tuple4(match.group(2)!, match.group(3)!, match.group(1)!, match.group(5)!);
  }

  String arbTranslationParameterName(ArbDefinitionType type, String value) {
    final rx = _translationRegExpFor(type);
    final match = rx.firstMatch(value);
    if (match == null) {
      throw ArgumentError('Invalid value "$value" for ArbDefinition of type $type');
    }
    return match.group(3)!;
  }

  List<ArbPlural> inferArbTranslationPluralOptions(String value) {
    final match = _pluralRegExp.firstMatch(value);
    if (match == null) {
      throw ArgumentError('Invalid value "$value" for ArbPluralTranslation');
    }
    final options = match.group(4)!;
    final optionsRegExp = _pluralOptionsRegExp;
    final matches = optionsRegExp.allMatches(options);
    return [
      for (final each in matches)
        ArbPlural(option: ArbPluralOption.forExpression(each.group(1)!), value: each.group(2)!),
    ];
  }

  List<ArbSelection> inferArbTranslationSelectOptions(String value) {
    final match = _selectRegExp.firstMatch(value);
    if (match == null) {
      throw ArgumentError('Invalid value "$value" for ArbSelectTranslation');
    }
    final options = match.group(4)!;
    final optionsRegExp = _selectOptionsRegExp;
    final matches = optionsRegExp.allMatches(options);
    return [
      for (final each in matches) ArbSelection(option: each.group(1)!, value: each.group(2)!),
    ];
  }

  String? arbTranslationParameter(ArbDefinitionType type, String value) {
    final rx = _translationRegExpFor(type);
    final match = rx.firstMatch(value);
    return match?.group(3);
  }
}

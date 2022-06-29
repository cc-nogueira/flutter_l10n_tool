enum ArbDefinitionType {
  plural,
  text,
  select;

  bool get isPlural => this == plural;
  bool get isSelect => this == select;
  bool get isText => this == text;
}

class ArbUtil {
  static final pluralRegExp = RegExp(r'{\s*(\w+)\s*,\s*plural\s*,(.*)}');
  static final selectRegExp = RegExp(r'{\s*(\w+)\s*,\s*select\s*,(.*)}');
  static final optionsRegExp = RegExp(r'(\w+){([^}]*)}');

  static ArbDefinitionType typeForValue(String value) {
    if (pluralRegExp.hasMatch(value)) {
      return ArbDefinitionType.plural;
    }
    if (selectRegExp.hasMatch(value)) {
      return ArbDefinitionType.select;
    }
    return ArbDefinitionType.text;
  }

  static String mainPlaceholder(ArbDefinitionType type, String value) {
    final rx = type.isPlural ? pluralRegExp : (type.isSelect ? selectRegExp : null);
    if (rx == null) {
      throw ArgumentError('There is no main placeholder for ArbDefinition of type $type');
    }
    final match = rx.firstMatch(value);
    if (match == null) {
      throw ArgumentError('Invalid value "$value" for ArbDefinition of type $type');
    }
    return match.group(1)!;
  }

  static Map<String, String> mainOptions(ArbDefinitionType type, String value) {
    final rx = type.isPlural ? pluralRegExp : (type.isSelect ? selectRegExp : null);
    if (rx == null) {
      throw ArgumentError('There is no main options for ArbDefinition of type $type');
    }
    final match = rx.firstMatch(value);
    if (match == null) {
      throw ArgumentError('Invalid value "$value" for ArbDefinition of type $type');
    }
    final content = match.group(2)!;
    final matches = optionsRegExp.allMatches(content);
    return {
      for (final each in matches) each.group(1)!: each.group(2)!,
    };
  }
}

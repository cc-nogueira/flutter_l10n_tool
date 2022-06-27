import '../entity/project/arb_definition.dart';
import '../entity/project/l10n_configuration.dart';
import '../exception/l10n_arb_exception.dart';

class ArbValidator {
  const ArbValidator(this.configuration, {required this.translations, required this.definitions});

  final L10nConfiguration configuration;
  final Map<String, String> translations;
  final Map<String, dynamic> definitions;

  void validate() {
    if (configuration.requiredResourceAttributes) {
      _validateAllResourcesWithDefinitions();
    }
    _validatePluralResources();
    _validateSelectResources();
    _validatePlaceholders();
  }

  void _validateAllResourcesWithDefinitions() {
    for (final key in translations.keys) {
      final definitionKey = '@$key';
      final definition = definitions[definitionKey];
      if (definition == null) {
        throw L10nMissingAnArbDefinitionException(definitionKey);
      }
      if (definition is! Map<String, dynamic>) {
        throw L10nArbDefinitionException(key);
      }
    }
  }

  void _validatePluralResources() {
    for (final entry in translations.entries) {
      final key = pluralKey(entry.value);
      if (key != null) {
        final attributeKey = '@${entry.key}';
        final definition = definitions[attributeKey];
        if (definition == null || definition is! Map<String, dynamic>) {
          throw L10nMissingArbDefinitionException(attributeKey, type: 'plural');
        }
        final placeholders = definition['placeholders'];
        if (placeholders == null) {
          throw L10nMissingPlaceholdersException(entry.key, type: 'plural');
        }
        if (placeholders is! Map<String, dynamic>) {
          throw L10nArbPlaceholdersFormatException(entry.key);
        }
        final placeholder = placeholders[key];
        if (placeholder == null || placeholder is! Map) {
          throw L10nMissingPlaceholderException(
            entry.key,
            type: 'plural',
            placeholderName: key,
          );
        }
      }
    }
  }

  void _validateSelectResources() {
    for (final entry in translations.entries) {
      final key = selectKey(entry.value);
      if (key != null) {
        final attributeKey = '@${entry.key}';
        final definition = definitions[attributeKey];
        if (definition == null || definition is! Map<String, dynamic>) {
          throw L10nMissingArbDefinitionException(attributeKey, type: 'select');
        }
        final placeholders = definition['placeholders'];
        if (placeholders == null) {
          throw L10nMissingPlaceholdersException(entry.key, type: 'select');
        }
        if (placeholders is! Map<String, dynamic>) {
          throw L10nArbPlaceholdersFormatException(entry.key);
        }
        final placeholder = placeholders[key];
        if (placeholder == null || placeholder is! Map) {
          throw L10nMissingPlaceholderException(
            entry.key,
            type: 'select',
            placeholderName: key,
          );
        }
      }
    }
  }

  void _validatePlaceholders() {
    for (final entry in definitions.entries) {
      final placeholders = entry.value['placeholders'];
      if (placeholders != null && placeholders is! Map<String, dynamic>) {
        throw L10nArbPlaceholdersFormatException(entry.key);
      }
    }
  }

  String? pluralKey(String value) {
    final match = ArbDefinition.pluralRegExp.firstMatch(value);
    return match?.group(1);
  }

  String? selectKey(String value) {
    final match = ArbDefinition.selectRegExp.firstMatch(value);
    return match?.group(1);
  }
}

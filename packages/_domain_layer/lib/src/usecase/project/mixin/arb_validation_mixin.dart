import '../../../entity/project/l10n_configuration.dart';
import '../../../exception/l10n_arb_exception.dart';
import 'arb_mixin.dart';

mixin ArbValidationMixin {
  void arbValidation({
    required L10nConfiguration configuration,
    required Map<String, String> translations,
    required Map<String, dynamic> definitions,
  }) {
    if (configuration.requiredResourceAttributes) {
      _validateAllResourcesWithDefinitions(translations: translations, definitions: definitions);
    }
    _validatePluralResources(translations: translations, definitions: definitions);
    _validateSelectResources(translations: translations, definitions: definitions);
    _validatePlaceholders(definitions);
  }

  void _validateAllResourcesWithDefinitions({
    required Map<String, String> translations,
    required Map<String, dynamic> definitions,
  }) {
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

  void _validatePluralResources({
    required Map<String, String> translations,
    required Map<String, dynamic> definitions,
  }) {
    for (final entry in translations.entries) {
      final key = arbPluralKey(entry.value);
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

  void _validateSelectResources({
    required Map<String, String> translations,
    required Map<String, dynamic> definitions,
  }) {
    for (final entry in translations.entries) {
      final key = arbSelectKey(entry.value);
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

  void _validatePlaceholders(Map<String, dynamic> definitions) {
    for (final entry in definitions.entries) {
      final placeholders = entry.value['placeholders'];
      if (placeholders != null && placeholders is! Map<String, dynamic>) {
        throw L10nArbPlaceholdersFormatException(entry.key);
      }
    }
  }

  String? arbPluralKey(String value) {
    final match = ArbMixin.pluralRegExp.firstMatch(value);
    return match?.group(1);
  }

  String? arbSelectKey(String value) {
    final match = ArbMixin.selectRegExp.firstMatch(value);
    return match?.group(1);
  }
}

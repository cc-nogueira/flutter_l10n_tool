import '../../../entity/project/l10n_configuration.dart';
import '../../../exception/l10n_arb_exception.dart';
import 'arb_mixin.dart';

mixin ArbValidationMixin on ArbMixin {
  void arbValidation({
    required L10nConfiguration configuration,
    required Map<String, String> translations,
    required Map<String, dynamic> definitions,
  }) {
    if (configuration.requiredResourceAttributes) {
      _validateAllResourcesWithDefinitions(translations: translations, definitions: definitions);
    }
    _validatePluralAndSelectPlaceholders(translations: translations, definitions: definitions);
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

  void _validatePluralAndSelectPlaceholders({
    required Map<String, String> translations,
    required Map<String, dynamic> definitions,
  }) {
    for (final entry in translations.entries) {
      final type = arbDefinitionTypeForValue(entry.value);
      if (type.isNotPlural && type.isNotSelect) {
        continue;
      }
      final parameter = arbTranslationParameter(type, entry.value);
      if (parameter != null) {
        final attributeKey = '@${entry.key}';
        final definition = definitions[attributeKey];
        if (definition == null || definition is! Map<String, dynamic>) {
          throw L10nMissingArbDefinitionException(attributeKey, type: type.name);
        }
        final placeholders = definition['placeholders'];
        if (placeholders == null) {
          throw L10nMissingPlaceholdersException(entry.key, type: type.name);
        }
        if (placeholders is! Map<String, dynamic>) {
          throw L10nArbPlaceholdersFormatException(entry.key);
        }
        final placeholder = placeholders[parameter];
        if (placeholder == null || placeholder is! Map) {
          throw L10nMissingPlaceholderException(
            entry.key,
            type: type.name,
            placeholderName: parameter,
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
}

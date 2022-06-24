import '../entity/project/arb_resource.dart';
import '../entity/project/l10n_configuration.dart';
import '../exception/l10n_arb_resource_definition_exception.dart';

class ArbValidator {
  const ArbValidator(this.configuration, {required this.resources, required this.meta});

  final L10nConfiguration configuration;
  final Map<String, String> resources;
  final Map<String, dynamic> meta;

  void validate() {
    if (configuration.requiredResourceAttributes) {
      _validateAllResourcesWithAttributes();
    }
    _validatePluralResources();
    _validateSelectResources();
    _validatePlaceholders();
  }

  void _validateAllResourcesWithAttributes() {
    for (final key in resources.keys) {
      final attributeKey = '@$key';
      final definition = meta[attributeKey];
      if (definition == null) {
        throw L10nMissingAnArbResourceException(attributeKey);
      }
      if (definition is! Map<String, dynamic>) {
        throw L10nArbResourceDefinitionException(key);
      }
    }
  }

  void _validatePluralResources() {
    for (final entry in resources.entries) {
      final key = pluralKey(entry.value);
      if (key != null) {
        final attributeKey = '@${entry.key}';
        final definition = meta[attributeKey];
        if (definition == null || definition is! Map<String, dynamic>) {
          throw L10nMissingArbResourceException(attributeKey, type: 'plural');
        }
        final placeholders = definition['placeholders'];
        if (placeholders == null) {
          throw L10nMissingResourcePlaceholdersException(entry.key, type: 'plural');
        }
        if (placeholders is! Map<String, dynamic>) {
          throw L10nArbResourcePlaceholdersFormatException(entry.key);
        }
        final placeholder = placeholders[key];
        if (placeholder == null || placeholder is! Map) {
          throw L10nMissingResourcePlaceholderException(
            entry.key,
            type: 'plural',
            placeholderName: key,
          );
        }
      }
    }
  }

  void _validateSelectResources() {
    for (final entry in resources.entries) {
      final key = selectKey(entry.value);
      if (key != null) {
        final attributeKey = '@${entry.key}';
        final definition = meta[attributeKey];
        if (definition == null || definition is! Map<String, dynamic>) {
          throw L10nMissingArbResourceException(attributeKey, type: 'select');
        }
        final placeholders = definition['placeholders'];
        if (placeholders == null) {
          throw L10nMissingResourcePlaceholdersException(entry.key, type: 'select');
        }
        if (placeholders is! Map<String, dynamic>) {
          throw L10nArbResourcePlaceholdersFormatException(entry.key);
        }
        final placeholder = placeholders[key];
        if (placeholder == null || placeholder is! Map) {
          throw L10nMissingResourcePlaceholderException(
            entry.key,
            type: 'select',
            placeholderName: key,
          );
        }
      }
    }
  }

  void _validatePlaceholders() {
    for (final entry in meta.entries) {
      final placeholders = entry.value['placeholders'];
      if (placeholders != null && placeholders is! Map<String, dynamic>) {
        throw L10nArbResourcePlaceholdersFormatException(entry.key);
      }
    }
  }

  String? pluralKey(String resourceValue) {
    final match = ArbResourceDefinition.pluralResourceRegExp.firstMatch(resourceValue);
    return match?.group(1);
  }

  String? selectKey(String resourceValue) {
    final match = ArbResourceDefinition.selectResourceRegExp.firstMatch(resourceValue);
    return match?.group(1);
  }
}

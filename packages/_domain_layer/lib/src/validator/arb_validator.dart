import '../entity/project/l10n_configuration.dart';
import '../exception/arb_exception.dart';

class ArbValidator {
  const ArbValidator(this.configuration, {required this.resources, required this.meta});

  static final _pluralResourceRegExp = RegExp(r'{\s*(\w+)\s*,\s*plural\s*,.*}');
  static final _selectResourceRegExp = RegExp(r'{\s*(\w+)\s*,\s*select\s*,.*}');

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
        throw ArbResourceDefinitionException.missingOne(attributeKey);
      }
      if (definition is! Map<String, dynamic>) {
        throw ArbResourceDefinitionException.format(key);
      }
    }
  }

  void _validatePluralResources() {
    for (final entry in resources.entries) {
      final pluralKey = _pluralKey(entry.value);
      if (pluralKey != null) {
        final attributeKey = '@${entry.key}';
        final definition = meta[attributeKey];
        if (definition == null || definition is! Map<String, dynamic>) {
          throw ArbResourceDefinitionException.missing(attributeKey, type: 'plural');
        }
        final placeholders = definition['placeholders'];
        if (placeholders == null) {
          throw ArbResourceDefinitionException.missingPlaceholders(entry.key, type: 'plural');
        }
        if (placeholders is! Map<String, dynamic>) {
          throw ArbResourceDefinitionException.placeholdersFormat(entry.key, type: 'plural');
        }
        final placeholder = placeholders[pluralKey];
        if (placeholder == null || placeholder is! Map) {
          throw ArbResourceDefinitionException.missingPlaceholder(
            entry.key,
            type: 'plural',
            placeholderName: pluralKey,
          );
        }
      }
    }
  }

  void _validateSelectResources() {
    for (final entry in resources.entries) {
      final selectKey = _selectKey(entry.value);
      if (selectKey != null) {
        final attributeKey = '@${entry.key}';
        final definition = meta[attributeKey];
        if (definition == null || definition is! Map<String, dynamic>) {
          throw ArbResourceDefinitionException.missing(attributeKey, type: 'select');
        }
        final placeholders = definition['placeholders'];
        if (placeholders == null) {
          throw ArbResourceDefinitionException.missingPlaceholders(entry.key, type: 'select');
        }
        if (placeholders is! Map<String, dynamic>) {
          throw ArbResourceDefinitionException.placeholdersFormat(entry.key, type: 'select');
        }
        final placeholder = placeholders[selectKey];
        if (placeholder == null || placeholder is! Map) {
          throw ArbResourceDefinitionException.missingPlaceholder(
            entry.key,
            type: 'select',
            placeholderName: selectKey,
          );
        }
      }
    }
  }

  void _validatePlaceholders() {
    for (final entry in meta.entries) {
      final placeholders = entry.value['placeholders'];
      if (placeholders != null && placeholders is! Map<String, dynamic>) {
        throw ArbResourceDefinitionException.placeholdersFormat(entry.key, type: '');
      }
    }
  }

  String? _pluralKey(String resourceValue) {
    final match = _pluralResourceRegExp.firstMatch(resourceValue);
    return match?.group(1);
  }

  String? _selectKey(String resourceValue) {
    final match = _selectResourceRegExp.firstMatch(resourceValue);
    return match?.group(1);
  }
}

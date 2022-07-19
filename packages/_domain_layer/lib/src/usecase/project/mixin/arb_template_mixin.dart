import 'dart:convert';
import 'dart:io';

import '../../../entity/arb/arb_definition.dart';
import '../../../entity/arb/arb_locale_translations.dart';
import '../../../entity/arb/arb_placeholder.dart';
import '../../../entity/arb/arb_template.dart';
import '../../../entity/arb/arb_translation.dart';
import '../../../entity/project/project.dart';
import '../../../exception/l10n_arb_exception.dart';
import '../../../exception/l10n_exception.dart';
import 'arb_mixin.dart';

mixin ArbTemplateMixin on ArbMixin {
  static final _localeFromFileNameRegExp = RegExp(r'^\w+_(\w\w).arb$');

  Future<Map<String, dynamic>> readArbTemplateMap(Project project) async {
    final config = project.configuration;
    final dir = Directory('${project.path}/${config.effectiveArbDir}');
    if (!await dir.exists()) {
      throw L10nMissingArbFolderError(dir);
    }

    final path = '${project.path}/${config.effectiveArbDir}/${config.effectiveTemplateArbFile}';
    final file = File(path);
    if (!await file.exists()) {
      throw L10nMissingArbTemplateError(file);
    }

    final content = await file.readAsString();
    final arb = jsonDecode(content);
    if (arb is! Map<String, dynamic>) {
      throw L10nArbFileFormatException(config.effectiveTemplateArbFile);
    }

    return arb;
  }

  Future<List<ArbLocaleTranslations>> readArbTranslations(Project project) async {
    final configuration = project.configuration;
    final dir = Directory('${project.path}/${configuration.effectiveArbDir}');
    if (!await dir.exists()) {
      L10nMissingArbFolderError(dir);
    }

    final languageFiles = <File>[];
    final dirList = dir.listSync();
    for (final file in dirList) {
      if (file is File) {
        final name = file.uri.pathSegments.last;
        if (name.endsWith('.arb')) {
          if (name != configuration.effectiveTemplateArbFile) {
            languageFiles.add(file);
          }
        }
      }
    }
    final translations = <ArbLocaleTranslations>[];
    for (final file in languageFiles) {
      translations.add(await readArbTranslationsFile(file));
    }
    return translations;
  }

  Future<ArbLocaleTranslations> readArbTranslationsFile(File file) async {
    final name = file.uri.pathSegments.last;
    final content = await file.readAsString();
    final arb = json.decode(content);
    if (arb is! Map<String, dynamic>) {
      throw L10nArbFileFormatException(name);
    }

    final locale = arbLocaleFromMap(name, arb);
    final translationsMap = <String, String>{};
    for (final entry in arb.entries) {
      if (!entry.key.startsWith('@')) {
        if (entry.value is String) {
          translationsMap[entry.key] = entry.value;
        } else {
          throw L10nArbDefinitionException(entry.key);
        }
      }
    }
    return arbLocaleTranslations(locale, translationsMap);
  }

  ArbLocaleTranslations arbLocaleTranslations(String locale, Map<String, String> translationsMap) {
    final translations = <String, ArbTranslation>{};
    for (final entry in translationsMap.entries) {
      translations[entry.key] = ArbTranslation(key: entry.key, value: entry.value);
    }
    return ArbLocaleTranslations(locale: locale, translations: translations);
  }

  String arbLocaleFromMap(String fileName, Map<String, dynamic> arb) =>
      arb['@@locale'] ?? matchArbLocaleFromFileName(fileName);

  String matchArbLocaleFromFileName(String name) {
    final match = _localeFromFileNameRegExp.firstMatch(name);
    if (match == null) {
      throw L10nFileMissingLocaleException(name);
    }
    return match.group(1)!;
  }

  void parserArbGlobalsDefinitionsAndTranslationsFromTemplateMap(
    Map<String, dynamic> map, {
    required Map<String, String> globals,
    required Map<String, dynamic> definitions,
    required Map<String, String> translations,
  }) {
    for (final entry in map.entries) {
      if (entry.key.startsWith('@@')) {
        if (entry.value is String) {
          globals[entry.key] = entry.value;
        } else {
          throw L10nArbGlobalDefinitionException(entry.key);
        }
      } else if (entry.key.startsWith('@')) {
        definitions[entry.key] = entry.value;
      } else {
        if (entry.value is String) {
          translations[entry.key] = entry.value;
        } else {
          throw L10nArbDefinitionException(entry.key);
        }
      }
    }
  }

  ArbTemplate arbTemplateFromMap({
    required Map<String, String> globals,
    required Map<String, String> translations,
    required Map<String, dynamic> meta,
  }) {
    final globalResources = globals.entries.map((e) => ArbTranslation(key: e.key, value: e.value));
    final definitions = translations.entries
        .map((keyValue) => arbDefinitionFromMap(keyValue.key, keyValue.value, meta));
    return ArbTemplate(
      globalResources: globalResources.toList(growable: false),
      definitions: definitions.toList(growable: false),
    );
  }

  ArbDefinition arbDefinitionFromMap(String key, String value, Map<String, dynamic> meta) {
    final definitionKey = '@$key';
    final definitionMap = meta[definitionKey];
    final type = arbDefinitionTypeForValue(value);
    switch (type) {
      case ArbDefinitionType.plural:
        return ArbDefinition.plural(
          key: key,
          context: definitionMap?['context'] as String?,
          description: definitionMap?['description'] as String?,
          placeholder: arbPlaceholderName(type, value),
        );
      case ArbDefinitionType.select:
        return ArbDefinition.select(
          key: key,
          context: definitionMap?['context'] as String?,
          description: definitionMap?['description'] as String?,
          placeholder: arbPlaceholderName(type, value),
        );
      default:
        return ArbDefinition.placeholders(
          key: key,
          context: definitionMap?['context'] as String?,
          description: definitionMap?['description'] as String?,
          placeholders:
              arbPlaceholdersFromMap(definitionMap?['placeholders'] as Map<String, dynamic>?),
        );
    }
  }

  List<ArbPlaceholder> arbPlaceholdersFromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return [];
    }
    final placeholders = <ArbPlaceholder>[];
    for (final entry in map.entries) {
      if (entry.value is! Map<String, dynamic>) {
        throw L10nArbPlaceholdersFormatException(entry.key);
      }
      final key = entry.key;
      final type = entry.value['type'] as String?;
      final desc = entry.value['description'] as String? ?? '';
      final example = entry.value['example'] as String? ?? '';
      if (type == null) {
        placeholders.add(ArbPlaceholder.generic(key: key, description: desc, example: example));
      } else if (type == 'String') {
        placeholders.add(ArbPlaceholder.string(key: key, description: desc, example: example));
      } else if (type == 'DateTime') {
        final formatString = entry.value['format'] as String? ?? '';
        final format = ArbIcuDateTimePlaceholderFormat.forSkeleton(formatString) ??
            ArbIcuDateTimePlaceholderFormat.yearMonthDay;
        final useCustomFormat = entry.value['isCustomDateFormat'] == 'true';
        placeholders.add(
          ArbPlaceholder.dateTime(
            key: key,
            description: desc,
            example: example,
            icuFormat: format,
            useCustomFormat: useCustomFormat,
            customFormat: useCustomFormat ? formatString : '',
          ),
        );
      } else if (type == 'num' || type == 'int' || type == 'double') {
        final formatName = entry.value['format'] as String?;
        final format = formatName == null ? null : ArbNumberPlaceholderFormat.forName(formatName);
        final optionalParamsMap = entry.value['optionalParameters'] as Map<String, dynamic>?;
        final optionalParameters = <String, String>{};
        if (format != null && optionalParamsMap != null) {
          for (final entry in optionalParamsMap.entries) {
            try {
              final parameter = ArbNumberPlaceholderParameter.forName(entry.key);
              if (format.optionalParameters.contains(parameter)) {
                optionalParameters[entry.key] = entry.value;
              }
            } catch (e) {
              throw const L10nException();
            }
          }
        }
        placeholders.add(
          ArbPlaceholder.number(
            key: key,
            description: desc,
            example: example,
            type: ArbPlaceholderType.forType(type),
            format: format,
            optionalParameters: optionalParameters,
          ),
        );
      }
    }
    return placeholders;
  }
}

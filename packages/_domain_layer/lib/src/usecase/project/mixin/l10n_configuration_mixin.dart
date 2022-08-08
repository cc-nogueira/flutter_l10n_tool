import 'dart:io';

import 'package:yaml/yaml.dart';

import '../../../../domain_layer.dart';

class L10nConfigurationMixin {
  Future<L10nConfiguration> readL10nConfiguration(Project project) async {
    final file = File('${project.path}/l10n.yaml');

    if (!await file.exists()) {
      return const L10nConfiguration(usingYamlFile: false);
    } else {
      final content = await file.readAsString();
      final yaml = loadYaml(content) ?? <String, dynamic>{};
      if (yaml is! Map) {
        throw const L10nInvalidConfigurationFileException();
      }

      return L10nConfiguration(
        usingYamlFile: true,
        arbDir: yaml['arb-dir'] ?? '',
        templateArbFile: yaml['template-arb-file'] ?? '',
        syntheticPackage: yaml['synthetic-package'] ?? L10nConfiguration.defaultSyntheticPackage,
        outputDir: yaml['output-dir'] ?? '',
        outputLocalizationFile: yaml['output-localization-file'] ?? '',
        outputClass: yaml['output-class'] ?? '',
        untranslatedMessagesFile: yaml['untranslated-messages-file'],
        header: yaml['header'] ?? '',
        requiredResourceAttributes: yaml['required-resource-attributes'] ??
            L10nConfiguration.defaultRequiredResourceAttributes,
        nullableGetter: yaml['nullable-getter'] ?? L10nConfiguration.defaultNullableGetter,
      );
    }
  }
}

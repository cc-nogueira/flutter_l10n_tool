import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'definition_widget.dart';
import 'resource_bar.dart';
import 'translation_widget.dart';

class ResourceWidget extends ConsumerWidget {
  const ResourceWidget(this.definition, {super.key});

  final ArbDefinition definition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    return Column(
      children: [
        const ResourceBar(),
        DefinitionWidget(definition),
        for (final localeTranslations in project.translations.values)
          TranslationWidget(
            localeTranslations.locale,
            definition,
            localeTranslations.translations[definition.key],
          )
      ],
    );
  }
}

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'resource_definition_widget.dart';
import 'resource_translation_widget.dart';

class ResourceWidget extends ConsumerWidget {
  const ResourceWidget(this.resource, {super.key});

  final ArbResourceDefinition resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    return Column(
      children: [
        ResourceDefinitionWidget(resource),
        for (final localeTranslations in project.translations.values)
          ResourceTranslationWidget(project, resource, localeTranslations)
      ],
    );
  }
}

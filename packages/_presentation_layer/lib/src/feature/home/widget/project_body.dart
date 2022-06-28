import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/message_widget.dart';
import 'resource_widget.dart';

class ProjectBody extends ConsumerWidget {
  const ProjectBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    if (project.hasError) {
      return _errorBody(context, project);
    }
    if (project.isNotReady) {
      return _notReadyBody();
    }
    final selectedDefinition = ref.watch(selectedDefinitionProvider);
    return _resourceBody(selectedDefinition);
  }

  Widget _resourceBody(ArbDefinition? definition) {
    return definition == null
        ? const MessageWidget('Localization App')
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ResourceWidget(definition),
          );
  }

  Widget _notReadyBody() => const MessageWidget('Localization App');

  Widget _errorBody(BuildContext context, Project project) {
    final colors = Theme.of(context).colorScheme;
    late final String message;
    if (project.l10nException != null) {
      message = 'Project configuration error: ${project.l10nException!.message(context)}';
    } else {
      message = 'Project loading error: ${project.loadError}';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: colors.errorContainer,
          padding: const EdgeInsets.all(16),
          child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
        ),
      ],
    );
  }
}

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/message_widget.dart';

class ProjectBody extends ConsumerWidget {
  const ProjectBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final colors = Theme.of(context).colorScheme;
    if (project.hasError) {
      return _errorBody(context, project);
    }
    if (project.isNotReady) {
      return _notReadyBody(context);
    }

    return _body(context, colors, project);
  }

  Widget _body(BuildContext context, ColorScheme colors, Project project) {
    return const MessageWidget('Localization App');
  }

  Widget _notReadyBody(BuildContext context) => const MessageWidget('Localization App');

  Widget _errorBody(BuildContext context, Project project) {
    late final String message;
    if (project.l10nException != null) {
      message = 'Project configuration error: ${project.l10nException!.message(context)}';
    } else {
      message = 'Project loading error: ${project.loadError}';
    }
    final colors = Theme.of(context).colorScheme;
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

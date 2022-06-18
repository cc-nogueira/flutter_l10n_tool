import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectBody extends ConsumerWidget {
  const ProjectBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    if (project.hasNoError) {
      return child;
    }
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
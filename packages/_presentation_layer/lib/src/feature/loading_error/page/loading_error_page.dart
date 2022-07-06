import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widget/fix_missing_arb_folder_widget.dart';
import '../widget/fix_missing_arb_template_file_widget.dart';
import '../widget/fix_missing_dependency_widget.dart';

class LoadErrorPage extends StatelessWidget {
  const LoadErrorPage(this.read, this.project, {super.key});

  final Reader read;
  final Project project;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    late final String message;
    if (project.l10nException != null) {
      message = 'Project configuration error: ${project.l10nException!.message(context)}';
    } else {
      message = 'Project loading error';
    }
    final errorActions = _errorFixActions(context, colors);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: colors.errorContainer,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(message, style: TextStyle(color: colors.onErrorContainer)),
              if (errorActions != null) errorActions,
            ],
          ),
        ),
      ],
    );
  }

  Widget? _errorFixActions(BuildContext context, ColorScheme colors) {
    final exception = project.l10nException;
    if (exception is L10nMissingDependencyException) {
      return FixMissingDependencyWidget(read: read, project: project, exception: exception);
    }
    if (exception is L10nMissingArbFolderException) {
      return FixMissingArbFolderWidget(read: read, project: project, exception: exception);
    }
    if (exception is L10nMissingArbTemplateFileException) {
      return FixMissingArbTemplateFileWidget(read: read, project: project, exception: exception);
    }
    return null;
  }
}

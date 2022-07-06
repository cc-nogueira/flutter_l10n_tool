import 'package:_domain_layer/domain_layer.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../show_project_loading/page/show_project_loading_dialog.dart';

class OpenProjectButton extends ConsumerWidget {
  const OpenProjectButton({super.key, required this.style});

  final ButtonStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    return TextButton.icon(
      style: style,
      icon: const Icon(Icons.folder_outlined),
      label: Text('${loc.label_open_project} ...'),
      onPressed: () => _onPressed(context, loc, ref.read),
    );
  }

  void _onPressed(BuildContext context, AppLocalizations loc, Reader read) async {
    final projectPath = await getDirectoryPath(confirmButtonText: loc.label_choose);
    if (projectPath == null) {
      return;
    }

    read(projectUsecaseProvider).loadProject(projectPath: projectPath);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ShowProjectLoadingDialog(),
    );
  }
}

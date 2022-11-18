import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../show_project_loading/page/show_project_loading_dialog.dart';
import '../page/fix_loading_error_dialog.dart';

abstract class FixActionWidget extends StatelessWidget {
  const FixActionWidget({super.key, required this.ref, required this.project});

  final WidgetRef ref;
  final Project project;

  void showFixDialogAndReload(
    BuildContext context,
    AppLocalizations loc, {
    required String title,
    required String fixDescription,
    required L10nExceptionCallback fixCallback,
  }) async {
    late final bool fixOK;
    try {
      fixOK = await showFixLoadingErrorDialog(
        context,
        loc,
        title: title,
        fixDescription: fixDescription,
        fixCallback: fixCallback,
      );
    } catch (e) {
      fixOK = false;
    }
    if (fixOK) {
      ref.read(projectUsecaseProvider).loadProject(projectPath: project.path);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const ShowProjectLoadingDialog(),
      );
    }
  }
}

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../load_project/page/load_project_dialog.dart';
import '../page/fix_loading_error_dialog.dart';

abstract class FixActionWidget extends StatelessWidget {
  const FixActionWidget({super.key, required this.project});

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
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => LoadProjectDialog(project.path, loc),
      );
    }
  }
}

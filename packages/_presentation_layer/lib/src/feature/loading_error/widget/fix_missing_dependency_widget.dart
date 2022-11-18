import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';
import 'fix_action_widgets.dart';

class FixMissingDependencyWidget extends FixActionWidget {
  const FixMissingDependencyWidget({
    super.key,
    required super.ref,
    required super.project,
    required this.exception,
  });

  final L10nMissingDependencyException exception;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(children: [
        outlinedButton(
          text: exception.fixActionLabel,
          onPressed: () => showFixDialogAndReload(
            context,
            loc,
            title: exception.fixActionLabel,
            fixDescription: exception.fixActionDescription,
            fixCallback: exception.fixActionCallback,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
            message: exception.fixActionInfo,
            child: Icon(Icons.info_outline, color: colors.onErrorContainer)),
      ]),
    );
  }
}

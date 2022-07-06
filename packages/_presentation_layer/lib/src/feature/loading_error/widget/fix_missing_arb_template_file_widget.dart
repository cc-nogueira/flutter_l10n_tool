import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/navigation/navigation_drawer_option.dart';
import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../../../provider/presentation_providers.dart';
import 'fix_action_widgets.dart';

class FixMissingArbTemplateFileWidget extends FixActionWidget {
  const FixMissingArbTemplateFileWidget({
    super.key,
    required this.read,
    required super.project,
    required this.exception,
  });

  static const _horizontalSpace = SizedBox(width: 8.0);

  final Reader read;
  final L10nMissingArbTemplateFileException exception;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(children: [
        outlinedButton(
          text: loc.title_project_configuration_drawer,
          onPressed: _showConfigurationDrawer,
        ),
        _horizontalSpace,
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
        _horizontalSpace,
        Tooltip(
            message: exception.fixActionInfo,
            child: Icon(Icons.info_outline, color: colors.onErrorContainer)),
      ]),
    );
  }

  void _showConfigurationDrawer() {
    read(activeNavigationProvider.notifier).state = NavigationDrawerTopOption.configuration;
  }
}

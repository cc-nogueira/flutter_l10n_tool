import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/navigation/navigation_drawer_option.dart';
import '../../../common/theme/warning_theme_extension.dart';
import '../../../common/widget/message_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../../../provider/presentation_providers.dart';
import '../../loading_error/page/loading_error_page.dart';
import '../widget/active_page.dart';
import '../widget/navigation_and_scaffold.dart';
import '../widget/project_title.dart';

/// Projects landing page.
///
/// Shows a page with main navigation cards.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      NavigationAndScaffold(title: const ProjectTitle(), body: _body(context, ref));

  Widget _body(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    if (project.hasError) {
      return LoadErrorPage(ref, project);
    }
    if (project.isNotReady) {
      return _messageWidget(context);
    }
    if (project.generateWarning) {
      return Column(
        children: [
          _generateWarningWidget(context, ref),
          const Expanded(child: ActivePage()),
        ],
      );
    }
    return const ActivePage();
  }

  Widget _messageWidget(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return MessageWidget(loc.title_home_page);
  }

  Widget _generateWarningWidget(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final warning = Theme.of(context).extension<WarningTheme>();
    final style = TextStyle(color: warning?.foregroundColor);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(color: warning?.backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectableText(loc.message_generate_flag_for_synthetic_package, style: style),
          const SizedBox(height: 8.0),
          Row(
            children: [
              SelectableText(loc.message_alternative_configure_custom_output_folder, style: style),
              const SizedBox(width: 8.0),
              TextButton(
                onPressed: () => _showConfigurationDrawer(ref),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF930006), padding: EdgeInsets.zero),
                child: Text(loc.title_project_configuration_drawer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfigurationDrawer(WidgetRef ref) =>
      ref.read(activeNavigationProvider.notifier).state = NavigationDrawerTopOption.configuration;
}

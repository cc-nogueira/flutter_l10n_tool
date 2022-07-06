import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/navigation/navigation_drawer_option.dart';
import '../../../common/widget/message_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../../../provider/presentation_providers.dart';
import '../../loading_error/page/loading_error_page.dart';
import '../../resource_editor/page/resource_page.dart';
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
      return LoadErrorPage(ref.read, project);
    }
    if (project.isNotReady) {
      return _messageWidget(context);
    }
    if (project.generateWarning) {
      return Column(
        children: [
          _generateWarningWidget(context, ref.read),
          const Expanded(child: ResourcePage()),
        ],
      );
    }
    return const ResourcePage();
  }

  Widget _messageWidget(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return MessageWidget(loc.title_home_page);
  }

  Widget _generateWarningWidget(BuildContext context, Reader read) {
    final loc = AppLocalizations.of(context);
    const style = TextStyle(color: Colors.black);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: const BoxDecoration(color: Colors.amber),
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
                onPressed: () => _showConfigurationDrawer(read),
                style: TextButton.styleFrom(
                    primary: const Color(0xFF930006), padding: EdgeInsets.zero),
                child: Text(loc.title_project_configuration_drawer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfigurationDrawer(Reader read) =>
      read(activeNavigationProvider.notifier).state = NavigationDrawerTopOption.configuration;
}

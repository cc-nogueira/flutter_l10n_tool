import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/message_widget.dart';
import '../../../l10n/app_localizations.dart';
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
    return const ResourcePage();
  }

  Widget _messageWidget(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return MessageWidget(loc.title_home_page);
  }
}

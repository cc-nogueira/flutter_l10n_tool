import 'dart:io';

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/widget/message_widget.dart';
import '../../l10n/translations.dart';
import '../navigation/navigation_and_scaffold.dart';

/// Projects landing page.
///
/// Shows a page with main navigation cards.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const title = ProjectTitle();
    const body = MessageWidget('Localization App');
    return _isMobile
        ? _mobileScaffold(context, title, body)
        : const NavigationAndScaffold(title: title, body: body);
  }

  Widget _mobileScaffold(BuildContext context, Widget title, Widget body) => Scaffold(
        appBar: AppBar(title: title),
        body: body,
      );

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;
}

class ProjectTitle extends ConsumerWidget {
  const ProjectTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    if (!project.loaded) {
      final tr = Translations.of(context);
      return Text(tr.title_home_page);
    }
    final colors = Theme.of(context).colorScheme;
    final nameStyle = TextStyle(fontWeight: FontWeight.w400, color: colors.onSurface);
    final pathStyle = TextStyle(fontWeight: FontWeight.w300, color: colors.onSurfaceVariant);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(project.name, style: nameStyle),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            project.path,
            style: pathStyle,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

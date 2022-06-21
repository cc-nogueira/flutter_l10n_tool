import 'dart:io';

import 'package:flutter/material.dart';

import '../widget/navigation_and_scaffold.dart';
import '../widget/project_body.dart';
import '../widget/project_title.dart';

/// Projects landing page.
///
/// Shows a page with main navigation cards.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const title = ProjectTitle();
    const body = ProjectBody();
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

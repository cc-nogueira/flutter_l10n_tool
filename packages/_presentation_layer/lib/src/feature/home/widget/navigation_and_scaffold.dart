import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/desktop/container_with_title_bar.dart';
import '../../../provider/presentation_providers.dart';
import '../../navigation/rail/navigation_drawer_rail.dart';
import 'active_navigation_drawer.dart';

class NavigationAndScaffold extends ConsumerWidget {
  const NavigationAndScaffold({super.key, required this.title, required this.body});

  final Widget title;
  final Widget body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveDrawer = ref.watch(activeNavigationProvider.select((value) => value != null));
    return Row(
      children: [
        const NavigationDrawerRail(),
        Expanded(
          child: Scaffold(
            body: Row(
              children: [
                if (hasActiveDrawer) const ActiveNavigationDrawer(),
                Expanded(
                  child: ContainerWithTitleBar(
                    title: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: title,
                    ),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

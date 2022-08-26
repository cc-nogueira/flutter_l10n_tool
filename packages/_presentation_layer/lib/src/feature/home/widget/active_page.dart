import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/navigation/navigation_drawer_option.dart';
import '../../../provider/presentation_providers.dart';
import '../../change_control/page/change_control_page.dart';
import '../../resource_editor/page/resource_page.dart';

/// Convenient widget to show the active page.
///
/// This riverpod widget observes the [activeNavigationProvider] to display the corresponding page.
class ActivePage extends ConsumerWidget {
  /// Const constructor.
  const ActivePage({super.key});

  /// Return the NavigationDrawer subclass corresponding to that current [activeNavigationProvider]
  /// state.
  ///
  /// Return a empty Container if there is no active navigation option.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNavigation = ref.watch(activeNavigationProvider);
    switch (activeNavigation) {
      case NavigationDrawerTopOption.changeControl:
        return const ChangeControlPage();
      default:
        return const ResourcePage();
    }
  }
}

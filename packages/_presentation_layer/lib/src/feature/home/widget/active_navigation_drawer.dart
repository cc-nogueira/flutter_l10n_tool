import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/navigation/navigation_drawer_option.dart';
import '../../../provider/presentation_providers.dart';
import '../../change_control/page/change_control_drawer.dart';
import '../../configuration/page/project_configuration_drawer.dart';
import '../../help/help_drawer.dart';
import '../../preferences/preferences_drawer.dart';
import '../../project_selector/page/project_selector_drawer.dart';
import '../../resources/page/resources_drawer.dart';

/// Convenient widget to show the active navigation drawer or an empty container.
///
/// This riverpod widget observes the [activeNavigationProvider] to display that provider
/// [NavigationDrawerOption].
class ActiveNavigationDrawer extends ConsumerWidget {
  /// Const constructor.
  const ActiveNavigationDrawer({super.key});

  /// Return the NavigationDrawer subclass corresponding to that current [activeNavigationProvider]
  /// state.
  ///
  /// Return a empty Container if there is no active navigation option.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNavigation = ref.watch(activeNavigationProvider);
    switch (activeNavigation) {
      case NavigationDrawerTopOption.projectSelector:
        return const ProjectSelectorDrawer();
      case NavigationDrawerTopOption.configuration:
        return const ProjectConfigurationDrawer();
      case NavigationDrawerTopOption.preferences:
        return const PreferencesDrawer();
      case NavigationDrawerTopOption.resources:
        return const ResourcesDrawer();
      case NavigationDrawerTopOption.changeControl:
        return const ChangeControlDrawer();
      case NavigationDrawerBottomOption.help:
        return const HelpDrawer();
      default:
        return Container();
    }
  }
}

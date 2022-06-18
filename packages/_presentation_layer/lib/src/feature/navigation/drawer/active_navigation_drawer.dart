import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/presentation_providers.dart';
import 'help_drawer.dart';
import 'navigation_drawer_option.dart';
import 'preferences_drawer.dart';
import 'project_configuration_drawer.dart';
import 'project_selector_drawer.dart';

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
      case NavigationDrawerOption.projectSelector:
        return const ProjectSelectorDrawer();
      case NavigationDrawerOption.configuration:
        return const ProjectConfigurationDrawer();
      case NavigationDrawerOption.preferences:
        return const PreferencesDrawer();
      case NavigationDrawerOption.help:
        return const HelpDrawer();
      default:
        return Container();
    }
  }
}

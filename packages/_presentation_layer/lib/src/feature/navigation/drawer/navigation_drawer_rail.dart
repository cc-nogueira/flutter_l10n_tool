import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/presentation_providers.dart';
import 'navigation_drawer_option.dart';

/// Project [NavigationRail].
///
/// Present each [NavigationDrawerOption] as a navigation destination.
/// Destination icons and indicatorColors are retrieved from each drawer option.
///
/// The selected index is stored/watched with a riverpod [activeNavigationProvider].
class NavigationDrawerRail extends ConsumerWidget {
  /// Const constructor.
  const NavigationDrawerRail({super.key});

  /// Builds this widget [NavigationRail] with destinatons in [NavigationDrawerOption].
  /// Destination icons and indicatorColors are retrieved from each drawer option.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNavigation = ref.watch(activeNavigationProvider);
    final colors = Theme.of(context).colorScheme;

    return NavigationRail(
      minWidth: 58,
      labelType: NavigationRailLabelType.none,
      backgroundColor: colors.secondaryContainer,
      indicatorColor: activeNavigation?.color(colors),
      destinations: _destinations,
      selectedIndex: activeNavigation?.index,
      onDestinationSelected: (index) =>
          _onDestinationTap(ref.read, NavigationDrawerOption.values[index]),
    );
  }

  /// Internal - generate a list of [NavigationRailDestination] with [NavigationDrawerOption].
  /// Destination icons are retrieved from each drawer option.
  /// Since this app rail is always collaped labels do not need to be internationalized.
  List<NavigationRailDestination> get _destinations => NavigationDrawerOption.values
      .map(
        (nav) => NavigationRailDestination(
          icon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Icon(nav.icon, size: 28, color: const Color(0xFFBBBBBB)),
          ),
          selectedIcon: Icon(nav.icon, color: const Color(0xFFFFFFFF)),
          label: Text(nav.name),
        ),
      )
      .toList();

  /// Internal - [NavigationRail.onDestinationSelected] callback.
  ///
  /// Updates the state in riverpod [activeNavigationProvider].
  /// Since this widget also observes this provider it will be notified and rebuild as a consequence
  /// of this update.
  void _onDestinationTap(Reader read, NavigationDrawerOption option) =>
      read(activeNavigationProvider.notifier).update((state) => state == option ? null : option);
}

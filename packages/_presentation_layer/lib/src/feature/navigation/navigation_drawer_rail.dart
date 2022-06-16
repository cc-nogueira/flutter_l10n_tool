import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/presentation_providers.dart';
import 'navigation_drawer_option.dart';

class NavigationDrawerRail extends ConsumerWidget {
  const NavigationDrawerRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNavigation = ref.watch(activeNavigationProvider);
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: NavigationRail(
            minWidth: 58,
            backgroundColor: colors.secondaryContainer,
            labelType: NavigationRailLabelType.none,
            selectedIndex: activeNavigation?.index,
            destinations: _destinations,
            onDestinationSelected: (index) =>
                _onDestinationTap(ref.read, NavigationDrawerOption.values[index]),
            indicatorColor: activeNavigation?.color(colors),
          ),
        ),
      ],
    );
  }

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

  void _onDestinationTap(Reader read, NavigationDrawerOption option) =>
      read(activeNavigationProvider.notifier).update((state) => state == option ? null : option);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/presentation_providers.dart';
import '../common/navigation_drawer_option.dart';
import 'widget/navigation_button.dart';

const _navigationWidth = 58.0;

/// Project [NavigationRail].
///
/// Present each [NavigationDrawerTopOption] as a navigation destination.
/// Destination icons and indicatorColors are retrieved from each drawer option.
///
/// Also shows all [NavigationDrawerBottomOption] values as bottom navigation buttons.
///
/// With this composition we render a rail with two groups of options, both setting the active
/// naviagtion in the same storage.
///
/// The selected option is stored/watched with a riverpod [activeNavigationProvider].
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
      minWidth: _navigationWidth,
      labelType: NavigationRailLabelType.none,
      backgroundColor: colors.secondaryContainer,
      indicatorColor: activeNavigation?.color(colors),
      destinations: _destinations(NavigationDrawerTopOption.values),
      selectedIndex: _topNavigationIndex(activeNavigation),
      onDestinationSelected: (index) =>
          _onDestinationTap(ref.read, NavigationDrawerTopOption.values[index]),
      trailing: _navigationTrailing(context, colors, ref.read, activeNavigation),
    );
  }

  /// Find the navigation index for a option if it is a NavigationDrawerTopOption.
  ///
  /// Retuns the NavigationDrawerOption index or null if it is not a NavigationDrawerTopOption.
  int? _topNavigationIndex(NavigationDrawerOption? option) =>
      option is NavigationDrawerTopOption ? option.index : null;

  /// Internal - generate a list of [NavigationRailDestination] with [NavigationDrawerOption].
  List<NavigationRailDestination> _destinations(List<NavigationDrawerOption> options) =>
      options.map((option) => _destination(option)).toList();

  /// Internal - generate a [NavigationRailDestination] for a [NavigationDrawerOption].
  /// Destination icons are retrieved from each drawer option.
  /// Since this app rail is always collaped labels do not need to be internationalized.
  NavigationRailDestination _destination(NavigationDrawerOption option) =>
      NavigationRailDestination(
        icon: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Icon(option.icon, size: 28, color: const Color(0xFFBBBBBB)),
        ),
        selectedIcon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Icon(option.icon, size: 28, color: const Color(0xFFFFFFFF))),
        label: Text(option.label),
      );

  /// Internal - trailing navigation buttons.
  ///
  /// These button mimic the look and feel of this rail destination buttons.
  Widget? _navigationTrailing(BuildContext context, ColorScheme colors, Reader read,
      NavigationDrawerOption? activeNavigation) {
    final buttons = <Widget>[];
    for (final option in NavigationDrawerBottomOption.values) {
      final destination = _destination(option);
      buttons.add(
        NavigationButton(
          destination,
          indicatoColor: option.color(colors),
          width: _navigationWidth,
          isActive: option == activeNavigation,
          onTap: () => _onDestinationTap(read, option),
        ),
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: buttons,
        ),
      ),
    );
  }

  /// Internal - [NavigationRail.onDestinationSelected] callback.
  ///
  /// Updates the state in riverpod [activeNavigationProvider].
  /// Since this widget also observes this provider it will be notified and rebuild as a consequence
  /// of this update.
  void _onDestinationTap(Reader read, NavigationDrawerOption option) =>
      read(activeNavigationProvider.notifier).update((state) => state == option ? null : option);
}

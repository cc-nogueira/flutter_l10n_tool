import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/translations.dart';
import '../../provider/presentation_providers.dart';
import 'navigation_drawer_option.dart';
import 'project_configuration_drawer.dart';
import 'project_selector_drawer.dart';

class ActiveNavigationDrawer extends ConsumerWidget {
  const ActiveNavigationDrawer({super.key});

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

abstract class NavigationDrawer extends ConsumerWidget {
  const NavigationDrawer(
    this.option, {
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
  });

  final NavigationDrawerOption option;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    return Drawer(
      child: Column(
        children: [
          _header(context, ref, tr),
          Expanded(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children(context, ref, tr),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, WidgetRef ref, Translations tr) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DrawerHeader(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(color: headerColor(colors)),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleText(tr)),
                ...headerChildren(context, ref, tr),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String titleText(Translations tr);

  List<Widget> headerChildren(BuildContext context, WidgetRef ref, Translations tr) => [];

  List<Widget> children(BuildContext context, WidgetRef ref, Translations tr) => [];

  Color headerColor(ColorScheme colors) => option.color(colors);
}

class PreferencesDrawer extends NavigationDrawer {
  const PreferencesDrawer({super.key}) : super(NavigationDrawerOption.preferences);

  @override
  String titleText(Translations tr) => tr.title_preferences_drawer;
}

class HelpDrawer extends NavigationDrawer {
  const HelpDrawer({super.key}) : super(NavigationDrawerOption.help);

  @override
  String titleText(Translations tr) => tr.title_help_drawer;
}

import 'package:flutter/material.dart';

enum X { a }

abstract class NavigationDrawerOption {
  int get index;
  IconData get icon;
  String get label;
  Color color(ColorScheme colors);
}

/// Naviagation options for this app navigation rail.
///
/// Each option defines an icon and a method to return that option color.
/// This color is used for the navigation rail indicator color and for the corresponding drawer
/// header color.
enum NavigationDrawerTopOption implements NavigationDrawerOption {
  projectSelector(Icons.source_outlined),
  configuration(Icons.webhook_outlined),
  preferences(Icons.settings_outlined),
  resources(Icons.list);

  /// Const constructor
  const NavigationDrawerTopOption(this.icon);

  /// Option icon
  @override
  final IconData icon;

  @override
  String get label => name;

  /// Option color from the project color scheme.
  @override
  Color color(ColorScheme colors) {
    if (this == NavigationDrawerTopOption.projectSelector) {
      return colors.primaryContainer;
    }
    if (this == NavigationDrawerTopOption.configuration) {
      return colors.onTertiary;
    }
    if (this == NavigationDrawerTopOption.preferences) {
      return colors.onSecondary;
    }
    if (this == NavigationDrawerTopOption.resources) {
      return colors.onPrimary;
    }
    return colors.surface;
  }
}

/// Naviagation bottom options for this app navigation rail.
///
/// Each option defines an icon and a method to return that option color.
/// This color is used for the navigation rail indicator color and for the corresponding drawer
/// header color.
enum NavigationDrawerBottomOption implements NavigationDrawerOption {
  help(Icons.help_outline);

  /// Const constructor
  const NavigationDrawerBottomOption(this.icon);

  /// Option icon
  @override
  final IconData icon;

  @override
  String get label => name;

  /// Option color from the project color scheme.
  @override
  Color color(ColorScheme colors) {
    if (this == NavigationDrawerBottomOption.help) {
      return colors.tertiaryContainer;
    }
    return colors.surface;
  }
}

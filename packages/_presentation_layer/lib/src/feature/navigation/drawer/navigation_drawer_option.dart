import 'package:flutter/material.dart';

/// Naviagation options for this app navigation rail.
///
/// Each option defines an icon and a method to return that option color.
/// This color is used for the navigation rail indicator color and for the corresponding drawer
/// header color.
enum NavigationDrawerOption {
  projectSelector(Icons.source_outlined),
  configuration(Icons.webhook_outlined),
  preferences(Icons.settings_outlined),
  help(Icons.help_outline);

  /// Const constructor
  const NavigationDrawerOption(this.icon);

  /// Option icon
  final IconData icon;

  /// Option color from the project color scheme.
  Color color(ColorScheme colors) {
    if (this == NavigationDrawerOption.projectSelector) {
      return colors.primaryContainer;
    }
    if (this == NavigationDrawerOption.configuration) {
      return colors.onTertiary;
    }
    if (this == NavigationDrawerOption.preferences) {
      return colors.onSecondary;
    }
    if (this == NavigationDrawerOption.help) {
      return colors.tertiaryContainer;
    }
    return colors.surface;
  }
}

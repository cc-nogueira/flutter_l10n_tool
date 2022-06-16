import 'package:flutter/material.dart';

enum NavigationDrawerOption {
  projectSelector(Icons.source_outlined),
  configuration(Icons.webhook_outlined, requiresProject: true),
  preferences(Icons.settings_outlined),
  help(Icons.help_outline);

  const NavigationDrawerOption(this.icon, {this.requiresProject = false});

  final IconData icon;
  final bool requiresProject;

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

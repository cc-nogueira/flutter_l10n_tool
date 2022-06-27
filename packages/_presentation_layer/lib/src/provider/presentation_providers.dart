import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/theme/theme_builder.dart';
import '../feature/navigation/common/navigation_drawer_option.dart';

// -- Theme:

/// theme builder provider
final themeBuilderProvider = Provider((_) => ThemeBuilder());

/// dark theme
final darkThemeProvider = Provider((ref) => ref.watch(themeBuilderProvider).darkTheme);

/// light theme
final lightThemeProvider = Provider((ref) => ref.watch(themeBuilderProvider).lightTheme);

/// theme provider based on mode preference.
final themeProvider = Provider((ref) {
  final mode = ref.watch(themeModeProvider);
  if (mode == ThemeMode.light) {
    return ref.watch(lightThemeProvider);
  }
  return ref.watch(darkThemeProvider);
});

/// Navigation rail/drawer
final activeNavigationProvider =
    StateProvider<NavigationDrawerOption?>((_) => NavigationDrawerTopOption.projectSelector);

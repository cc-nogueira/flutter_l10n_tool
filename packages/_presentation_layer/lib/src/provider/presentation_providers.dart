import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/navigation/navigation_drawer_option.dart';
import '../common/theme/theme_builder.dart';

// -- Theme:

/// theme builder provider
final themeBuilderProvider = Provider((_) => ThemeBuilder());

/// dark theme
final darkThemeProvider = Provider((ref) => ref.watch(themeBuilderProvider).darkTheme);

/// light theme
final lightThemeProvider = Provider((ref) => ref.watch(themeBuilderProvider).lightTheme);

/// theme provider based on mode preference
final themeProvider = Provider((ref) {
  final mode = ref.watch(themeModeProvider);
  if (mode == ThemeMode.light) {
    return ref.watch(lightThemeProvider);
  }
  return ref.watch(darkThemeProvider);
});

/// Locales filter provider
final selectedLocalesProvider = StateProvider<Set<String>>((ref) {
  ref.watch(projectProvider.select((project) => project.isReady));
  return <String>{};
});

final allLocalesProvider =
    Provider(((ref) => ref.read(projectProvider).translations.keys.toList()));

final activeLocalesProvider = Provider((ref) {
  final selected = ref.watch(selectedLocalesProvider).toList();
  if (selected.isNotEmpty) {
    return selected;
  }
  return ref.watch(allLocalesProvider);
});

final localeTranslationForActiveLocalesProvider = Provider((ref) {
  final activeLocales = ref.watch(activeLocalesProvider);
  final translations = ref.read(projectProvider).translations;
  return [
    for (final locale in activeLocales) translations[locale]!,
  ];
});

/// Navigation rail/drawer
final activeNavigationProvider =
    StateProvider<NavigationDrawerOption?>((_) => NavigationDrawerTopOption.projectSelector);

final resetConfigurationProvider = StateProvider<bool>((_) => false);

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
final localesFilterProvider = StateProvider((ref) {
  final isReady = ref.watch(projectProvider.select((project) => project.isReady));
  final count = isReady ? ref.read(projectProvider).translations.length : 0;
  return List.filled(count, false);
});

final selectedLocalesProvider = Provider((ref) {
  final locales = ref.read(projectProvider).translations.keys.toList();
  final filters = ref.watch(localesFilterProvider);
  assert(filters.length == locales.length);
  final noneSelected = !filters.any((value) => value);
  return [
    for (int i = 0; i < filters.length; ++i)
      if (noneSelected || filters[i]) locales[i]
  ];
});

final selectedLocaleTranslationsProvider = Provider((ref) {
  final selectedLocales = ref.watch(selectedLocalesProvider);
  final translations = ref.read(projectProvider).translations;
  return [
    for (final locale in selectedLocales) translations[locale]!,
  ];
});

/// Navigation rail/drawer
final activeNavigationProvider =
    StateProvider<NavigationDrawerOption?>((_) => NavigationDrawerTopOption.projectSelector);

final resetConfigurationProvider = StateProvider<bool>((_) => false);

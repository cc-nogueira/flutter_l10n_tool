import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../entity/preferences/language_option.dart';
import '../entity/project/arb_resource.dart';
import '../entity/project/l10n_configuration.dart';
import '../entity/project/project.dart';
import '../layer/domain_layer.dart';
import '../usecase/preferences_usecase.dart';
import '../usecase/project_usecase.dart';
import '../usecase/resource_usecase.dart';

/// Domain Layer provider
final domainLayerProvider = Provider((ref) => DomainLayer(read: ref.read));

/// Function provider for dependency configuration (implementation injection)
final domainConfigurationProvider = Provider<DomainConfiguration>(
    (ref) => ref.watch(domainLayerProvider.select((layer) => layer.configure)));

/// System locales obtained on main()
final systemLocalesProvider = StateProvider<List<Locale>>((ref) => []);

// -- Preferences:

/// PreferencesUsecase singleton provider
final preferencesUsecaseProvider =
    Provider<PreferencesUsecase>((ref) => ref.watch(domainLayerProvider).preferencesUsecase);

/// LanguageOption preference provider
final languageOptionProvider = StateNotifierProvider<LanguageOptionNotifier, LanguageOption>((ref) {
  final usecase = ref.read(preferencesUsecaseProvider);
  return LanguageOptionNotifier(usecase);
});

/// ThemeMode preference provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final usecase = ref.read(preferencesUsecaseProvider);
  return ThemeModeNotifier(usecase);
});

// -- Project

/// ProjectUsecase singleton provider
final projectUsecaseProvider = Provider<ProjectUsecase>((ref) => ProjectUsecase(ref.read));

/// Current project provider
final projectProvider = StateNotifierProvider<ProjectNotifier, Project>((_) => ProjectNotifier());

/// Project loaded provider
final isProjectLoadedProvider = Provider(
  (ref) => ref.watch(projectProvider.select((p) => p.path.isNotEmpty)),
);

/// Project configuration provider
final projectConfigurationProvider = Provider(
  (ref) => ref.watch(projectProvider.select((p) => p.configuration)),
);

/// Form configuration provider (configuration being edited)
final formConfigurationProvider = StateProvider<L10nConfiguration>((ref) {
  final projectConfiguration = ref.watch(projectConfigurationProvider);
  return projectConfiguration.copyWith();
});

final resetConfigurationProvider = StateProvider<bool>((_) => false);

/// Recent projects provider
final recentProjectsProvider = StateProvider<List<Project>>(
  (_) => const [
    Project(id: 1, name: 'one', path: '/dev/flutter/cc.nogueira/one'),
    Project(id: 2, name: 'l10n', path: '/dev/flutter/cc.nogueira/l10n'),
    Project(id: 2, name: 'three', path: '/dev/flutter/cc.nogueira/test/prov/project/three-flutter'),
  ],
);

// -- Resources

/// EditResourceUsecase singleton provider
final resourceUsecaseProvider = Provider<ResourceUsecase>((ref) => ResourceUsecase(ref.read));

/// Selected resource provider
final selectedResourceProvider =
    StateNotifierProvider<SelectedResourceNotifier, ArbResourceDefinition?>(
        (_) => SelectedResourceNotifier());

final beingEditedResourcesProvider = StateNotifierProvider<BeingEditedResourcesNotifier,
    Map<ArbResourceDefinition, List<ArbResource>>>((_) => BeingEditedResourcesNotifier());

final beingEditedResourceDefinitionsProvider = StateNotifierProvider<
        BeingEditedResourceDefinitionsNotifier, Map<ArbResourceDefinition, ArbResourceDefinition>>(
    (_) => BeingEditedResourceDefinitionsNotifier());

final beingEditedTranslationsProvider = StateNotifierProvider.family<
    BeingEditedTranslationsNotifier,
    Map<ArbResource, ArbResource>,
    String>((_, locale) => BeingEditedTranslationsNotifier(locale));

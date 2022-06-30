import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../entity/arb/arb_definition.dart';
import '../entity/arb/arb_translation.dart';
import '../entity/preferences/display_option.dart';
import '../entity/preferences/language_option.dart';
import '../entity/project/l10n_configuration.dart';
import '../entity/project/project.dart';
import '../layer/domain_layer.dart';
import '../usecase/arb/arb_usecase.dart';
import '../usecase/preferences/preferences_usecase.dart';
import '../usecase/project/project_usecase.dart';

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

/// DisplayOption provider
final displayOptionProvider = StateNotifierProvider<DisplayOptionNotifier, DisplayOption>((ref) {
  final usecase = ref.read(preferencesUsecaseProvider);
  return DisplayOptionNotifier(usecase);
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

// -- Arb

/// ArbUsecase singleton provider
final arbUsecaseProvider = Provider<ArbUsecase>((ref) => ArbUsecase(ref.read));

/// Selected definitions provider
final selectedDefinitionProvider =
    StateNotifierProvider<SelectedDefinitionNotifier, ArbDefinition?>(
        (_) => SelectedDefinitionNotifier());

final currentDefinitionsProvider =
    StateNotifierProvider<DefinitionsNotifier, Map<ArbDefinition, ArbDefinition>>(
        (_) => DefinitionsNotifier());

final beingEditedDefinitionsProvider =
    StateNotifierProvider<DefinitionsNotifier, Map<ArbDefinition, ArbDefinition>>(
        (_) => DefinitionsNotifier());

final currentTranslationsForLanguageProvider = StateNotifierProvider.family<
    TranslationsForLanguageNotifier,
    Map<ArbDefinition, ArbTranslation>,
    String>((_, locale) => TranslationsForLanguageNotifier(locale));

final beingEditedTranslationLocalesProvider =
    StateNotifierProvider<TranslationLocalesNotifier, Map<ArbDefinition, Set<String>>>(
        (_) => TranslationLocalesNotifier());

final beingEditedTranslationsForLanguageProvider = StateNotifierProvider.family<
    TranslationsForLanguageNotifier,
    Map<ArbDefinition, ArbTranslation>,
    String>((_, locale) => TranslationsForLanguageNotifier(locale));

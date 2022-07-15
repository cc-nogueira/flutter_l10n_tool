import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../entity/arb/arb_definition.dart';
import '../entity/arb/arb_placeholder.dart';
import '../entity/arb/arb_translation.dart';
import '../entity/preferences/display_option.dart';
import '../entity/preferences/language_option.dart';
import '../entity/project/l10n_configuration.dart';
import '../entity/project/project.dart';
import '../entity/project/recent_project.dart';
import '../layer/domain_layer.dart';
import '../usecase/arb/arb_usecase.dart';
import '../usecase/preferences/preferences_usecase.dart';
import '../usecase/project/project_usecase.dart';
import '../usecase/project/recent_projects_usecase.dart';

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
final projectUsecaseProvider =
    Provider<ProjectUsecase>((ref) => ref.watch(domainLayerProvider).projectUsecase);

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

/// RecentProjectsUsecase singleton provider
final recentProjectsUsecaseProvider =
    Provider<RecentProjectsUsecase>((ref) => ref.watch(domainLayerProvider).recentProjectsUsecase);

/// Recent projects provider
final recentProjectsProvider = StateNotifierProvider<RecentProjectsNotifier, List<RecentProject>>(
  (ref) {
    final usecase = ref.read(recentProjectsUsecaseProvider);
    return RecentProjectsNotifier(usecase);
  },
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

/// Represents an existing placeholder currently being edited for a ArbDefinition.
///
/// It will be the initial value of the corresponding value in [formPlaceholdersProvider] for an
/// edit placeholder action.
/// When the Form value changes by user interaction these two values may differ, representing
/// pending changes in the form.
///
/// The value for a ArbDefinition will be null when no placeholder is being edited or when a new
/// placeholder is being edited in the user's form.
final existingPlaceholdersBeingEditedProvider =
    StateNotifierProvider<PlaceholdersNotifier, Map<ArbDefinition, ArbPlaceholder>>(
        (_) => PlaceholdersNotifier());

/// Form placeholders are the current value displayed and edited by the user for a ArbDefinition.
///
/// When editing an existing placeholder this value will be initialized with the corresponding
/// [existingPlaceholdersBeingEditedProvider].
/// When the Form value changes by user interaction these two values may differ, representing
/// pending changes in the form.
///
/// When editing a new placeholder this value will a new generic placeholder and no corresponding
/// entry will found in [existingPlaceholdersBeingEditedProvider].
final formPlaceholdersProvider =
    StateNotifierProvider<PlaceholdersNotifier, Map<ArbDefinition, ArbPlaceholder>>(
        (_) => PlaceholdersNotifier());

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

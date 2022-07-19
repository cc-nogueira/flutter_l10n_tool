import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../entity/project/recent_project.dart';
import '../layer/domain_layer.dart';
import '../usecase/arb/arb_usecase.dart';
import '../usecase/preferences/preferences_usecase.dart';
import '../usecase/project/project_usecase.dart';
import '../usecase/recent_projects/recent_projects_usecase.dart';

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

/// ProjectUsecase singleton provider
final projectUsecaseProvider =
    Provider<ProjectUsecase>((ref) => ref.watch(domainLayerProvider).projectUsecase);

/// RecentProjectsUsecase singleton provider
final recentProjectsUsecaseProvider =
    Provider<RecentProjectsUsecase>((ref) => ref.watch(domainLayerProvider).recentProjectsUsecase);

/// ArbUsecase singleton provider
final arbUsecaseProvider = Provider<ArbUsecase>((ref) => ArbUsecase(ref.read));

/// Recent projects provider
final recentProjectsProvider = StateNotifierProvider<RecentProjectsNotifier, List<RecentProject>>(
  (ref) {
    final usecase = ref.read(recentProjectsUsecaseProvider);
    return RecentProjectsNotifier(usecase);
  },
);

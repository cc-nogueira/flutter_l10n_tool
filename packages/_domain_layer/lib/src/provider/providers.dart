import 'dart:ui';

import 'package:riverpod/riverpod.dart';

import '../entity/project/project.dart';
import '../layer/domain_layer.dart';
import '../usecase/preferences_usecase.dart';
import '../usecase/project_usecase.dart';

/// Domain Layer provider
final domainLayerProvider = Provider((ref) => DomainLayer(read: ref.read));

/// Function provider for dependency configuration (implementation injection)
final domainConfigurationProvider = Provider<DomainConfiguration>(
    (ref) => ref.watch(domainLayerProvider.select((layer) => layer.configure)));

/// System locales obtained on main()
final systemLocalesProvider = StateProvider<List<Locale>>((ref) => []);

/// PreferencesUsecase singleton provider
final preferencesUsecaseProvider =
    Provider<PreferencesUsecase>((ref) => ref.watch(domainLayerProvider).preferencesUsecase);

/// ProjectUsecase singleton provider
final projectUsecaseProvider = Provider<ProjectUsecase>((ref) => ProjectUsecase(ref.read));

// -- Project

/// Current project provider
final projectProvider = StateNotifierProvider<ProjectNotifier, Project>((_) => ProjectNotifier());

/// Project loaded provider
final isProjectLoadedProvider = Provider(
  (ref) => ref.watch(projectProvider.select((p) => p.loaded)),
);

/// Project configuration provider
final projectConfigurationProvider = Provider(
  (ref) => ref.watch(projectProvider.select((p) => p.configuration)),
);

/// Recent projects provider
final recentProjectsProvider = StateProvider<List<Project>>(
  (_) => const [
    Project(id: 1, name: 'one', path: '/dev/flutter/cc.nogueira/one'),
    Project(id: 2, name: 'l10n', path: '/dev/flutter/cc.nogueira/l10n'),
    Project(id: 2, name: 'three', path: '/dev/flutter/cc.nogueira/test/prov/project/three-flutter'),
  ],
);

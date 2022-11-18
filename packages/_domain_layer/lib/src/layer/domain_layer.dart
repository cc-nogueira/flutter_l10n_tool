import 'package:_core_layer/core_layer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../provider/providers.dart';
import '../repository/preferences_repository.dart';
import '../repository/recent_projects_repository.dart';
import '../usecase/preferences/preferences_usecase.dart';
import '../usecase/project/project_usecase.dart';
import '../usecase/recent_projects/recent_projects_usecase.dart';

part 'domain_layer.g.dart';

/// Domain Layer provider
@Riverpod(keepAlive: true)
DomainLayer domainLayer(DomainLayerRef ref) => DomainLayer(ref: ref);

/// Function provider for dependency configuration (implementation injection)
@riverpod
DomainConfiguration domainConfiguration(DomainConfigurationRef ref) =>
    ref.watch(domainLayerProvider).configure;

/// Function definition for Domain Layer dependencies
typedef DomainConfiguration = void Function({
  required PreferencesRepository preferencesRepository,
  required RecentProjectsRepository recentProjectsRepository,
});

/// DomainLayer has the responsibility to provide domain usecases.
///
/// To fullfill this responsibility DomainLayer requires its configuration to be
/// invoked before any usecase is accessed. Configuration is usually done during
/// DILayer's init() method.
///
/// DomainLayer configuration is also available through [domainConfigurationProvider].
///
/// Domains usecases are available through usecase providers:
class DomainLayer extends AppLayer with WidgetsBindingObserver {
  /// Constructor.
  ///
  /// Required a Riverpod Reader to instantite the [PreferencesUsecase].
  DomainLayer({required this.ref});

  /// Internal reader
  @internal
  final Ref ref;

  /// Configured [PreferencesUsecase] singleton.
  late final PreferencesUsecase preferencesUsecase;

  /// Configured [ProjectUsecase] singleton.
  late final ProjectUsecase projectUsecase;

  /// Configured [RecentProjectsUsecase] singleton.
  late final RecentProjectsUsecase recentProjectsUsecase;

  /// Initialize the DomainLayer.
  ///
  /// Intializes the systemLocalesProvider state and register this layer object as a
  /// WidgetsBindings observer to keep this provider always up to date with system locale changes.
  @override
  Future<void> init() {
    final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
    ref.read(systemLocalesProvider.notifier).state = systemLocales;

    WidgetsBinding.instance.addObserver(this);

    return SynchronousFuture(null);
  }

  /// Handle system locales changes.
  ///
  /// Keep the systemLocalesProvier up to date with the system locales.
  @override
  void didChangeLocales(List<Locale>? locales) {
    if (locales != null) {
      ref.read(systemLocalesProvider.notifier).state = locales;
    }
  }

  void configure({
    required PreferencesRepository preferencesRepository,
    required RecentProjectsRepository recentProjectsRepository,
  }) {
    preferencesUsecase = PreferencesUsecase(ref: ref, repository: preferencesRepository);
    recentProjectsUsecase =
        RecentProjectsUsecase(ref: ref, recentProjectsRepository: recentProjectsRepository);
    projectUsecase = ProjectUsecase(ref: ref, recentProjectsUsecase: recentProjectsUsecase);
  }
}

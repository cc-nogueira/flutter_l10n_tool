import 'package:_core_layer/core_layer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../provider/providers.dart';
import '../repository/preferences_repository.dart';
import '../usecase/preferences_usecase.dart';

/// Function definition for Domain Layer dependencies
typedef DomainConfiguration = void Function({
  required PreferencesRepository preferencesRepository,
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
  DomainLayer({required this.read});

  /// Internal reader
  @internal
  final Reader read;

  /// Configured [PreferencesUsecase] singleton.
  late final PreferencesUsecase preferencesUsecase;

  /// Initialize the DomainLayer.
  ///
  /// Intializes the systemLocalesProvider state and register this layer object as a
  /// WidgetsBindings observer to keep this provider always up to date with system locale changes.
  @override
  Future<void> init() {
    final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
    read(systemLocalesProvider.notifier).state = systemLocales;

    WidgetsBinding.instance.addObserver(this);

    return SynchronousFuture(null);
  }

  /// Handle system locales changes.
  ///
  /// Keep the systemLocalesProvier up to date with the system locales.
  @override
  void didChangeLocales(List<Locale>? locales) {
    if (locales != null) {
      read(systemLocalesProvider.notifier).state = locales;
    }
  }

  void configure({required PreferencesRepository preferencesRepository}) {
    preferencesUsecase = PreferencesUsecase(read: read, repository: preferencesRepository);
  }
}

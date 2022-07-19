import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../layer/domain_layer.dart';

/// Domain Layer provider
final domainLayerProvider = Provider((ref) => DomainLayer(read: ref.read));

/// Function provider for dependency configuration (implementation injection)
final domainConfigurationProvider = Provider<DomainConfiguration>(
    (ref) => ref.watch(domainLayerProvider.select((layer) => layer.configure)));

/// System locales obtained on main()
final systemLocalesProvider = StateProvider<List<Locale>>((ref) => []);

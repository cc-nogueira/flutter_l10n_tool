import 'package:_core_layer/core_layer.dart';
import 'package:_data_layer/data_layer.dart';
import 'package:_domain_layer/domain_layer.dart';
import 'package:_presentation_layer/presentation_layer.dart';
import 'package:meta/meta.dart';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'di_layer.g.dart';

/// DI Layer provider
@riverpod
DiLayer diLayer(DiLayerRef ref) {
  final diLayer = DiLayer(ref);
  ref.onDispose(() => diLayer.dispose());
  return diLayer;
}

/// Dependency Injection layer.
///
/// This layers is responsible for init() and dispose() of all other layers.
/// It is also responsible for layer configuration injecting interface
/// implementations into layers configuration functions.
///
/// This layer object should be initialized in main(), something like this:
///
/// void main() => runApp
///       ProviderScope(
///         child: Consumer(
///           builder: (_, ref, __) => ref.watch(_appProvider).when(
///                 loading: () => const Center(child: CircularProgressIndicator()),
///                 data: (app) => app,
///                 error: (error, _) => ExampleApp.error(error),
///               ),
///         ),
///       ),
///     );
///
/// final _appProvider = FutureProvider.autoDispose<Widget>((ref) async {
///   final diLayer = ref.watch(diLayerProvider);
///   await diLayer.init();
///   return const ExampleApp();
/// });
///
/// The DILayer instance should be accessed through diLayerProvider.
/// And in tests it may be instatiated using a ProviderContainer, like this:
///
/// late DILayer diLayer;
///
/// setUp(() {
///   final container = ProviderContainer();
///   addTearDown(container.dispose);
///   diLayer = DILayer(read: container.read);
/// });
class DiLayer extends AppLayer {
  DiLayer(this.ref);

  @internal
  final Ref ref;

  @internal
  final layerProviders = [
    coreLayerProvider,
    domainLayerProvider,
    dataLayerProvider,
    presentationLayerProvider,
  ];

  /// Init all layers and configure those that requires dependency injections.
  @override
  Future<void> init() async {
    for (final layerProvider in layerProviders) {
      await ref.read(layerProvider).init();
    }
    _configureDomainLayer();
  }

  /// Dispose all layers.
  @override
  void dispose() {
    for (final layerProvider in layerProviders.reversed) {
      ref.read(layerProvider).dispose();
    }
  }

  /// Configure domain layer with required implementations.
  void _configureDomainLayer() {
    final domainConfiguration = ref.read(domainConfigurationProvider);
    domainConfiguration(
      preferencesRepository: ref.read(preferencesRepositoryProvider),
      recentProjectsRepository: ref.read(recentProjectsRepositoryProvider),
    );
  }
}

import 'package:riverpod/riverpod.dart';

import '../layer/data_layer.dart';

/// Data Layer provider
final dataLayerProvider = Provider((_) => DataLayer());

/// PreferencesRepositoy implementation provider
final preferencesRepositoryProvider =
    Provider((ref) => ref.watch(dataLayerProvider).preferencesRepository);

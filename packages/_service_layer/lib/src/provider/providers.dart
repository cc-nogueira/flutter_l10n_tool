import 'package:riverpod/riverpod.dart';

import '../layer/service_layer.dart';

/// Layer provider
final serviceLayerProvider = Provider((_) => const ServiceLayer());

import 'package:_core_layer/core_layer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'presentation_layer.g.dart';

@Riverpod(keepAlive: true)
AppLayer presentationLayer(PresentationLayerRef ref) => const AppLayer();

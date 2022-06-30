import 'dart:io';

import 'package:_di_layer/di_layer.dart';
import 'package:_presentation_layer/presentation_layer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    doWhenWindowReady(() {
      const min = Size(800, 560);
      const initial = Size(1280, 720);
      final win = appWindow;
      win.minSize = min;
      win.size = initial;
      win.alignment = Alignment.topRight;
      win.title = "L10n";
      win.show();
    });
  }

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (_, ref, __) => ref.watch(appProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (app) => app,
              error: (error, _) => L10nApp.error(error),
            ),
      ),
    ),
  );
}

/// Provides the configured application.
///
/// Async initializes all layers through DI Layer init method.
final appProvider = FutureProvider.autoDispose<Widget>((ref) async {
  final diLayer = ref.watch(diLayerProvider);
  await diLayer.init();

  const app = L10nApp();
  return app;
});

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';

class CloseProjectButton extends ConsumerWidget {
  const CloseProjectButton({super.key, required this.style});

  final ButtonStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectLoaded = ref.watch(isProjectLoadedProvider);
    final loc = AppLocalizations.of(context);
    return TextButton.icon(
      style: style,
      icon: const Icon(Icons.close),
      label: Text(loc.label_close_project),
      onPressed: projectLoaded ? () => _onPressed(ref) : null,
    );
  }

  void _onPressed(WidgetRef ref) => ref.read(projectUsecaseProvider).closeProject();
}

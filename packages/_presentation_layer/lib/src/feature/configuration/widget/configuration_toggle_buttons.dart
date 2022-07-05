import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';

class ConfigurationToggleButtons extends ConsumerWidget {
  const ConfigurationToggleButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(formConfigurationProvider);
    return _ConfigurationToggleButtons(
      formConfigurationController: ref.watch(formConfigurationProvider.notifier),
      resetConfigurationController: ref.watch(resetConfigurationProvider.notifier),
    );
  }
}

class _ConfigurationToggleButtons extends StatelessWidget {
  const _ConfigurationToggleButtons({
    required this.formConfigurationController,
    required this.resetConfigurationController,
  });

  final StateController<L10nConfiguration> formConfigurationController;
  final StateController<bool> resetConfigurationController;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final configuration = formConfigurationController.state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.start,
          text: 'Default',
          onPressed: _onDefaultPressed,
          selected: configuration.isDefault,
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.center,
          text: 'RCMdd',
          onPressed: _onRecommendedPressed,
          selected: configuration.isRecommended,
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.end,
          text: 'Custom',
          onPressed: _onCustomPressed,
          selected: configuration.isCustom,
        ),
      ],
    );
  }

  void _onDefaultPressed() {
    formConfigurationController.state = const L10nConfiguration();
    resetConfigurationController.update((state) => !state);
  }

  void _onRecommendedPressed() {
    formConfigurationController.state = L10nConfiguration.recommended();
    resetConfigurationController.update((state) => !state);
  }

  void _onCustomPressed() => formConfigurationController.update(
        (state) => state.copyWith(markedCustom: true),
      );
}

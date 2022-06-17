import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';

class ProjectConfigurationButtons extends ConsumerWidget {
  const ProjectConfigurationButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ProjectConfigurationButtons(
      configuration: ref.watch(projectConfigurationProvider),
      formConfigurationController: ref.watch(formConfigurationProvider.notifier),
    );
  }
}

class _ProjectConfigurationButtons extends StatelessWidget {
  const _ProjectConfigurationButtons({
    required this.configuration,
    required this.formConfigurationController,
  });

  final L10nConfiguration configuration;
  final StateController<L10nConfiguration> formConfigurationController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _doSomethingButton(),
      ],
    );
  }

  Widget _doSomethingButton() => outlinedButton(text: 'Do something', onPressed: null);
}

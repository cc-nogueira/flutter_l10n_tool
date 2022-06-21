import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../page/load_project_dialog.dart';

class ProjectConfigurationButtons extends ConsumerWidget {
  const ProjectConfigurationButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ProjectConfigurationButtons(
      read: ref.read,
      currentConfiguration: ref.watch(projectConfigurationProvider),
      formConfiguration: ref.watch(formConfigurationProvider),
    );
  }
}

class _ProjectConfigurationButtons extends StatelessWidget {
  const _ProjectConfigurationButtons({
    required this.read,
    required this.currentConfiguration,
    required this.formConfiguration,
  });

  final Reader read;
  final L10nConfiguration currentConfiguration;
  final L10nConfiguration formConfiguration;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isModified = currentConfiguration != formConfiguration;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _discardButton(isModified),
          const SizedBox(width: 16),
          _confirmButton(context, loc, isModified),
          const SizedBox(width: 4.0),
        ],
      ),
    );
  }

  Widget _discardButton(bool isModified) => textButton(
      text: 'Discard Changes',
      onPressed: isModified
          ? () => read(formConfigurationProvider.notifier).state = currentConfiguration
          : null);

  Widget _confirmButton(BuildContext context, AppLocalizations loc, bool isModified) => textButton(
      text: 'Confirm',
      onPressed: isModified
          ? () async {
              final usecase = read(projectUsecaseProvider);
              await usecase.saveConfiguration(formConfiguration);
              showDialog<void>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) =>
                    LoadProjectDialog(read(projectProvider).path, loc),
              );
            }
          : null);
}

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/navigation/navigation_drawer_option.dart';
import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_mixin.dart';
import '../../../l10n/app_localizations.dart';
import '../../../provider/presentation_providers.dart';

class ShowProjectLoadingDialog extends ConsumerWidget {
  const ShowProjectLoadingDialog({super.key});

  static const _contentInsets = EdgeInsets.symmetric(horizontal: 24);
  static const _buttonRowInsets = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadStage = ref.watch(projectProvider.select((project) => project.loadStage));
    final project = ref.read(projectProvider);
    final loc = AppLocalizations.of(context);
    if (loadStage.isFinal) {
      _postFrameClose(context, ref.read);
    }
    final colors = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 24.0),
        backgroundColor: colors.background,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(context, loc, project),
            _progressIndicator(loadStage),
            FormMixin.verticalSeparator,
            _progressDescription(context, loc, project, loadStage),
            const SizedBox(height: 40),
            _dialogButtons(ref.read, colors, loadStage),
            FormMixin.verticalSeparator,
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context, AppLocalizations loc, Project project) {
    final theme = Theme.of(context).textTheme;
    final usingYamlFile = project.configuration.usingYamlFile;
    final text =
        usingYamlFile ? loc.message_loading_with_yaml_conf : loc.message_loading_without_yaml_conf;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      constraints: const BoxConstraints(minWidth: 400.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.message_loading, style: theme.headlineSmall),
          const SizedBox(height: 8),
          Text(text),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Padding _progressIndicator(LoadStage loadStage) {
    return Padding(
      padding: _contentInsets,
      child: LinearProgressIndicator(value: loadStage.percent),
    );
  }

  Widget _progressDescription(
      BuildContext context, AppLocalizations loc, Project project, LoadStage loadStage) {
    return Padding(
      padding: _contentInsets,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loadStage == LoadStage.error)
                Text(project.l10nException?.message(context) ?? 'Error loading project.')
              else
                _stageDescription(loc, loadStage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stageDescription(AppLocalizations loc, LoadStage loadStage) =>
      Text(loc.message_loading_stage(loadStage.description));

  Widget _dialogButtons(Reader read, ColorScheme colors, LoadStage loadStage) {
    final List<Widget> okCancelButtons = [
      textButton(text: 'Cancel', onPressed: loadStage.complete ? null : () => _cancelLoading(read)),
    ];

    return Padding(
      padding: _buttonRowInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: okCancelButtons,
      ),
    );
  }

  void _cancelLoading(Reader read) {
    read(projectUsecaseProvider).cancelLoading();
  }

  void _postFrameClose(BuildContext context, Reader read) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (read(projectProvider).hasNoError &&
          read(activeNavigationProvider) == NavigationDrawerTopOption.projectSelector) {
        read(activeNavigationProvider.notifier).state = NavigationDrawerTopOption.resources;
      }
      Navigator.pop(context);
    });
  }
}

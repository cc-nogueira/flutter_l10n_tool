import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../common/fix_stage.dart';

Future<void> showFixLoadingErrorDialog(
  BuildContext context,
  AppLocalizations loc, {
  required String title,
  required String fixDescription,
  required L10nExceptionCallback fixCallback,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => FixLoadingErrorDialog(loc,
        title: title, fixDescription: fixDescription, fixCallback: fixCallback),
  );
}

class FixLoadingErrorDialog extends ConsumerStatefulWidget {
  const FixLoadingErrorDialog(
    this.loc, {
    required this.title,
    required this.fixDescription,
    required this.fixCallback,
    super.key,
  });

  final AppLocalizations loc;
  final String title;
  final String fixDescription;
  final L10nExceptionCallback fixCallback;

  @override
  ConsumerState<FixLoadingErrorDialog> createState() => _FixLoadingErrorDialogState();
}

class _FixLoadingErrorDialogState extends ConsumerState<FixLoadingErrorDialog> {
  static const _contentInsets = EdgeInsets.symmetric(horizontal: 24);
  static const _buttonRowInsets = EdgeInsets.symmetric(horizontal: 16);
  late FixStage _fixStage;

  @override
  void initState() {
    super.initState();
    _fixStage = FixStage.initial;
  }

  void _runStageAction(BuildContext context) {
    if (_fixStage.waiting || _fixStage.complete) {
      return;
    }
    switch (_fixStage) {
      case FixStage.initial:
        _fixAction();
        break;
      default:
    }
  }

  Future<void> _fixAction() async {
    _setStage(FixStage.fixing);
    try {
      await widget.fixCallback();
    } catch (e) {
      _setStage(FixStage.error);
    }
    _setStage(FixStage.done);
  }

  @override
  Widget build(BuildContext context) {
    _runStageAction(context);
    final colors = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 24.0),
        backgroundColor: colors.background,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(context),
            _progressIndicator(),
            const SizedBox(height: 16),
            _progressDescription(),
            const SizedBox(height: 40),
            _dialogButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      constraints: const BoxConstraints(minWidth: 400.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: theme.headlineSmall),
          const SizedBox(height: 8),
          Text(widget.fixDescription),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Padding _progressIndicator() {
    return Padding(
      padding: _contentInsets,
      child: LinearProgressIndicator(value: _fixStage.complete ? 1.0 : null),
    );
  }

  Widget _progressDescription() {
    return Padding(
      padding: _contentInsets,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_fixStage == FixStage.error)
                const Text('Error trying to fix project.')
              else
                _stageDescription,
            ],
          ),
        ],
      ),
    );
  }

  Widget get _stageDescription => Text(widget.loc.message_fixing_stage(_fixStage.description));

  Widget _dialogButtons() {
    final List<Widget> buttons = [
      textButton(
          text: 'Continue', onPressed: _fixStage.complete ? () => Navigator.pop(context) : null),
    ];

    return Padding(
      padding: _buttonRowInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: buttons,
      ),
    );
  }

  void _setStage(FixStage stage) {
    setState(() => _fixStage = stage);
  }
}

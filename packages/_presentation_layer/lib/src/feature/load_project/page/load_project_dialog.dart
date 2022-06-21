import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../../../provider/presentation_providers.dart';
import '../../navigation/common/navigation_drawer_option.dart';
import '../common/load_stage.dart';

class LoadProjectDialog extends ConsumerStatefulWidget {
  const LoadProjectDialog(this.projectPath, this.loc, {super.key});

  final String projectPath;
  final AppLocalizations loc;

  @override
  ConsumerState<LoadProjectDialog> createState() => _LoadProjectDialogState();
}

class _LoadProjectDialogState extends ConsumerState<LoadProjectDialog> {
  static const _contentInsets = EdgeInsets.symmetric(horizontal: 24);
  static const _buttonRowInsets = EdgeInsets.symmetric(horizontal: 16);
  static const _progressWait = Duration(milliseconds: 100);

  late ProjectUsecase _projectUsecase;
  late LoadStage _loadStage;
  String? _error;

  @override
  void initState() {
    _loadStage = LoadStage.initial;
    super.initState();
  }

  void _keepLoading(BuildContext context) {
    if (_loadStage.waiting) {
      return;
    }
    if (_loadStage.finished) {
      _postFrameClose();
    }
    switch (_loadStage) {
      case LoadStage.initial:
        _initProject();
        _readPubspec();
        break;
      case LoadStage.doneReadingPubspec:
        _defineConfiguration();
        break;
      case LoadStage.doneDefiningConfiguration:
        _readTemplateFile();
        break;
      case LoadStage.doneReadingResourceDefinitions:
        _readTranslationFiles();
        break;
      default:
    }
  }

  void _initProject() async {
    await Future.delayed(_progressWait);
    _projectUsecase.initProject(projectPath: widget.projectPath);
  }

  void _readPubspec() async {
    await Future.delayed(_progressWait);
    _setStage(LoadStage.readingPubspec);
    try {
      await _projectUsecase.loadPubspec();
      _setStage(LoadStage.doneReadingPubspec);
    } on L10nException catch (e) {
      _handleL10nException(e);
    } catch (e) {
      _handleException(e);
    }
  }

  void _defineConfiguration() async {
    await Future.delayed(_progressWait);
    _setStage(LoadStage.definingConfiguration);
    try {
      await _projectUsecase.defineConfiguration();
      _setStage(LoadStage.doneDefiningConfiguration);
    } on L10nException catch (e) {
      _handleL10nException(e);
    } catch (e) {
      _handleException(e);
    }
  }

  void _readTemplateFile() async {
    await Future.delayed(_progressWait);
    _setStage(LoadStage.readingResourceDefinitions);
    try {
      await _projectUsecase.readTemplateFile();
      _setStage(LoadStage.doneReadingResourceDefinitions);
    } on L10nException catch (e) {
      _handleL10nException(e);
    } catch (e) {
      _handleException(e);
    }
  }

  void _readTranslationFiles() async {
    await Future.delayed(_progressWait);
    _setStage(LoadStage.readingTranslations);
    try {
      await _projectUsecase.readTranslationFiles();
      _setStage(LoadStage.doneReadingTranslations);
    } on L10nException catch (e) {
      _handleL10nException(e);
    } catch (e) {
      _handleException(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _projectUsecase = ref.watch(projectUsecaseProvider);
    final colors = Theme.of(context).colorScheme;
    _keepLoading(context);
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
            _dialogButtons(colors),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final usingYamlFile = ref.watch(
      projectConfigurationProvider.select((conf) => conf.usingYamlFile),
    );
    final text = usingYamlFile
        ? widget.loc.message_loading_with_yaml_conf
        : widget.loc.message_loading_without_yaml_conf;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      constraints: const BoxConstraints(minWidth: 400.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.loc.message_loading, style: theme.headlineSmall),
          const SizedBox(height: 8),
          Text(text),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Padding _progressIndicator() {
    return Padding(
      padding: _contentInsets,
      child: LinearProgressIndicator(value: _loadStage.percent),
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
              if (_loadStage == LoadStage.error)
                Text(_error ?? 'Error loading project.')
              else
                _stageDescription,
            ],
          ),
        ],
      ),
    );
  }

  Widget get _stageDescription => Text(widget.loc.message_loading_stage(_loadStage.description));

  Widget _dialogButtons(ColorScheme colors) {
    final List<Widget> okCancelButtons = [
      textButton(text: 'Cancel', onPressed: _loadStage.finished ? null : _cancelLoading),
    ];

    return Padding(
      padding: _buttonRowInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: okCancelButtons,
      ),
    );
  }

  void _setStage(LoadStage stage) {
    if (_loadStage != LoadStage.canceled) {
      setState(() => _loadStage = stage);
    }
  }

  void _handleL10nException(L10nException e) {
    _setError(e.message(context));
  }

  void _handleException(Object e) {
    _setError(e.toString());
  }

  void _setError(String message) {
    if (_loadStage != LoadStage.canceled) {
      setState(() {
        _loadStage = LoadStage.error;
        _error = message;
      });
    }
  }

  void _cancelLoading() {
    _setStage(LoadStage.canceled);
    Navigator.pop(context);
  }

  void _postFrameClose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(projectProvider).hasNoError &&
          ref.read(activeNavigationProvider) == NavigationDrawerTopOption.projectSelector) {
        ref.read(activeNavigationProvider.notifier).state = null;
      }
      Navigator.pop(context);
    });
  }
}

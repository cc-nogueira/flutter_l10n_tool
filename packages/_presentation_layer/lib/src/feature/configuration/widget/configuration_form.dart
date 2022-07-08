import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/label_divider.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../../../l10n/app_localizations.dart';
import 'configuration_form_dropdown.dart';

class ConfigurationForm extends ConsumerWidget {
  const ConfigurationForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(resetConfigurationProvider);
    final currentConfiguration = ref.watch(projectConfigurationProvider);
    final loc = AppLocalizations.of(context);
    final controller = ref.watch(formConfigurationProvider.notifier);
    return _ConfigurationForm(loc, currentConfiguration, controller);
  }
}

class _ConfigurationForm extends StatefulWidget {
  const _ConfigurationForm(this.loc, this.currentConfiguration, this.configurationController);

  final AppLocalizations loc;
  final L10nConfiguration currentConfiguration;
  final StateController<L10nConfiguration> configurationController;

  @override
  State<_ConfigurationForm> createState() => _ConfigurationFormState();

  L10nConfiguration get configuration => configurationController.state;

  set configuration(L10nConfiguration configuration) =>
      configurationController.state = configuration;
}

class _ConfigurationFormState extends State<_ConfigurationForm> with TextFormFieldMixin {
  late final TextEditingController _arbDirTextController;
  late final TextEditingController _outputDirTextController;
  late final TextEditingController _templateArbFileTextController;
  late final TextEditingController _outputLocalizationFileTextController;
  late final TextEditingController _outputClassTextController;
  late final TextEditingController _headerTextController;

  final FocusNode _arbDirFocus = FocusNode();
  final FocusNode _templateArbFileFocus = FocusNode();
  final FocusNode _requiredAttibutesFocus = FocusNode();
  final FocusNode _syntheticPackageFocus = FocusNode();
  final FocusNode _outputDirFocus = FocusNode();
  final FocusNode _outputLocalizationFocus = FocusNode();
  final FocusNode _outputClassFocus = FocusNode();
  final FocusNode _nullableGetterFocus = FocusNode();
  final FocusNode _headerFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _arbDirTextController = TextEditingController(text: widget.configuration.arbDir);
    _outputDirTextController = TextEditingController(text: widget.configuration.outputDir);
    _templateArbFileTextController =
        TextEditingController(text: widget.configuration.templateArbFile);
    _outputLocalizationFileTextController =
        TextEditingController(text: widget.configuration.outputLocalizationFile);
    _outputClassTextController = TextEditingController(text: widget.configuration.outputClass);
    _headerTextController = TextEditingController(text: widget.configuration.header);
  }

  @override
  void didUpdateWidget(covariant _ConfigurationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reconfigureTextControllers());
  }

  void _reconfigureTextControllers() {
    _arbDirTextController.text = widget.configuration.arbDir;
    _outputDirTextController.text = widget.configuration.outputDir;
    _templateArbFileTextController.text = widget.configuration.templateArbFile;
    _outputLocalizationFileTextController.text = widget.configuration.outputLocalizationFile;
    _outputClassTextController.text = widget.configuration.outputClass;
    _headerTextController.text = widget.configuration.header;
    setState(() {});
  }

  @override
  void dispose() {
    _arbDirTextController.dispose();
    _templateArbFileTextController.dispose();
    _outputDirTextController.dispose();
    _outputLocalizationFileTextController.dispose();
    _outputClassTextController.dispose();
    _headerTextController.dispose();
    _arbDirFocus.dispose();
    _templateArbFileFocus.dispose();
    _requiredAttibutesFocus.dispose();
    _syntheticPackageFocus.dispose();
    _outputDirFocus.dispose();
    _outputLocalizationFocus.dispose();
    _outputClassFocus.dispose();
    _nullableGetterFocus.dispose();
    _headerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _fields(context);
  }

  Widget _fields(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelDivider(
          padding: const EdgeInsets.only(bottom: 16),
          color: colors.onBackground,
          label: const Text('Input'),
          separation: 8,
        ),
        textField(
          context: context,
          label: 'arb folder',
          hintText: L10nConfiguration.defaultArbDir,
          textController: _arbDirTextController,
          focusNode: _arbDirFocus,
          nextFocus: _templateArbFileFocus,
          originalText: widget.currentConfiguration.arbDir,
          onChanged: (value) => setState(
            () => widget.configurationController.update((state) => state.copyWith(arbDir: value)),
          ),
        ),
        FormMixin.verticalSeparator,
        textField(
          context: context,
          label: 'template file',
          hintText: L10nConfiguration.defaultTemplateArbFile,
          textController: _templateArbFileTextController,
          focusNode: _templateArbFileFocus,
          nextFocus: _requiredAttibutesFocus,
          originalText: widget.currentConfiguration.templateArbFile,
          onChanged: (value) => setState(
            () => widget.configurationController
                .update((state) => state.copyWith(templateArbFile: value)),
          ),
        ),
        FormMixin.verticalSeparator,
        ConfigurationFormDropdown<bool>(
          label: 'required attributes',
          options: const [true, false],
          optionLabel: (value) =>
              value ? 'require attribute to all resources' : 'don\'t require resource attributes',
          currentValue: () => widget.currentConfiguration.requiredResourceAttributes,
          formValue: () => widget.configuration.requiredResourceAttributes,
          setValue: (value) => setState(
            () => widget.configurationController
                .update((state) => state.copyWith(requiredResourceAttributes: value ?? false)),
          ),
          focusNode: _requiredAttibutesFocus,
        ),
        LabelDivider(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          color: colors.onBackground,
          label: const Text('Output'),
          separation: 8,
        ),
        ConfigurationFormDropdown<bool>(
          label: 'synthetic package',
          options: const [true, false],
          optionLabel: (value) => value ? 'use synthetic package' : 'use output folder',
          currentValue: () => widget.currentConfiguration.syntheticPackage,
          formValue: () => widget.configuration.syntheticPackage,
          setValue: (value) => setState(
            () => widget.configurationController
                .update((state) => state.copyWith(syntheticPackage: value ?? true)),
          ),
          focusNode: _syntheticPackageFocus,
        ),
        FormMixin.verticalSeparator,
        textField(
          context: context,
          enabled: !widget.configuration.syntheticPackage,
          label: 'output folder',
          hintText: widget.configuration.syntheticPackage
              ? '.dart_tool/flutter_gen/gen_l10n'
              : _arbDirTextController.text.isEmpty
                  ? L10nConfiguration.defaultArbDir
                  : _arbDirTextController.text,
          textController: _outputDirTextController,
          focusNode: _outputDirFocus,
          nextFocus: _outputLocalizationFocus,
          originalText: widget.currentConfiguration.outputDir,
          onChanged: (value) => setState(
            () =>
                widget.configurationController.update((state) => state.copyWith(outputDir: value)),
          ),
        ),
        FormMixin.verticalSeparator,
        textField(
          context: context,
          label: 'output file',
          hintText: L10nConfiguration.defaultOutputLocalizationFile,
          textController: _outputLocalizationFileTextController,
          focusNode: _outputLocalizationFocus,
          nextFocus: _outputClassFocus,
          originalText: widget.currentConfiguration.outputLocalizationFile,
          onChanged: (value) => setState(
            () => widget.configurationController
                .update((state) => state.copyWith(outputLocalizationFile: value)),
          ),
        ),
        FormMixin.verticalSeparator,
        textField(
          context: context,
          label: 'output class',
          hintText: L10nConfiguration.defaultOutputClass,
          textController: _outputClassTextController,
          focusNode: _outputClassFocus,
          nextFocus: _nullableGetterFocus,
          originalText: widget.currentConfiguration.outputClass,
          onChanged: (value) => setState(
            () => widget.configurationController
                .update((state) => state.copyWith(outputClass: value)),
          ),
        ),
        LabelDivider(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          color: colors.onBackground,
          label: const Text('Generation'),
          separation: 8,
        ),
        ConfigurationFormDropdown<bool>(
          label: 'nullable getter',
          options: const [true, false],
          optionLabel: (value) =>
              value ? 'generate nullable getter' : 'generate non nullable getter',
          currentValue: () => widget.currentConfiguration.nullableGetter,
          formValue: () => widget.configuration.nullableGetter,
          setValue: (value) => setState(
            () => widget.configurationController
                .update((state) => state.copyWith(nullableGetter: value ?? true)),
          ),
          focusNode: _nullableGetterFocus,
        ),
        FormMixin.verticalSeparator,
        textField(
          context: context,
          label: 'header',
          textController: _headerTextController,
          focusNode: _headerFocus,
          nextFocus: _arbDirFocus,
          maxLines: null,
          originalText: widget.currentConfiguration.header,
          onChanged: (value) => setState(
            () => widget.configurationController.update((state) => state.copyWith(header: value)),
          ),
        ),
      ],
    );
  }
}

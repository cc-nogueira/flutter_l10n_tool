import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/label_divider.dart';
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

class _ConfigurationFormState extends State<_ConfigurationForm> {
  late final TextEditingController _arbDirTextController;
  late final TextEditingController _outputDirTextController;
  late final TextEditingController _templateArbFileTextController;
  late final TextEditingController _outputLocalizationFileTextController;
  late final TextEditingController _outputClassTextController;
  late final TextEditingController _headerTextController;

  final FocusNode _arbDirFocus = FocusNode();
  final FocusNode _outputDirFocus = FocusNode();
  final FocusNode _templateArbFileFocus = FocusNode();
  final FocusNode _outputLocalizationFocus = FocusNode();
  final FocusNode _outputClassFocus = FocusNode();
  final FocusNode _headerFocus = FocusNode();

  final _verticalSeparator = const SizedBox(height: 16);

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
    _outputDirTextController.dispose();
    _templateArbFileTextController.dispose();
    _outputLocalizationFileTextController.dispose();
    _outputClassTextController.dispose();
    _headerTextController.dispose();
    _arbDirFocus.dispose();
    _outputDirFocus.dispose();
    _templateArbFileFocus.dispose();
    _outputLocalizationFocus.dispose();
    _outputClassFocus.dispose();
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
        _formField(
          context,
          colors,
          'arb folder',
          _arbDirTextController,
          currentValue: widget.currentConfiguration.arbDir,
          hintText: L10nConfiguration.defaultArbDir,
          focusNode: _arbDirFocus,
          nextFocus: _outputDirFocus,
        ),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'template file',
          _templateArbFileTextController,
          currentValue: widget.currentConfiguration.templateArbFile,
          hintText: L10nConfiguration.defaultTemplateArbFile,
          focusNode: _templateArbFileFocus,
          nextFocus: _outputLocalizationFocus,
        ),
        _verticalSeparator,
        RequiredResouceAttributesDropdown(loc: widget.loc),
        LabelDivider(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          color: colors.onBackground,
          label: const Text('Output'),
          separation: 8,
        ),
        UseSyntheticPackageDropdown(loc: widget.loc),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'output folder',
          _outputDirTextController,
          currentValue: widget.currentConfiguration.outputDir,
          hintText: _arbDirTextController.text.isEmpty
              ? L10nConfiguration.defaultArbDir
              : _arbDirTextController.text,
          focusNode: _outputDirFocus,
          nextFocus: _templateArbFileFocus,
        ),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'output file',
          _outputLocalizationFileTextController,
          currentValue: widget.currentConfiguration.outputLocalizationFile,
          hintText: L10nConfiguration.defaultOutputLocalizationFile,
          focusNode: _outputLocalizationFocus,
          nextFocus: _outputClassFocus,
        ),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'output class',
          _outputClassTextController,
          currentValue: widget.currentConfiguration.outputClass,
          hintText: L10nConfiguration.defaultOutputClass,
          focusNode: _outputClassFocus,
          nextFocus: _headerFocus,
        ),
        LabelDivider(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          color: colors.onBackground,
          label: const Text('Generation'),
          separation: 8,
        ),
        NullableGetterDropdown(loc: widget.loc),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'header',
          _headerTextController,
          currentValue: widget.currentConfiguration.header,
          focusNode: _headerFocus,
          nextFocus: _arbDirFocus,
          maxLines: null,
        ),
      ],
    );
  }

  Widget _formField(
    BuildContext context,
    ColorScheme colors,
    String label,
    TextEditingController controller, {
    String? currentValue,
    String? hintText,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    String? Function(String?)? validator,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool readOnly = false,
    bool enabled = true,
    int? maxLines = 1,
  }) {
    final isModified = currentValue != null && currentValue != controller.text;
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      enabled: enabled,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 0.0),
        border: const OutlineInputBorder(),
        enabledBorder: _enabledBorder(colors, isModified),
        focusedBorder: _focusedBorder(colors, isModified),
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        counterText: '',
      ),
      maxLength: maxLength,
      onChanged: (_) => _onFormChanged(),
      validator: validator,
      focusNode: focusNode,
      onEditingComplete: nextFocus == null ? null : () => _focusNext(context, focusNode, nextFocus),
      textInputAction: nextFocus == null ? TextInputAction.done : TextInputAction.next,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
    );
  }

  void _onFormChanged() => setState(() {
        widget.configuration = L10nConfiguration(
          syntheticPackage: widget.configuration.syntheticPackage,
          arbDir: _arbDirTextController.text,
          outputDir: _outputDirTextController.text,
          templateArbFile: _templateArbFileTextController.text,
          outputLocalizationFile: _outputLocalizationFileTextController.text,
          outputClass: _outputClassTextController.text,
          header: _headerTextController.text,
          nullableGetter: widget.configuration.nullableGetter,
          requiredResourceAttributes: widget.configuration.requiredResourceAttributes,
        );
      });

  void _focusNext(BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  InputBorder? _enabledBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 1.2))
      : null;

  InputBorder? _focusedBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 2.0))
      : null;
}

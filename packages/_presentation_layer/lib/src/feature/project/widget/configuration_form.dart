import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/translations.dart';

class ConfigurationForm extends ConsumerWidget {
  const ConfigurationForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(resetConfigurationProvider);
    final tr = Translations.of(context);
    final controller = ref.watch(formConfigurationProvider.notifier);
    return _ConfigurationForm(tr, controller);
  }
}

class _ConfigurationForm extends StatefulWidget {
  const _ConfigurationForm(this.tr, this.configurationController);

  final Translations tr;
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
        _formField(
          context,
          colors,
          'arb folder',
          _arbDirTextController,
          hintText: L10nConfiguration.defaultArbDir,
          onChanged: (_) => _onFormChanged(),
          focusNode: _arbDirFocus,
          nextFocus: _outputDirFocus,
        ),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'output folder',
          _outputDirTextController,
          hintText: _arbDirTextController.text.isEmpty
              ? L10nConfiguration.defaultArbDir
              : _arbDirTextController.text,
          onChanged: (_) => _onFormChanged(),
          focusNode: _outputDirFocus,
          nextFocus: _templateArbFileFocus,
        ),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'template file',
          _templateArbFileTextController,
          hintText: L10nConfiguration.defaultTemplateArbFile,
          onChanged: (_) => _onFormChanged(),
          focusNode: _templateArbFileFocus,
          nextFocus: _outputLocalizationFocus,
        ),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'output file',
          _outputLocalizationFileTextController,
          hintText: L10nConfiguration.defaultOutputLocalizationFile,
          onChanged: (_) => _onFormChanged(),
          focusNode: _outputLocalizationFocus,
          nextFocus: _outputClassFocus,
        ),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'output class',
          _outputClassTextController,
          hintText: L10nConfiguration.defaultOutputClass,
          onChanged: (_) => _onFormChanged(),
          focusNode: _outputClassFocus,
          nextFocus: _headerFocus,
        ),
        _verticalSeparator,
        _formField(
          context,
          colors,
          'header',
          _headerTextController,
          onChanged: (_) => _onFormChanged(),
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
    String? hintText,
    void Function(String)? onChanged,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    String? Function(String?)? validator,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool readOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
    int? maxLines = 1,
  }) =>
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        enabled: enabled,
        onTap: onTap,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 0.0),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(5.0),
          ),
          labelText: label,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'clear',
                  onPressed: () {
                    controller.clear();
                    _onFormChanged();
                  },
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                ),
          counterText: '',
        ),
        maxLength: maxLength,
        onChanged: onChanged,
        validator: validator,
        focusNode: focusNode,
        onEditingComplete:
            nextFocus == null ? null : () => _focusNext(context, focusNode, nextFocus),
        textInputAction: nextFocus == null ? TextInputAction.done : TextInputAction.next,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
      );

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
}

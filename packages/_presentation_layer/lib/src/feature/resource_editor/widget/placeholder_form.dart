import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';
import 'definition_form_mixin.dart';

enum _DisplayOption {
  simple,
  detailed;

  String text(AppLocalizations loc) => loc.label_placeholder_display_option(name);
}

class PlaceholderForm extends StatefulWidget {
  const PlaceholderForm({super.key, required this.placeholder, required this.onUpdate});

  final ArbPlaceholderBase placeholder;
  final ValueChanged<ArbPlaceholderBase> onUpdate;

  @override
  State<PlaceholderForm> createState() => _PlaceholderFormState();
}

class _PlaceholderFormState extends State<PlaceholderForm> with DefinitionFormMixin {
  late ArbPlaceholderBase formPlaceholder;
  _DisplayOption displayOption = _DisplayOption.simple;
  TextEditingController keyTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();
  TextEditingController exampleTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant PlaceholderForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      resetState();
    }
  }

  void resetState() {
    formPlaceholder = widget.placeholder;
    displayOption = formPlaceholder.hasDetails ? _DisplayOption.detailed : _DisplayOption.simple;
    keyTextController.text = formPlaceholder.key;
    descTextController.text = formPlaceholder.description;
    exampleTextController.text = formPlaceholder.example;
  }

  @override
  void dispose() {
    keyTextController.dispose();
    descTextController.dispose();
    exampleTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        _placeholderKeyRow(context, colors),
        if (displayOption == _DisplayOption.detailed) _details(context, colors),
      ],
    );
  }

  Widget _placeholderKeyRow(BuildContext context, ColorScheme colors) => Row(children: [
        Expanded(
          child: textField(
            colors: colors,
            label: 'Placeholder',
            originalText: formPlaceholder.key,
            textController: keyTextController,
            inputFormatters: [keyFormatter],
            onChanged: (value) => setState(() {}),
          ),
        ),
        IconButton(
            onPressed: keyTextController.text.trim().isEmpty ? null : () {},
            icon: const Icon(Icons.add)),
        const SizedBox(width: 16.0),
        if (!formPlaceholder.hasDetails) _displayOptions,
      ]);

  Widget _details(BuildContext context, ColorScheme colors) {
    return Column(children: [
      DefinitionFormMixin.verticalSeparator,
      textField(
        colors: colors,
        label: 'Description',
        originalText: formPlaceholder.description,
        textController: descTextController,
        onChanged: (value) {},
      ),
      DefinitionFormMixin.verticalSeparator,
      textField(
        colors: colors,
        label: 'Example',
        originalText: formPlaceholder.example,
        textController: exampleTextController,
        onChanged: (value) {},
      ),
    ]);
  }

  Widget get _displayOptions => _PlaceholderDisplayOptions(
        currentOption: displayOption,
        onChanged: (value) => setState(() => displayOption = value),
      );
}

class _PlaceholderDisplayOptions extends StatelessWidget {
  const _PlaceholderDisplayOptions({required this.currentOption, required this.onChanged});

  final _DisplayOption currentOption;
  final ValueChanged<_DisplayOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        _button(loc, theme, MainAxisAlignment.start, _DisplayOption.simple),
        _button(loc, theme, MainAxisAlignment.end, _DisplayOption.detailed),
      ],
    );
  }

  Widget _button(
    AppLocalizations loc,
    ThemeData theme,
    MainAxisAlignment align,
    _DisplayOption option,
  ) {
    final colors = theme.colorScheme;
    return segmentedButton(
        align: align,
        colors: colors,
        backgroundColor: colors.background,
        text: option.text(loc),
        style: style(theme.textTheme, option),
        minimumSize: const Size(0, 36),
        onPressed: () => _onPressed(option),
        selected: currentOption == option);
  }

  void _onPressed(_DisplayOption option) {
    if (currentOption != option) {
      onChanged(option);
    }
  }

  TextStyle? style(TextTheme theme, _DisplayOption option) {
    return currentOption == option
        ? theme.bodySmall?.copyWith(fontWeight: FontWeight.w500)
        : theme.bodySmall;
  }
}

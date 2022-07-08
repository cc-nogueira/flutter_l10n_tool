import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_dropdown.dart';
import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../../../l10n/app_localizations.dart';

enum _DisplayOption {
  simple,
  detailed;

  String text(AppLocalizations loc) => loc.label_placeholder_display_option(name);
}

class PlaceholderForm extends StatefulWidget {
  const PlaceholderForm({super.key, required this.placeholder, required this.onUpdate});

  final ArbPlaceholder placeholder;
  final ValueChanged<ArbPlaceholder> onUpdate;

  @override
  State<PlaceholderForm> createState() => _PlaceholderFormState();
}

class _PlaceholderFormState extends State<PlaceholderForm> with TextFormFieldMixin {
  late ArbPlaceholder formPlaceholder;
  _DisplayOption displayOption = _DisplayOption.simple;
  TextEditingController keyTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();
  TextEditingController exampleTextController = TextEditingController();
  TextEditingController formatTextController = TextEditingController();

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
    formPlaceholder.maybeMap(
        dateTime: (value) {
          formatTextController.text = value.format;
        },
        orElse: () {});
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
            context: context,
            label: 'Placeholder',
            originalText: formPlaceholder.key,
            textController: keyTextController,
            inputFormatters: [textInputKeyFormatter],
            enableCleanButton: true,
            onChanged: (value) => setState(() {
              formPlaceholder = formPlaceholder.copyWith(key: value);
              widget.onUpdate(formPlaceholder);
            }),
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
      FormMixin.verticalSeparator,
      textField(
        context: context,
        label: 'Description',
        originalText: formPlaceholder.description,
        textController: descTextController,
        enableCleanButton: true,
        onChanged: (value) => setState(() {
          formPlaceholder = formPlaceholder.copyWith(description: value);
          widget.onUpdate(formPlaceholder);
        }),
      ),
      FormMixin.verticalSeparator,
      textField(
        context: context,
        label: 'Example',
        originalText: formPlaceholder.example,
        textController: exampleTextController,
        enableCleanButton: true,
        onChanged: (value) => setState(() {
          formPlaceholder = formPlaceholder.copyWith(example: value);
          widget.onUpdate(formPlaceholder);
        }),
      ),
      FormMixin.verticalSeparator,
      Row(
        children: [
          Expanded(
            flex: 1,
            child: FormDropdown<ArbPlaceholderType>(
              label: 'Type',
              options: ArbPlaceholderType.values,
              optionLabel: (value) => value.type,
              originalValue: widget.placeholder.type,
              formValue: formPlaceholder.type,
              onChanged: (value) => setState(() {
                if (value != formPlaceholder.type) {
                  formPlaceholder = _copyWithType(value);
                  widget.onUpdate(formPlaceholder);
                }
              }),
            ),
          ),
          FormMixin.horizontalSeparator,
          Expanded(
            flex: 1,
            child: _formatInputOrEmpty(),
          ),
        ],
      ),
      ..._typeDetails(),
    ]);
  }

  ArbPlaceholder _copyWithType(ArbPlaceholderType? type) {
    switch (type) {
      case ArbPlaceholderType.stringType:
        return ArbPlaceholder.string(
          key: formPlaceholder.key,
          description: formPlaceholder.description,
          example: formPlaceholder.example,
        );
      case ArbPlaceholderType.numType:
      case ArbPlaceholderType.intType:
      case ArbPlaceholderType.doubleType:
        return ArbPlaceholder.number(
          key: formPlaceholder.key,
          description: formPlaceholder.description,
          example: formPlaceholder.example,
          type: type!,
        );
      case ArbPlaceholderType.dateTimeType:
        return ArbPlaceholder.dateTime(
          key: formPlaceholder.key,
          description: formPlaceholder.description,
          example: formPlaceholder.example,
        );
      default:
        return ArbPlaceholder.generic(
          key: formPlaceholder.key,
          description: formPlaceholder.description,
          example: formPlaceholder.example,
        );
    }
  }

  Widget _formatInputOrEmpty() {
    return formPlaceholder.maybeMap<Widget>(
      dateTime: (value) => textField(
        context: context,
        label: 'Format',
        originalText: value.format,
        textController: formatTextController,
        enableCleanButton: true,
        onChanged: (txt) => setState(() {
          formPlaceholder = value.copyWith(format: txt);
          widget.onUpdate(formPlaceholder);
        }),
      ),
      orElse: () => Container(),
    );
  }

  List<Widget> _typeDetails() {
    return formPlaceholder.maybeMap<List<Widget>>(
      orElse: () => [],
    );
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

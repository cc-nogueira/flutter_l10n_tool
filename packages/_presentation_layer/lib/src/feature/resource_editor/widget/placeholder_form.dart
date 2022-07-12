import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_dropdown.dart';
import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../../../l10n/app_localizations.dart';

enum _PlaceholderDateFormatType {
  icu,
  custom;

  String text(AppLocalizations loc) => loc.label_placeholder_date_format_type(name);
  bool get isCustom => this == custom;
}

class PlaceholderForm extends StatefulWidget {
  const PlaceholderForm({
    super.key,
    required this.placeholder,
    required this.onUpdate,
    required this.onDiscard,
  });

  final ArbPlaceholder placeholder;
  final ValueChanged<ArbPlaceholder> onUpdate;
  final VoidCallback onDiscard;

  @override
  State<PlaceholderForm> createState() => _PlaceholderFormState();
}

class _PlaceholderFormState extends State<PlaceholderForm> with TextFormFieldMixin {
  late ArbPlaceholder formPlaceholder;
  late ArbDateTimePlaceholder formDatePlaceholder;
  late ArbNumberPlaceholder formNumberPlaceholder;
  var showDesc = false;
  var showExample = false;
  var keyTextController = TextEditingController();
  var descTextController = TextEditingController();
  var exampleTextController = TextEditingController();
  var numberCustomPatternTextController = TextEditingController();
  var dateIcuFormatTextController = TextEditingController();
  var dateCustomFormatTextController = TextEditingController();

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
    _initDateAndNumberPlaceholders();
    showDesc = formPlaceholder.description.isNotEmpty;
    showExample = formPlaceholder.example.isNotEmpty;
    keyTextController.text = formPlaceholder.key;
    descTextController.text = formPlaceholder.description;
    exampleTextController.text = formPlaceholder.example;
    dateIcuFormatTextController.text = formDatePlaceholder.icuFormat.skeleton;
    dateCustomFormatTextController.text = formDatePlaceholder.customFormat;
    numberCustomPatternTextController.text = formNumberPlaceholder
            .optionalParameters[ArbNumberPlaceholderParameter.customPattern.name] ??
        '';
  }

  void _initDateAndNumberPlaceholders() {
    formPlaceholder = widget.placeholder;
    widget.placeholder.maybeMap(
      number: (numberPlaceholder) {
        formNumberPlaceholder = numberPlaceholder;
        _initDatePlaceholder();
      },
      dateTime: (dateTimePlaceholder) {
        formDatePlaceholder = dateTimePlaceholder;
        _initNumberPlaceholder();
      },
      orElse: () {
        _initDatePlaceholder();
        _initNumberPlaceholder();
      },
    );
  }

  void _initDatePlaceholder() {
    formDatePlaceholder = ArbDateTimePlaceholder(
      key: widget.placeholder.key,
      description: widget.placeholder.description,
      example: widget.placeholder.example,
      icuFormat: ArbIcuDatePlaceholderFormat.yearMonthDay,
      customFormat: '',
    );
  }

  void _initNumberPlaceholder() {
    formNumberPlaceholder = ArbNumberPlaceholder(
      type: ArbPlaceholderType.numType,
      key: formPlaceholder.key,
      description: formPlaceholder.description,
      example: formPlaceholder.example,
    );
  }

  @override
  void dispose() {
    keyTextController.dispose();
    descTextController.dispose();
    exampleTextController.dispose();
    dateIcuFormatTextController.dispose();
    dateCustomFormatTextController.dispose();
    numberCustomPatternTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _typeAndPlaceholderRow(),
        ..._typeDetails(loc),
        ..._descriptionAndExample(loc),
        FormMixin.verticalSeparator,
        _saveDiscardButtonsRow(loc, colors),
      ],
    );
  }

  Widget _typeAndPlaceholderRow() {
    return Row(children: [
      SizedBox(
        width: 120,
        child: FormDropdown<ArbPlaceholderType>(
          label: 'Type',
          options: ArbPlaceholderType.values,
          optionLabel: (value) => value.type,
          originalValue: widget.placeholder.type,
          formValue: formPlaceholder.type,
          onChanged: (value) => setState(() {
            if (value != formPlaceholder.type) {
              _changeFormPlaceholderType(value);
              widget.onUpdate(formPlaceholder);
            }
          }),
        ),
      ),
      FormMixin.horizontalSeparator,
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
            formDatePlaceholder = formDatePlaceholder.copyWith(key: value);
            formNumberPlaceholder = formNumberPlaceholder.copyWith(key: value);
            widget.onUpdate(formPlaceholder);
          }),
        ),
      ),
    ]);
  }

  Widget _saveDiscardButtonsRow(AppLocalizations loc, ColorScheme colors) {
    return Row(children: [
      outlinedButton(text: loc.label_discard_placeholder_changes, onPressed: widget.onDiscard),
      FormMixin.horizontalSeparator,
      filledButton(
        colors: colors,
        text: loc.label_save_placeholder,
        onPressed: formPlaceholder.key.isEmpty ? null : () {},
      )
    ]);
  }

  List<Widget> _typeDetails(AppLocalizations loc) {
    return formPlaceholder.maybeMap<List<Widget>>(
      orElse: () => [],
      number: (value) => [
        FormMixin.verticalSeparator,
        textField(
          context: context,
          label: 'Format',
          originalText: value.format?.name ?? '',
          textController: numberCustomPatternTextController,
          enableCleanButton: true,
          onChanged: (txt) => setState(() {
            final optionalParameters =
                Map<String, String>.from(formNumberPlaceholder.optionalParameters);
            optionalParameters[ArbNumberPlaceholderParameter.customPattern.name] = txt;
            formNumberPlaceholder = formNumberPlaceholder.copyWith(
                optionalParameters: Map.unmodifiable(optionalParameters));
            formPlaceholder = formNumberPlaceholder;
            widget.onUpdate(formPlaceholder);
          }),
        )
      ],
      dateTime: (value) => [
        FormMixin.verticalSeparator,
        Row(
          children: [
            SizedBox(
              width: 120,
              child: FormDropdown<_PlaceholderDateFormatType>(
                label: 'Format type',
                options: const [_PlaceholderDateFormatType.icu, _PlaceholderDateFormatType.custom],
                optionLabel: (option) => option.text(loc),
                originalValue: _PlaceholderDateFormatType.icu,
                formValue: _PlaceholderDateFormatType.icu,
                onChanged: (option) {
                  final isCustom = option?.isCustom ?? false;
                  setState(() {
                    formDatePlaceholder = value.copyWith(useCustomFormat: isCustom);
                    formPlaceholder = formDatePlaceholder;
                    widget.onUpdate(formPlaceholder);
                  });
                },
              ),
            ),
            FormMixin.horizontalSeparator,
            Expanded(
              child: formDatePlaceholder.useCustomFormat
                  ? textField(
                      context: context,
                      label: 'Custom Format',
                      hintText: 'Ex. EEE, M/d/y',
                      originalText: value.customFormat,
                      textController: dateCustomFormatTextController,
                      onChanged: (txt) => setState(() {
                        formDatePlaceholder = formDatePlaceholder.copyWith(customFormat: txt);
                        formPlaceholder = formDatePlaceholder;
                        widget.onUpdate(formPlaceholder);
                      }),
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: FormDropdown<ArbIcuDatePlaceholderFormat>(
                            label: 'ICU name',
                            options: ArbIcuDatePlaceholderFormat.values,
                            optionLabel: (option) => option.icuName,
                            originalValue: value.icuFormat,
                            formValue: value.icuFormat,
                            onChanged: (icu) => setState(() {
                              if (icu != null) {
                                dateIcuFormatTextController.text = icu.skeleton;
                                formDatePlaceholder = formDatePlaceholder.copyWith(icuFormat: icu);
                                formPlaceholder = formDatePlaceholder;
                                widget.onUpdate(formPlaceholder);
                              }
                            }),
                          ),
                        ),
                        FormMixin.horizontalSeparator,
                        Expanded(
                          flex: 1,
                          child: textField(
                            context: context,
                            readOnly: true,
                            label: 'Format',
                            originalText: value.icuFormat.skeleton,
                            textController: dateIcuFormatTextController,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        )
      ],
    );
  }

  List<Widget> _descriptionAndExample(AppLocalizations loc) {
    return [
      if (showDesc) ...[
        FormMixin.verticalSeparator,
        textField(
          context: context,
          label: loc.label_description,
          originalText: formPlaceholder.description,
          textController: descTextController,
          enableCleanButton: true,
          onChanged: (value) => setState(() {
            formPlaceholder = formPlaceholder.copyWith(description: value);
            widget.onUpdate(formPlaceholder);
          }),
        )
      ],
      if (showExample) ...[
        FormMixin.verticalSeparator,
        textField(
          context: context,
          label: loc.label_example,
          originalText: formPlaceholder.example,
          textController: exampleTextController,
          enableCleanButton: true,
          onChanged: (value) => setState(() {
            formPlaceholder = formPlaceholder.copyWith(example: value);
            widget.onUpdate(formPlaceholder);
          }),
        ),
      ],
      if (!showDesc || !showExample) ...[
        FormMixin.verticalSeparator,
        Row(children: [
          if (!showDesc)
            textButton(
              text: loc.label_set_placeholder_option(loc.label_description),
              onPressed: () => setState(() => showDesc = true),
            ),
          if (!showDesc && !showExample) FormMixin.horizontalSeparator,
          if (!showExample)
            textButton(
              text: loc.label_set_placeholder_option(loc.label_example),
              onPressed: () => setState(() => showExample = true),
            ),
        ])
      ],
    ];
  }

  void _changeFormPlaceholderType(ArbPlaceholderType? type) {
    switch (type) {
      case ArbPlaceholderType.numType:
      case ArbPlaceholderType.intType:
      case ArbPlaceholderType.doubleType:
        formPlaceholder = formNumberPlaceholder;
        break;
      case ArbPlaceholderType.dateTimeType:
        formPlaceholder = formDatePlaceholder;
        break;
      case ArbPlaceholderType.stringType:
        formPlaceholder = ArbPlaceholder.string(
          key: formPlaceholder.key,
          description: formPlaceholder.description,
          example: formPlaceholder.example,
        );
        break;
      default:
        formPlaceholder = ArbPlaceholder.generic(
          key: formPlaceholder.key,
          description: formPlaceholder.description,
          example: formPlaceholder.example,
        );
    }
  }
}

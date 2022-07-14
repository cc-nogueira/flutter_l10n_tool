import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_dropdown.dart';
import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../../../l10n/app_localizations.dart';
import 'placeholder_buttons.dart';
import 'placeholders_and_form.dart';

enum _PlaceholderDateFormatType {
  icu,
  custom;

  String text(AppLocalizations loc) => loc.label_placeholder_date_format_type(name);
  bool get isCustom => this == custom;
}

class PlaceholderForm extends StatefulWidget {
  const PlaceholderForm({
    super.key,
    required this.original,
    required this.formPlaceholder,
    required this.onUpdate,
    required this.onSave,
    required this.onDiscard,
    this.showSaveButton = true,
    this.showPlaceholderInput = true,
    this.saveButtonKey,
    this.placeholderInputKey,
  });

  final ArbPlaceholder? original;
  final ArbPlaceholder formPlaceholder;
  final ValueChanged<ArbPlaceholder> onUpdate;
  final ValueChanged<ArbPlaceholder> onSave;
  final VoidCallback onDiscard;
  final bool showSaveButton;
  final bool showPlaceholderInput;
  final Key? saveButtonKey;
  final Key? placeholderInputKey;

  @override
  State<PlaceholderForm> createState() => _PlaceholderFormState();
}

class _PlaceholderFormState extends State<PlaceholderForm> with TextFormFieldMixin {
  late ArbPlaceholder formPlaceholder;
  late ArbDateTimePlaceholder formDatePlaceholder;
  late ArbNumberPlaceholder formNumberPlaceholder;
  var showDesc = false;
  var showExample = false;
  late var keyTextController = _keyTC();
  late var descTextController = _descTC();
  late var exampleTextController = _exampleTC();
  late var dateIcuFormatTextController = _dateIcuFormatTC();
  late var dateCustomFormatTextController = _dateCustomFormatTC();
  late var numberCustomPatternTextController = _numberCustomPatternTC();

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant PlaceholderForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      resetState(true);
    }
  }

  void resetState([updateControllers = false]) {
    _initDateAndNumberPlaceholders();
    showDesc = formPlaceholder.description.isNotEmpty;
    showExample = formPlaceholder.example.isNotEmpty;
    if (updateControllers) {
      keyTextController.dispose();
      keyTextController = _keyTC();
      descTextController.dispose();
      descTextController = _descTC();
      exampleTextController.dispose();
      exampleTextController = _exampleTC();
      dateIcuFormatTextController.dispose();
      dateIcuFormatTextController = _dateIcuFormatTC();
      dateCustomFormatTextController.dispose();
      dateCustomFormatTextController = _dateCustomFormatTC();
      numberCustomPatternTextController.dispose();
      numberCustomPatternTextController = _numberCustomPatternTC();
    }
  }

  void _initDateAndNumberPlaceholders() {
    formPlaceholder = widget.formPlaceholder;
    widget.formPlaceholder.maybeMap(
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

  TextEditingController _keyTC() => TextEditingController(text: formPlaceholder.key);
  TextEditingController _descTC() => TextEditingController(text: formPlaceholder.description);
  TextEditingController _exampleTC() => TextEditingController(text: formPlaceholder.example);
  TextEditingController _dateIcuFormatTC() =>
      TextEditingController(text: formDatePlaceholder.icuFormat.skeleton);
  TextEditingController _dateCustomFormatTC() =>
      TextEditingController(text: formDatePlaceholder.customFormat);
  TextEditingController _numberCustomPatternTC() => TextEditingController(
      text: formNumberPlaceholder
              .optionalParameters[ArbNumberPlaceholderParameter.customPattern.name] ??
          '');

  void _initDatePlaceholder() {
    formDatePlaceholder = ArbDateTimePlaceholder(
      key: widget.formPlaceholder.key,
      description: widget.formPlaceholder.description,
      example: widget.formPlaceholder.example,
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
        FormMixin.verticalSeparator,
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
          originalValue: widget.original?.type ?? ArbPlaceholderType.genericType,
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
        child: widget.showPlaceholderInput
            ? _placeholderTextField()
            : IgnorePointer(child: Opacity(opacity: 0.3, child: _placeholderTextField())),
      ),
    ]);
  }

  Widget _placeholderTextField() => textField(
      key: placeholderInputKey,
      context: context,
      label: 'Placeholder',
      originalText: widget.original?.key ?? '',
      textController: keyTextController,
      inputFormatters: [textInputKeyFormatter],
      enableCleanButton: true,
      onChanged: (value) => setState(() {
            formPlaceholder = formPlaceholder.copyWith(key: value);
            formDatePlaceholder = formDatePlaceholder.copyWith(key: value);
            formNumberPlaceholder = formNumberPlaceholder.copyWith(key: value);
            widget.onUpdate(formPlaceholder);
          }));

  Widget _saveDiscardButtonsRow(AppLocalizations loc, ColorScheme colors) {
    final enabled = formPlaceholder.key.isNotEmpty && formPlaceholder != widget.original;
    return Row(children: [
      _discardButton(loc),
      FormMixin.horizontalSeparator,
      SavePlaceholderButton(
        key: widget.saveButtonKey,
        loc: loc,
        colors: colors,
        onPressed: enabled ? () => widget.onSave(formPlaceholder) : null,
        hide: !widget.showSaveButton,
      ),
    ]);
  }

  Widget _discardButton(AppLocalizations loc) =>
      outlinedButton(text: loc.label_discard_placeholder_changes, onPressed: widget.onDiscard);

  List<Widget> _typeDetails(AppLocalizations loc) {
    final original = widget.original;
    return formPlaceholder.maybeMap<List<Widget>>(
      orElse: () => [],
      number: (value) {
        late final String originalText;
        if (original is ArbNumberPlaceholder) {
          originalText = original.format?.name ?? '';
        } else {
          originalText = '';
        }
        return [
          FormMixin.verticalSeparator,
          textField(
            context: context,
            label: 'Format',
            originalText: originalText,
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
        ];
      },
      dateTime: (value) {
        late final _PlaceholderDateFormatType originalFormatType;
        late final String originalCustomFormat;
        late final ArbIcuDatePlaceholderFormat originalIcuFormat;
        if (original is ArbDateTimePlaceholder) {
          originalFormatType = original.useCustomFormat
              ? _PlaceholderDateFormatType.custom
              : _PlaceholderDateFormatType.icu;
          originalCustomFormat = original.customFormat;
          originalIcuFormat = original.icuFormat;
        } else {
          originalFormatType = _PlaceholderDateFormatType.icu;
          originalCustomFormat = '';
          originalIcuFormat = ArbIcuDatePlaceholderFormat.yearMonthDay;
        }

        return [
          FormMixin.verticalSeparator,
          Row(
            children: [
              SizedBox(
                width: 120,
                child: FormDropdown<_PlaceholderDateFormatType>(
                  label: 'Format type',
                  options: const [
                    _PlaceholderDateFormatType.icu,
                    _PlaceholderDateFormatType.custom
                  ],
                  optionLabel: (option) => option.text(loc),
                  originalValue: originalFormatType,
                  formValue: value.useCustomFormat
                      ? _PlaceholderDateFormatType.custom
                      : _PlaceholderDateFormatType.icu,
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
                        originalText: originalCustomFormat,
                        textController: dateCustomFormatTextController,
                        onChanged: (txt) {
                          setState(() {
                            formDatePlaceholder = formDatePlaceholder.copyWith(customFormat: txt);
                            formPlaceholder = formDatePlaceholder;
                            widget.onUpdate(formPlaceholder);
                          });
                        },
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: FormDropdown<ArbIcuDatePlaceholderFormat>(
                              label: 'ICU name',
                              options: ArbIcuDatePlaceholderFormat.values,
                              optionLabel: (option) => option.icuName,
                              originalValue: originalIcuFormat,
                              formValue: value.icuFormat,
                              onChanged: (icu) => setState(() {
                                if (icu != null) {
                                  dateIcuFormatTextController.text = icu.skeleton;
                                  formDatePlaceholder =
                                      formDatePlaceholder.copyWith(icuFormat: icu);
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
                              originalText: originalIcuFormat.skeleton,
                              textController: dateIcuFormatTextController,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          )
        ];
      },
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
          onChanged: (value) {
            setState(() {
              formPlaceholder = formPlaceholder.copyWith(description: value);
              widget.onUpdate(formPlaceholder);
            });
          },
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
          onChanged: (value) {
            setState(() {
              formPlaceholder = formPlaceholder.copyWith(example: value);
              widget.onUpdate(formPlaceholder);
            });
          },
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

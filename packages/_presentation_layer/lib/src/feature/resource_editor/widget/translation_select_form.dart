import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_button.dart';
import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../../../l10n/app_localizations.dart';

class TranslationSelectForm extends StatefulWidget {
  const TranslationSelectForm({
    super.key,
    required this.definition,
    required this.original,
    required this.formOption,
    required this.onUpdate,
    required this.addCallback,
    required this.replaceCallback,
    required this.onDiscard,
    this.showAddButton = true,
    this.showOptionInput = true,
    this.addButtonKey,
    this.optionInputKey,
  });

  final ArbSelectDefinition definition;
  final ArbSelectCase? original;
  final ArbSelectCase formOption;
  final ValueChanged<ArbSelectCase> onUpdate;
  final ValueChanged<ArbSelectCase> addCallback;
  final ValueChanged<ArbSelectCase> replaceCallback;
  final VoidCallback onDiscard;
  final bool showAddButton;
  final bool showOptionInput;
  final Key? addButtonKey;
  final Key? optionInputKey;

  @override
  State<TranslationSelectForm> createState() => _TranslationSelectFormState();

  bool get isEditing => original != null;
}

class _TranslationSelectFormState extends State<TranslationSelectForm> with TextFormFieldMixin {
  late ArbSelectCase formOption;
  late var caseTextController = _caseTC();
  late var valueTextController = _valueTC();

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant TranslationSelectForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      resetState(true);
    }
  }

  void resetState([updateControllers = false]) {
    formOption = widget.formOption;
    if (updateControllers) {
      caseTextController.dispose();
      caseTextController = _caseTC();
      valueTextController.dispose();
      valueTextController = _valueTC();
    }
  }

  TextEditingController _caseTC() => TextEditingController(text: formOption.option);
  TextEditingController _valueTC() => TextEditingController(text: formOption.value);

  @override
  void dispose() {
    valueTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Material(
        color: colors.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        elevation: 8,
        surfaceTintColor: Colors.black,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _optionRow(),
              FormMixin.verticalSeparator,
              widget.isEditing
                  ? _updateAddDiscardButtonsRow(loc, colors)
                  : _saveDiscardButtonsRow(loc, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionRow() {
    return Row(children: [
      SizedBox(
        width: 200,
        child: _optionCaseTextField(),
      ),
      FormMixin.horizontalSeparator,
      Expanded(
        child: widget.showOptionInput
            ? _optionTextField()
            : IgnorePointer(child: Opacity(opacity: 0.3, child: _optionTextField())),
      ),
    ]);
  }

  Widget _optionCaseTextField() => textField(
      context: context,
      label: 'Case',
      originalText: widget.original?.option ?? '',
      textController: caseTextController,
      onChanged: (value) => setState(() {
            formOption = formOption.copyWith(option: value);
            widget.onUpdate(formOption);
          }));

  Widget _optionTextField() => textField(
      key: widget.optionInputKey,
      context: context,
      label: 'Value',
      originalText: widget.original?.value ?? '',
      textController: valueTextController,
      enableCleanButton: true,
      onChanged: (value) => setState(() {
            formOption = formOption.copyWith(value: value);
            widget.onUpdate(formOption);
          }));

  Widget _saveDiscardButtonsRow(AppLocalizations loc, ColorScheme colors) {
    final enableAdd = formOption.option.isNotEmpty && formOption != widget.original;
    return Row(children: [
      _discardButton(loc),
      FormMixin.horizontalSeparator,
      FormMixin.horizontalSeparator,
      FormButton(
        key: widget.addButtonKey,
        colors: colors,
        text: loc.label_add_select,
        onPressed: enableAdd ? () => widget.addCallback(formOption) : null,
        hide: !widget.showAddButton,
      ),
    ]);
  }

  Widget _updateAddDiscardButtonsRow(AppLocalizations loc, ColorScheme colors) {
    final enableUpdate = formOption.option.isNotEmpty && formOption != widget.original;
    final enableAdd = enableUpdate && formOption.option != widget.original!.option;
    return Row(children: [
      _discardButton(loc),
      FormMixin.horizontalSeparator,
      FormMixin.horizontalSeparator,
      FormButton(
        key: widget.addButtonKey,
        colors: colors,
        text: loc.label_add_select,
        tonal: true,
        onPressed: enableAdd ? () => widget.addCallback(formOption) : null,
        hide: !widget.showAddButton,
      ),
      FormMixin.horizontalSeparator,
      FormButton(
        colors: colors,
        text: loc.label_update_select,
        onPressed: enableUpdate ? () => widget.replaceCallback(formOption) : null,
      ),
    ]);
  }

  Widget _discardButton(AppLocalizations loc) =>
      outlinedButton(text: loc.label_discard_select_changes, onPressed: widget.onDiscard);
}

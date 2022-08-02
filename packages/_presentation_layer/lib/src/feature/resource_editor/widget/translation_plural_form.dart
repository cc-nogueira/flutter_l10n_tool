import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_button.dart';
import '../../../common/widget/form_dropdown.dart';
import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../../../l10n/app_localizations.dart';

class TranslationPluralForm extends StatefulWidget {
  const TranslationPluralForm({
    super.key,
    required this.definition,
    required this.availableOptions,
    required this.original,
    required this.formPlural,
    required this.onUpdate,
    required this.addCallback,
    required this.replaceCallback,
    required this.onDiscard,
    this.showAddButton = true,
    this.showPluralInput = true,
    this.addButtonKey,
    this.pluralInputKey,
  });

  final ArbPluralDefinition definition;
  final List<ArbPluralOption> availableOptions;
  final ArbPlural? original;
  final ArbPlural formPlural;
  final ValueChanged<ArbPlural> onUpdate;
  final ValueChanged<ArbPlural> addCallback;
  final ValueChanged<ArbPlural> replaceCallback;
  final VoidCallback onDiscard;
  final bool showAddButton;
  final bool showPluralInput;
  final Key? addButtonKey;
  final Key? pluralInputKey;

  @override
  State<TranslationPluralForm> createState() => _TranslationPluralFormState();

  bool get isEditing => original != null;
}

class _TranslationPluralFormState extends State<TranslationPluralForm> with TextFormFieldMixin {
  late ArbPlural formPlural;
  late var valueTextController = _valueTC();

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant TranslationPluralForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      resetState(true);
    }
  }

  void resetState([updateControllers = false]) {
    formPlural = widget.formPlural;
    if (updateControllers) {
      valueTextController.dispose();
      valueTextController = _valueTC();
    }
  }

  TextEditingController _valueTC() => TextEditingController(text: formPlural.value);

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
              _pluralRow(),
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

  Widget _pluralRow() {
    return Row(children: [
      SizedBox(
        width: 120,
        child: FormDropdown<ArbPluralOption>(
          label: widget.definition.parameterName,
          options: widget.availableOptions,
          optionLabel: (value) => value.name,
          originalValue: widget.original?.option ?? widget.formPlural.option,
          formValue: formPlural.option,
          onChanged: (option) {
            if (option == null || option == formPlural.option) {
              return;
            }
            setState(() {
              formPlural = formPlural.copyWith(option: option);
              widget.onUpdate(formPlural);
            });
          },
        ),
      ),
      FormMixin.horizontalSeparator,
      Expanded(
        child: widget.showPluralInput
            ? _pluralTextField()
            : IgnorePointer(child: Opacity(opacity: 0.3, child: _pluralTextField())),
      ),
    ]);
  }

  Widget _pluralTextField() => textField(
      key: widget.pluralInputKey,
      context: context,
      label: 'Value',
      originalText: widget.original?.value ?? '',
      textController: valueTextController,
      enableCleanButton: true,
      onChanged: (value) => setState(() {
            formPlural = formPlural.copyWith(value: value);
            widget.onUpdate(formPlural);
          }));

  Widget _saveDiscardButtonsRow(AppLocalizations loc, ColorScheme colors) {
    final enableAdd = formPlural != widget.original;
    return Row(children: [
      _discardButton(loc),
      FormMixin.horizontalSeparator,
      FormMixin.horizontalSeparator,
      FormButton(
        key: widget.addButtonKey,
        colors: colors,
        text: loc.label_add_plural,
        onPressed: enableAdd ? () => widget.addCallback(formPlural) : null,
        hide: !widget.showAddButton,
      ),
    ]);
  }

  Widget _updateAddDiscardButtonsRow(AppLocalizations loc, ColorScheme colors) {
    final enableUpdate = formPlural != widget.original;
    final enableAdd = enableUpdate && formPlural.option != widget.original!.option;
    return Row(children: [
      _discardButton(loc),
      FormMixin.horizontalSeparator,
      FormMixin.horizontalSeparator,
      FormButton(
        key: widget.addButtonKey,
        colors: colors,
        text: loc.label_add_plural,
        tonal: true,
        onPressed: enableAdd ? () => widget.addCallback(formPlural) : null,
        hide: !widget.showAddButton,
      ),
      FormMixin.horizontalSeparator,
      FormButton(
        colors: colors,
        text: loc.label_update_plural,
        onPressed: enableUpdate ? () => widget.replaceCallback(formPlural) : null,
      ),
    ]);
  }

  Widget _discardButton(AppLocalizations loc) =>
      outlinedButton(text: loc.label_discard_plural_changes, onPressed: widget.onDiscard);
}

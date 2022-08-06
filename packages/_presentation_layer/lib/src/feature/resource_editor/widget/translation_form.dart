import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../builder/arb_builder.dart';
import 'translation_placeholders_text_editing_controller.dart';
import 'translation_plurals_and_form.dart';
import 'translation_selects_and_form.dart';

abstract class TranslationForm<D extends ArbDefinition, T extends ArbTranslation>
    extends StatefulWidget {
  const TranslationForm({
    super.key,
    required this.displayOption,
    required this.locale,
    required this.definition,
    required this.current,
    required this.beingEdited,
    required this.onUpdate,
    required this.onSaveChanges,
    required this.onDiscardChanges,
  });

  final DisplayOption displayOption;
  final String locale;
  final D definition;
  final T? current;
  final T beingEdited;
  final ValueChanged<ArbTranslation> onUpdate;
  final ValueChanged<ArbTranslation> onSaveChanges;
  final VoidCallback onDiscardChanges;
}

class PlaceholdersTranslationForm
    extends TranslationForm<ArbPlaceholdersDefinition, ArbPlaceholdersTranslation> {
  const PlaceholdersTranslationForm({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.definition,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<TranslationForm<ArbPlaceholdersDefinition, ArbPlaceholdersTranslation>> createState() =>
      PlaceholdersTranslationFormState();
}

class PluralTranslationForm extends TranslationForm<ArbPluralDefinition, ArbPluralTranslation> {
  const PluralTranslationForm({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.definition,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<TranslationForm<ArbPluralDefinition, ArbPluralTranslation>> createState() =>
      PluralTranslationFormState();
}

class SelectTranslationForm extends TranslationForm<ArbSelectDefinition, ArbSelectTranslation> {
  const SelectTranslationForm({
    super.key,
    required super.displayOption,
    required super.locale,
    required super.definition,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onSaveChanges,
    required super.onDiscardChanges,
    required this.knownCases,
  });

  final Set<String> knownCases;

  @override
  State<SelectTranslationForm> createState() => SelectTranslationFormState();
}

abstract class TranslationFormState<S extends TranslationForm<D, T>, D extends ArbDefinition,
    T extends ArbTranslation> extends State<S> with TextFormFieldMixin {
  late ArbTranslationBuilder builder;
  late StateController<T> translationController;

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant S oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      resetState();
    }
  }

  @mustCallSuper
  void resetState() {
    translationController = StateController<T>(widget.beingEdited);
    builder = ArbTranslationBuilder.forArgs(
        displayOption: widget.displayOption,
        definition: widget.definition,
        translation: translationController.state);
  }

  @override
  Widget build(BuildContext context) {
    builder.init(context);
    final ThemeData theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: builder.tileLeadingIcons()),
        ArbBuilder.leadingSeparator,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title(theme.textTheme, colors),
              const SizedBox(height: 4.0),
              form(context, theme.colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget title(TextTheme theme, ColorScheme colors) {
    return builder.tileTitle(
      title: Text(widget.locale, style: builder.titleStyle),
      subtitle: subtitle(),
      trailing: Row(children: [
        IconButton(icon: const Icon(Icons.check), onPressed: hasChanges ? _saveChanges : null),
        IconButton(icon: const Icon(Icons.close), onPressed: widget.onDiscardChanges),
      ]),
    );
  }

  bool get hasChanges => translationController.state != widget.current;

  Widget? subtitle() => null;

  Widget form(BuildContext context, ColorScheme colors);

  void onChangedValue(T value) {
    setState(() {
      builder.translation = value;
      translationController.state = value;
      widget.onUpdate(value);
    });
  }

  void _saveChanges() => widget.onSaveChanges(translationController.state);
}

class PlaceholdersTranslationFormState extends TranslationFormState<PlaceholdersTranslationForm,
    ArbPlaceholdersDefinition, ArbPlaceholdersTranslation> with ArbMixin {
  late TranslationPlaceholdersTextEditingController translationTextController =
      TranslationPlaceholdersTextEditingController(placeholders: widget.definition.placeholders);

  @override
  void resetState() {
    super.resetState();
    translationTextController.text = translationController.state.value;
    translationTextController.arbBuilder = builder;
  }

  @override
  void dispose() {
    translationTextController.dispose();
    super.dispose();
  }

  @override
  Widget form(BuildContext context, ColorScheme colors) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.only(right: ArbBuilder.leadingSize),
        child: textField(
          context: context,
          label: 'Translation',
          originalText: widget.current?.value ?? '',
          textController: translationTextController,
          onChanged: (value) => onChangedValue(
            translationController.state
                .copyWith(value: value, placeholderNames: arbTranslationPlaceholderNames(value)),
          ),
        ),
      ),
    );
  }
}

abstract class TranslationWithParameterFormState<
    S extends TranslationForm<D, T>,
    D extends ArbDefinitionWithParameter,
    T extends ArbTranslationWithParameter> extends TranslationFormState<S, D, T> {
  TextEditingController prefixTextController = TextEditingController();
  TextEditingController suffixTextController = TextEditingController();

  @override
  void resetState() {
    super.resetState();
    prefixTextController.text = translationController.state.prefix;
    suffixTextController.text = translationController.state.suffix;
  }

  @override
  void dispose() {
    prefixTextController.dispose();
    suffixTextController.dispose();
    super.dispose();
  }

  @override
  Widget? subtitle() => builder.descriptorWidget();

  @override
  Widget form(BuildContext context, ColorScheme colors) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.only(right: ArbBuilder.leadingSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormMixin.verticalSeparator,
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: textField(
                    context: context,
                    label: 'Prefix',
                    originalText: widget.current?.prefix ?? '',
                    textController: prefixTextController,
                    onChanged: (value) => onChangedValue(copyWithPrefix(value)),
                  ),
                ),
                FormMixin.horizontalSeparator,
                Expanded(
                  flex: 1,
                  child: textField(
                    context: context,
                    label: 'Suffix',
                    originalText: widget.current?.suffix ?? '',
                    textController: suffixTextController,
                    onChanged: (value) => onChangedValue(copyWithSuffix(value)),
                  ),
                ),
              ],
            ),
            FormMixin.verticalSeparator,
            optionsAndForm(),
          ],
        ),
      ),
    );
  }

  T copyWithPrefix(String value);
  T copyWithSuffix(String value);

  Widget optionsAndForm();
}

class PluralTranslationFormState extends TranslationWithParameterFormState<PluralTranslationForm,
    ArbPluralDefinition, ArbPluralTranslation> {
  @override
  ArbPluralTranslationBuilder get builder => super.builder as ArbPluralTranslationBuilder;

  @override
  Widget optionsAndForm() => TranslationPluralsAndForm(
        translationBuilder: builder,
        definition: widget.definition,
        locale: widget.current?.locale ?? widget.beingEdited.locale,
        translationController: translationController,
        onUpdateTranslation: onChangedValue,
      );

  @override
  ArbPluralTranslation copyWithPrefix(String value) =>
      translationController.state.copyWith(prefix: value);

  @override
  ArbPluralTranslation copyWithSuffix(String value) =>
      translationController.state.copyWith(suffix: value);
}

class SelectTranslationFormState extends TranslationWithParameterFormState<SelectTranslationForm,
    ArbSelectDefinition, ArbSelectTranslation> {
  @override
  ArbSelectTranslationBuilder get builder => super.builder as ArbSelectTranslationBuilder;

  @override
  void resetState() {
    super.resetState();
    builder.knownCases = widget.knownCases;
  }

  @override
  Widget optionsAndForm() => TranslationSelectsAndForm(
        translationBuilder: builder,
        definition: widget.definition,
        locale: widget.current?.locale ?? widget.beingEdited.locale,
        translationController: translationController,
        onUpdateTranslation: onChangedValue,
      );

  @override
  ArbSelectTranslation copyWithPrefix(String value) =>
      translationController.state.copyWith(prefix: value);

  @override
  ArbSelectTranslation copyWithSuffix(String value) =>
      translationController.state.copyWith(suffix: value);
}

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../builder/arb_builder.dart';
import 'placeholders_text_editing_controller.dart';
import 'plurals_and_form.dart';

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
  });

  @override
  State<TranslationForm<ArbSelectDefinition, ArbSelectTranslation>> createState() =>
      SelectTranslationFormState();
}

abstract class TranslationFormState<D extends ArbDefinition, T extends ArbTranslation>
    extends State<TranslationForm<D, T>> with TextFormFieldMixin {
  late ArbTranslationBuilder builder;
  late StateController<T> translationController;

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant TranslationForm<D, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      resetState();
    }
  }

  @mustCallSuper
  void resetState() {
    translationController = StateController<T>(widget.beingEdited);
    builder = ArbTranslationBuilder(
        displayOption: widget.displayOption,
        definition: widget.definition,
        translation: translationController.state);
  }

  @override
  Widget build(BuildContext context) {
    builder.init(context);
    final ThemeData theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      children: [
        title(theme.textTheme, colors),
        const SizedBox(height: 4.0),
        form(context, theme.colorScheme),
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

  void _saveChanges() => widget.onSaveChanges(translationController.state);

  bool get hasChanges => translationController.state != widget.current;

  Widget? subtitle() => null;

  Widget form(BuildContext context, ColorScheme colors);
}

class PlaceholdersTranslationFormState
    extends TranslationFormState<ArbPlaceholdersDefinition, ArbPlaceholdersTranslation>
    with ArbMixin {
  late PlaceholdersTextEditingController translationTextController =
      PlaceholdersTextEditingController(placeholders: widget.definition.placeholders);

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
        padding: const EdgeInsets.only(
          left: ArbBuilder.leadingSize + ArbBuilder.leadingSeparation,
          right: ArbBuilder.leadingSize,
        ),
        child: textField(
          context: context,
          label: 'Translation',
          originalText: widget.current?.value ?? '',
          textController: translationTextController,
          onChanged: _onChangedValue,
        ),
      ),
    );
  }

  void _onChangedValue(String value) {
    final placeholderNames = arbTranslationPlaceholderNames(value);
    setState(() {
      translationController
          .update((state) => state.copyWith(value: value, placeholderNames: placeholderNames));
      widget.onUpdate(translationController.state);
    });
  }
}

class PluralTranslationFormState
    extends TranslationFormState<ArbPluralDefinition, ArbPluralTranslation> {
  TextEditingController prefixTextController = TextEditingController();
  TextEditingController suffixTextController = TextEditingController();

  @override
  ArbPluralTranslationBuilder get builder => super.builder as ArbPluralTranslationBuilder;

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
        padding: const EdgeInsets.only(
          left: ArbBuilder.leadingSize + ArbBuilder.leadingSeparation,
          right: ArbBuilder.leadingSize,
        ),
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
                    onChanged: (value) =>
                        _onChangedValue(translationController.state.copyWith(prefix: value)),
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
                    onChanged: (value) =>
                        _onChangedValue(translationController.state.copyWith(suffix: value)),
                  ),
                ),
              ],
            ),
            FormMixin.verticalSeparator,
            PluralsAndForm(
              translationBuilder: builder,
              definition: widget.definition,
              locale: widget.current?.locale ?? widget.beingEdited.locale,
              translationController: translationController,
              onUpdateTranslation: (value) => _onChangedValue(value as ArbPluralTranslation),
            ),
          ],
        ),
      ),
    );
  }

  void _onChangedValue(ArbPluralTranslation value) {
    setState(() {
      builder.translation = value;
      translationController.state = value;
      widget.onUpdate(value);
    });
  }
}

class SelectTranslationFormState
    extends TranslationFormState<ArbSelectDefinition, ArbSelectTranslation> {
  @override
  Widget form(BuildContext context, ColorScheme colors) {
    return Container();
  }

  @override
  bool get hasChanges => false;

  @override
  void resetState() {
    super.resetState();
  }
}

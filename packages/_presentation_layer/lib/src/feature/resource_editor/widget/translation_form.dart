import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/text_form_field_mixin.dart';
import 'translation_tile_mixin.dart';

abstract class TranslationForm extends StatefulWidget {
  const TranslationForm({
    super.key,
    required this.locale,
    required this.current,
    required this.beingEdited,
    required this.onUpdate,
    required this.onSaveChanges,
    required this.onDiscardChanges,
  });

  final String locale;
  final ArbTranslation? current;
  final ArbTranslation beingEdited;
  final ValueChanged<ArbTranslation> onUpdate;
  final ValueChanged<ArbTranslation> onSaveChanges;
  final VoidCallback onDiscardChanges;
}

class PlaceholdersTranslationForm extends TranslationForm {
  const PlaceholdersTranslationForm({
    super.key,
    required super.locale,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<PlaceholdersTranslationForm> createState() => TextTranslationFormState();
}

class PluralTranslationForm extends TranslationForm {
  const PluralTranslationForm({
    super.key,
    required super.locale,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<PluralTranslationForm> createState() => PluralTranslationFormState();
}

class SelectTranslationForm extends TranslationForm {
  const SelectTranslationForm({
    super.key,
    required super.locale,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<SelectTranslationForm> createState() => SelectTranslationFormState();
}

abstract class TranslationFormState<T extends TranslationForm> extends State<T>
    with TranslationTileMixin, TextFormFieldMixin {
  late ArbTranslation formTranslation;

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      resetState();
    }
  }

  @mustCallSuper
  void resetState() {
    formTranslation = widget.beingEdited;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        title(theme.textTheme),
        const SizedBox(height: 4.0),
        form(context, theme.colorScheme),
      ],
    );
  }

  Widget title(TextTheme theme) {
    return tileTitle(
      theme,
      title: widget.locale,
      trailing: Row(children: [
        IconButton(icon: const Icon(Icons.check), onPressed: hasChanges ? _saveChanges : null),
        IconButton(icon: const Icon(Icons.close), onPressed: widget.onDiscardChanges),
      ]),
    );
  }

  void _saveChanges() => widget.onSaveChanges(formTranslation);

  bool get hasChanges;

  Widget form(BuildContext context, ColorScheme colors);
}

class TextTranslationFormState extends TranslationFormState<PlaceholdersTranslationForm> {
  TextEditingController translationTextController = TextEditingController();

  @override
  void dispose() {
    translationTextController.dispose();
    super.dispose();
  }

  @override
  void resetState() {
    super.resetState();
    translationTextController.text = formTranslation.value;
  }

  @override
  bool get hasChanges => formTranslation.value != (widget.current?.value ?? '');

  @override
  Widget form(BuildContext context, ColorScheme colors) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.only(
          left: TranslationTileMixin.leadingSize + TranslationTileMixin.leadingSeparation,
          right: TranslationTileMixin.leadingSize,
        ),
        child: textField(
          context: context,
          label: 'Translation',
          originalText: formTranslation.value,
          textController: translationTextController,
          onChanged: (value) => setState(() {
            formTranslation = formTranslation.copyWith(value: value);
            widget.onUpdate(formTranslation);
          }),
        ),
      ),
    );
  }
}

class PluralTranslationFormState extends TranslationFormState<PluralTranslationForm> {
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

class SelectTranslationFormState extends TranslationFormState<SelectTranslationForm> {
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

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import 'translation_form_mixin.dart';
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

class TextTranslationForm extends TranslationForm {
  const TextTranslationForm({
    super.key,
    required super.locale,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<TextTranslationForm> createState() => TextTranslationFormState();
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
    with TranslationTileMixin, TranslationFormMixin {
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
        form(theme.colorScheme),
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

  Widget form(ColorScheme colors);
}

class TextTranslationFormState extends TranslationFormState<TextTranslationForm> {
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
  Widget form(ColorScheme colors) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.only(
          left: TranslationTileMixin.leadingSize + TranslationTileMixin.leadingSeparation,
          right: TranslationTileMixin.leadingSize,
        ),
        child: textField(
          colors: colors,
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
  Widget form(ColorScheme colors) {
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
  Widget form(ColorScheme colors) {
    return Container();
  }

  @override
  bool get hasChanges => false;

  @override
  void resetState() {
    super.resetState();
  }
}

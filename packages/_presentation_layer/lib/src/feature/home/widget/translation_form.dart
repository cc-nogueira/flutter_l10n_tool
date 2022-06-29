import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import 'translation_form_mixin.dart';
import 'translation_tile_mixin.dart';

abstract class TranslationForm extends StatefulWidget {
  const TranslationForm({
    super.key,
    required this.locale,
    required this.original,
    required this.current,
    required this.onDiscardChanges,
    required this.onSaveChanges,
  });

  final String locale;
  final ArbTranslation? original;
  final ArbTranslation current;
  final VoidCallback? onDiscardChanges;
  final VoidCallback? onSaveChanges;

  String get translationValue => current.value;
  String get originalValue => original?.value ?? '';
}

class TextTranslationForm extends TranslationForm {
  const TextTranslationForm({
    super.key,
    required super.locale,
    required super.original,
    required super.current,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<TextTranslationForm> createState() => TextTranslationFormState();
}

class PluralTranslationForm extends TranslationForm {
  const PluralTranslationForm({
    super.key,
    required super.locale,
    required super.original,
    required super.current,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<PluralTranslationForm> createState() => PluralTranslationFormState();
}

class SelectTranslationForm extends TranslationForm {
  const SelectTranslationForm({
    super.key,
    required super.locale,
    required super.original,
    required super.current,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<SelectTranslationForm> createState() => SelectTranslationFormState();
}

abstract class TranslationFormState<T extends TranslationForm> extends State<T>
    with TranslationTileMixin, TranslationFormMixin {
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

  void resetState();

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
        IconButton(
            icon: const Icon(Icons.check), onPressed: hasChanges ? widget.onSaveChanges : null),
        IconButton(icon: const Icon(Icons.close), onPressed: widget.onDiscardChanges),
      ]),
    );
  }

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
    translationTextController.text = widget.translationValue;
  }

  @override
  bool get hasChanges => translationTextController.text != (widget.translationValue);

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
          originalText: widget.originalValue,
          textController: translationTextController,
          onChanged: (_) => setState(() {}),
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
  void resetState() {}
}

class SelectTranslationFormState extends TranslationFormState<SelectTranslationForm> {
  @override
  Widget form(ColorScheme colors) {
    return Container();
  }

  @override
  bool get hasChanges => false;

  @override
  void resetState() {}
}

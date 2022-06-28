import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TranslationWidget extends ConsumerWidget {
  const TranslationWidget(this.locale, this.definition, this.translation, {super.key});

  final String locale;
  final ArbDefinition definition;
  final ArbTranslation? translation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final beingEdited = translation == null
        ? null
        : ref.watch(beingEditedTranslationsForLanguageProvider(locale)
            .select((value) => value[translation]));

    final isBeingEdited = beingEdited != null;
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
      child: isBeingEdited ? _form(ref.read) : _tile(ref.read),
    );
  }

  Widget _tile(Reader read) {
    switch (definition.type) {
      case ArbDefinitionType.plural:
        return _PluralTranslationTile(
          locale: locale,
          translation: translation,
          onEdit: () => _editTranslation(read),
        );
      case ArbDefinitionType.select:
        return _SelectTranslationTile(
          locale: locale,
          translation: translation,
          onEdit: () => _editTranslation(read),
        );
      default:
        return _TextTranslationTile(
          locale: locale,
          translation: translation,
          onEdit: () => _editTranslation(read),
        );
    }
  }

  Widget _form(Reader read) {
    switch (definition.type) {
      case ArbDefinitionType.plural:
        return _PluralTranslationForm(
          locale: locale,
          translation: translation,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      case ArbDefinitionType.select:
        return _SelectTranslationForm(
          locale: locale,
          translation: translation,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      default:
        return _TextTranslationForm(
          locale: locale,
          translation: translation,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
    }
  }

  void _editTranslation(Reader read) {
    if (translation != null) {
      read(arbUsecaseProvider).editTranslation(locale, definition, translation!);
    }
  }

  void _discardChanges(Reader read) {
    if (translation != null) {
      read(arbUsecaseProvider).discardTranslationChanges(locale, definition, translation!);
    }
  }

  void _saveChanges(Reader read) {}
}

mixin _TranslationTileMixin {
  static const leadingIcon = Icon(Icons.translate);
  static const leadingSize = 48.0;
  static const leadingSeparation = 8.0;
  static const leadingSeparator = SizedBox(width: leadingSeparation);

  Widget tileTitle(TextTheme theme, String locale, {required Widget trailing}) {
    return Row(
      children: [
        const SizedBox(width: leadingSize, height: leadingSize, child: Center(child: leadingIcon)),
        leadingSeparator,
        Expanded(child: Text(locale, style: theme.titleMedium)),
        trailing,
      ],
    );
  }
}

mixin _TranslationFormMixin {
  Widget textField({
    required ColorScheme colors,
    required String label,
    String? hintText,
    required String originalText,
    required TextEditingController textController,
    required ValueChanged<String> onChanged,
    int? maxLines,
  }) {
    final hasChanges = textController.text != originalText;
    return TextFormField(
      controller: textController,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 0.0),
        border: const OutlineInputBorder(),
        enabledBorder: _enabledBorder(colors, hasChanges),
        focusedBorder: _focusedBorder(colors, hasChanges),
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        counterText: '',
      ),
      onChanged: onChanged,
      maxLines: maxLines,
    );
  }

  InputBorder? _enabledBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 1.2))
      : null;

  InputBorder? _focusedBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 2.0))
      : null;
}

abstract class _TranslationTile extends StatelessWidget with _TranslationTileMixin {
  const _TranslationTile({
    required this.locale,
    required this.translation,
    required this.onEdit,
  });

  final String locale;
  final ArbTranslation? translation;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return tileTitle(textTheme, locale, trailing: _trailing);
  }

  Widget get _trailing => IconButton(icon: const Icon(Icons.edit), iconSize: 20, onPressed: onEdit);
}

class _TextTranslationTile extends _TranslationTile {
  const _TextTranslationTile({
    required super.locale,
    required super.translation,
    required super.onEdit,
  });
}

class _PluralTranslationTile extends _TranslationTile {
  const _PluralTranslationTile({
    required super.locale,
    required super.translation,
    required super.onEdit,
  });
}

class _SelectTranslationTile extends _TranslationTile {
  const _SelectTranslationTile({
    required super.locale,
    required super.translation,
    required super.onEdit,
  });
}

abstract class _TranslationForm extends StatefulWidget {
  const _TranslationForm({
    required this.locale,
    required this.translation,
    required this.onDiscardChanges,
    required this.onSaveChanges,
  });

  final String locale;
  final ArbTranslation? translation;
  final VoidCallback? onDiscardChanges;
  final VoidCallback? onSaveChanges;
}

class _TextTranslationForm extends _TranslationForm {
  const _TextTranslationForm({
    required super.locale,
    required super.translation,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<_TextTranslationForm> createState() => _TextTranslationFormState();
}

class _PluralTranslationForm extends _TranslationForm {
  const _PluralTranslationForm({
    required super.locale,
    required super.translation,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<_PluralTranslationForm> createState() => _PluralTranslationFormState();
}

class _SelectTranslationForm extends _TranslationForm {
  const _SelectTranslationForm({
    required super.locale,
    required super.translation,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<_SelectTranslationForm> createState() => _SelectTranslationFormState();
}

abstract class _TranslationFormState<T extends _TranslationForm> extends State<T>
    with _TranslationTileMixin, _TranslationFormMixin {
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
      widget.locale,
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

class _TextTranslationFormState extends _TranslationFormState<_TextTranslationForm> {
  TextEditingController translationTextController = TextEditingController();

  @override
  void dispose() {
    translationTextController.dispose();
    super.dispose();
  }

  @override
  void resetState() {
    translationTextController.text = widget.translation?.value ?? '';
  }

  @override
  bool get hasChanges => translationTextController.text != (widget.translation?.value ?? '');

  @override
  Widget form(ColorScheme colors) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.only(
          left: _TranslationTileMixin.leadingSize + _TranslationTileMixin.leadingSeparation,
          right: _TranslationTileMixin.leadingSize,
        ),
        child: textField(
          colors: colors,
          label: 'Translation',
          textController: translationTextController,
          originalText: widget.translation?.value ?? '',
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }
}

class _PluralTranslationFormState extends _TranslationFormState<_PluralTranslationForm> {
  @override
  Widget form(ColorScheme colors) {
    return Container();
  }

  @override
  bool get hasChanges => false;

  @override
  void resetState() {}
}

class _SelectTranslationFormState extends _TranslationFormState<_SelectTranslationForm> {
  @override
  Widget form(ColorScheme colors) {
    return Container();
  }

  @override
  bool get hasChanges => false;

  @override
  void resetState() {}
}

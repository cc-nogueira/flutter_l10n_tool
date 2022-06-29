import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TranslationWidget extends ConsumerWidget {
  TranslationWidget(this.locale, this.definition, this.translation, {super.key});

  final String locale;
  final ArbDefinition definition;
  final ArbTranslation? translation;
  final translationController = StateController<ArbTranslation?>(null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final displayOption = ref.watch(displayOptionProvider);
    final beingEdited = translation == null
        ? null
        : ref.watch(beingEditedTranslationsForLanguageProvider(locale)
            .select((value) => value[translation]));

    translationController.state = beingEdited;

    final isBeingEdited = beingEdited != null;
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
      child: isBeingEdited ? _form(ref.read, displayOption) : _tile(ref.read, displayOption),
    );
  }

  Widget _tile(Reader read, DisplayOption displayOption) {
    if (definition is ArbTextDefinition) {
      return _TextTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: translationController.state ?? translation,
        definition: definition as ArbTextDefinition,
        onEdit: () => _editTranslation(read),
      );
    } else if (definition is ArbSelectDefinition) {
      return _SelectTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: translationController.state ?? translation,
        definition: definition as ArbSelectDefinition,
        onEdit: () => _editTranslation(read),
      );
    } else if (definition is ArbPluralDefinition) {
      return _PluralTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: translationController.state ?? translation,
        definition: definition as ArbPluralDefinition,
        onEdit: () => _editTranslation(read),
      );
    } else {
      throw StateError('Illegal ArbDefinition type');
    }
  }

  Widget _form(Reader read, DisplayOption displayOption) {
    switch (definition.type) {
      case ArbDefinitionType.plural:
        return _PluralTranslationForm(
          locale: locale,
          original: translation,
          current: translationController.state,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      case ArbDefinitionType.select:
        return _SelectTranslationForm(
          locale: locale,
          original: translation,
          current: translationController.state,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      default:
        return _TextTranslationForm(
          locale: locale,
          original: translation,
          current: translationController.state,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
    }
  }

  void _editTranslation(Reader read) {
    read(arbUsecaseProvider).editTranslation(
        locale, definition, translation ?? ArbTranslation(key: definition.key, value: ''));
  }

  void _discardChanges(Reader read) {
    if (translation != null) {
      read(arbUsecaseProvider).discardTranslationChanges(locale, definition, translation!);
    }
  }

  void _saveChanges(Reader read) {}
}

abstract class _TranslationTile<T extends ArbDefinition> extends StatelessWidget
    with _TranslationTileMixin {
  const _TranslationTile({
    required this.displayOption,
    required this.locale,
    required this.translation,
    required this.definition,
    required this.onEdit,
  });

  final DisplayOption displayOption;
  final String locale;
  final ArbTranslation? translation;
  final T definition;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = tileContent(theme.textTheme, theme.colorScheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tileTitle(theme.textTheme, title: locale, subtitle: subtitle, trailing: titleTrailing),
        const SizedBox(height: 4.0),
        if (content != null) content,
      ],
    );
  }

  String? get subtitle => null;

  Widget get titleTrailing =>
      IconButton(icon: const Icon(Icons.edit), iconSize: 20, onPressed: onEdit);

  Widget? tileContent(TextTheme theme, ColorScheme colors) => null;
}

class _TextTranslationTile extends _TranslationTile<ArbTextDefinition> {
  const _TextTranslationTile({
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.onEdit,
  });

  @override
  String? get subtitle => translation?.value;
}

class _PluralTranslationTile extends _TranslationTile<ArbPluralDefinition> {
  const _PluralTranslationTile({
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.onEdit,
  });
}

class _SelectTranslationTile extends _TranslationTile<ArbSelectDefinition> {
  const _SelectTranslationTile({
    required super.displayOption,
    required super.locale,
    required super.translation,
    required super.definition,
    required super.onEdit,
  });

  @override
  String? get subtitle => displayOption.isCompact ? translation?.value : null;

  @override
  Widget? tileContent(TextTheme theme, ColorScheme colors) {
    if (displayOption.isCompact) {
      return null;
    }
    final mStyle = markingStyle(theme);
    final vStyle = valueStyle(theme);
    final oStyle = optionStyle(theme, colors);
    return Padding(
      padding: const EdgeInsets.only(
        left: _TranslationTileMixin.leadingSize + _TranslationTileMixin.leadingSeparation,
        right: _TranslationTileMixin.leadingSize,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('{ ', style: mStyle),
            Text(definition.mainPlaceholder(), style: vStyle),
            Text(', ', style: mStyle),
            Text('select', style: oStyle),
            Text(', ', style: mStyle),
            Text('...', style: vStyle),
            Text(' }', style: mStyle),
          ]),
          const SizedBox(height: 8),
          ...options(theme, colors),
        ],
      ),
    );
  }

  List<Widget> options(TextTheme theme, ColorScheme colors) {
    final mStyle = markingStyle(theme);
    final vStyle = valueStyle(theme);
    final oStyle = optionStyle(theme, colors);
    final value = translation?.value ?? '';
    const hSpace = SizedBox(width: 4);
    if (value.trim().isEmpty) {
      return const [Text('empty')];
    }
    final options = ArbUtil.mainOptions(definition.type, value);
    return [
      for (final option in options.entries)
        Row(children: [
          const Icon(
            Icons.swap_horiz,
            size: 20,
          ),
          hSpace,
          Text(option.key, style: vStyle),
          Text('{', style: mStyle),
          hSpace,
          Text(option.value, style: oStyle),
          hSpace,
          Text('}', style: mStyle),
        ]),
    ];
  }
}

abstract class _TranslationForm extends StatefulWidget {
  const _TranslationForm({
    required this.locale,
    required this.original,
    required this.current,
    required this.onDiscardChanges,
    required this.onSaveChanges,
  });

  final String locale;
  final ArbTranslation? original;
  final ArbTranslation? current;
  final VoidCallback? onDiscardChanges;
  final VoidCallback? onSaveChanges;

  String get translationValue => current?.value ?? original?.value ?? '';
  String get originalValue => original?.value ?? '';
}

class _TextTranslationForm extends _TranslationForm {
  const _TextTranslationForm({
    required super.locale,
    required super.original,
    required super.current,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<_TextTranslationForm> createState() => _TextTranslationFormState();
}

class _PluralTranslationForm extends _TranslationForm {
  const _PluralTranslationForm({
    required super.locale,
    required super.original,
    required super.current,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<_PluralTranslationForm> createState() => _PluralTranslationFormState();
}

class _SelectTranslationForm extends _TranslationForm {
  const _SelectTranslationForm({
    required super.locale,
    required super.original,
    required super.current,
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

class _TextTranslationFormState extends _TranslationFormState<_TextTranslationForm> {
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
          left: _TranslationTileMixin.leadingSize + _TranslationTileMixin.leadingSeparation,
          right: _TranslationTileMixin.leadingSize,
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

mixin _TranslationTileMixin {
  static const leadingIcon = Icon(Icons.translate);
  static const leadingSize = 40.0;
  static const leadingSeparation = 12.0;
  static const leadingSeparator = SizedBox(width: leadingSeparation);

  Widget tileTitle(TextTheme theme,
      {required String title, String? subtitle, required Widget trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: leadingSize, height: leadingSize, child: Center(child: leadingIcon)),
        leadingSeparator,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle(theme)),
              if (subtitle != null) Text(subtitle, style: subtitleStyle(theme)),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  TextStyle titleStyle(TextTheme theme) => theme.titleMedium!;

  TextStyle subtitleStyle(TextTheme theme) =>
      theme.bodyMedium!.copyWith(color: theme.caption?.color);

  TextStyle markingStyle(TextTheme theme) => subtitleStyle(theme);

  TextStyle valueStyle(TextTheme theme) => theme.bodyMedium!;

  TextStyle optionStyle(TextTheme theme, ColorScheme colors) =>
      theme.bodyMedium!.copyWith(color: colors.primary);
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

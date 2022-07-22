import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/text_form_field_mixin.dart';
import '../builder/arb_builder.dart';

abstract class TranslationForm extends StatefulWidget {
  const TranslationForm({
    super.key,
    required this.displayOption,
    required this.locale,
    required this.current,
    required this.beingEdited,
    required this.onUpdate,
    required this.onSaveChanges,
    required this.onDiscardChanges,
  });

  final DisplayOption displayOption;
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
    required super.displayOption,
    required super.locale,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<PlaceholdersTranslationForm> createState() => PlaceholdersTranslationFormState();
}

class PluralTranslationForm extends TranslationForm {
  const PluralTranslationForm({
    super.key,
    required super.displayOption,
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
    required super.displayOption,
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
    with TextFormFieldMixin {
  late ArbTranslation formTranslation;
  late ArbTranslationBuilder arbBuilder;

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
    arbBuilder =
        ArbTranslationBuilder(displayOption: widget.displayOption, translation: formTranslation);
  }

  @override
  Widget build(BuildContext context) {
    arbBuilder.init(context);
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
    return arbBuilder.tileTitle(
      title: Text(widget.locale, style: arbBuilder.titleStyle),
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

class PlaceholdersTranslationFormState extends TranslationFormState<PlaceholdersTranslationForm>
    with ArbMixin {
  TextEditingController translationTextController = TextEditingController();

  @override
  ArbPlaceholdersTranslation get formTranslation =>
      super.formTranslation as ArbPlaceholdersTranslation;

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
  bool get hasChanges => formTranslation != widget.current;

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
          originalText: formTranslation.value,
          textController: translationTextController,
          onChanged: _onChangedValue,
        ),
      ),
    );
  }

  void _onChangedValue(String value) {
    final placeholderNames = arbTranslationPlaceholderNames(value);
    setState(() {
      formTranslation = formTranslation.copyWith(value: value, placeholderNames: placeholderNames);
      widget.onUpdate(formTranslation);
    });
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

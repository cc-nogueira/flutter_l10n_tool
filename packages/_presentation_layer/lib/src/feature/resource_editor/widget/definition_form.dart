import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../../../common/widget/label_divider.dart';
import 'definition_tile_mixin.dart';
import 'placeholder_form.dart';
import 'text_form_field_mixin.dart';

abstract class DefinitionForm<T extends ArbDefinition> extends StatefulWidget {
  const DefinitionForm({
    super.key,
    required this.current,
    required this.beingEdited,
    required this.onUpdate,
    required this.onUpdatePlaceholder,
    required this.onSaveChanges,
    required this.onDiscardChanges,
  });

  final T current;
  final T beingEdited;
  final ValueChanged<ArbDefinition> onUpdate;
  final ValueChanged<ArbPlaceholder> onUpdatePlaceholder;
  final ValueChanged<ArbDefinition> onSaveChanges;
  final VoidCallback onDiscardChanges;
}

class TextDefinitionForm extends DefinitionForm<ArbTextDefinition> {
  const TextDefinitionForm({
    super.key,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onUpdatePlaceholder,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<DefinitionForm<ArbTextDefinition>> createState() => TextDefinitionFormState();
}

class PluralDefinitionForm extends DefinitionForm<ArbPluralDefinition> {
  const PluralDefinitionForm({
    super.key,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onUpdatePlaceholder,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<DefinitionForm<ArbPluralDefinition>> createState() => PluralDefinitionFormState();
}

class SelectDefinitionForm extends DefinitionForm<ArbSelectDefinition> {
  const SelectDefinitionForm({
    super.key,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onUpdatePlaceholder,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<DefinitionForm<ArbSelectDefinition>> createState() => SelectDefinitionFormState();
}

abstract class DefinitionFormState<T extends ArbDefinition> extends State<DefinitionForm<T>>
    with DefinitionTileMixin, TextFormFieldMixin {
  late T formDefinition;

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant DefinitionForm<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      resetState();
    }
  }

  @mustCallSuper
  void resetState() {
    formDefinition = widget.beingEdited;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Form(
      child: Container(
        decoration: BoxDecoration(color: colors.primaryContainer),
        padding: const EdgeInsets.all(8.0),
        child: definitionTile(
          content: form(theme.colorScheme),
          trailing: trailing(),
        ),
      ),
    );
  }

  Widget trailing() => Row(children: [
        IconButton(icon: const Icon(Icons.check), onPressed: hasChanges ? _saveChanges : null),
        IconButton(icon: const Icon(Icons.close), onPressed: widget.onDiscardChanges),
      ]);

  void _saveChanges() => widget.onSaveChanges(formDefinition);

  bool get hasChanges => formDefinition != widget.current;

  Widget form(ColorScheme colors);
}

class TextDefinitionFormState extends DefinitionFormState<ArbTextDefinition> {
  TextEditingController keyTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();
  ArbPlaceholder placeHolderBeingEdited = const ArbPlaceholder(key: '');

  @override
  void dispose() {
    keyTextController.dispose();
    descTextController.dispose();
    super.dispose();
  }

  @override
  void resetState() {
    super.resetState();
    keyTextController.text = formDefinition.key;
    descTextController.text = formDefinition.description ?? '';
    placeHolderBeingEdited = const ArbPlaceholder();
  }

  @override
  Widget form(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textField(
          colors: colors,
          label: 'Key',
          originalText: formDefinition.key,
          textController: keyTextController,
          onChanged: (value) => setState(() {
            formDefinition = formDefinition.copyWith(key: value);
            widget.onUpdate(formDefinition);
          }),
          inputFormatters: [textInputKeyFormatter],
        ),
        DefinitionTileMixin.verticalSeparator,
        textField(
          colors: colors,
          label: 'Description',
          originalText: formDefinition.description ?? '',
          textController: descTextController,
          onChanged: (value) => setState(() {
            formDefinition = formDefinition.copyWith(description: value);
            widget.onUpdate(formDefinition);
          }),
        ),
        DefinitionTileMixin.verticalSeparator,
        placeholders(colors),
      ],
    );
  }

  Widget placeholders(ColorScheme colors) {
    return Column(
      children: [
        LabelDivider(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          color: colors.onBackground,
          label: const Text('Placeholders'),
          separation: 8.0,
        ),
        if (formDefinition.placeholders?.isNotEmpty ?? false)
          Row(children: [
            for (final each in formDefinition.placeholders!) placeholderTag(each),
          ]),
        PlaceholderForm(placeholder: placeHolderBeingEdited, onUpdate: widget.onUpdatePlaceholder),
      ],
    );
  }

  Widget placeholderTag(ArbPlaceholder placeholder) {
    return Text(placeholder.key);
  }
}

class PluralDefinitionFormState extends DefinitionFormState<ArbPluralDefinition> {
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

class SelectDefinitionFormState extends DefinitionFormState<ArbSelectDefinition> {
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

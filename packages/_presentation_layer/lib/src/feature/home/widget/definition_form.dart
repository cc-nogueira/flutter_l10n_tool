import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import 'definition_form_mixin.dart';
import 'definition_tile_mixin.dart';

abstract class DefinitionForm<T extends ArbDefinition> extends StatefulWidget {
  const DefinitionForm({
    super.key,
    required this.current,
    required this.beingEdited,
    required this.onUpdate,
    required this.onDiscardChanges,
    required this.onSaveChanges,
  });

  final T current;
  final T beingEdited;
  final VoidCallback onDiscardChanges;
  final ValueChanged<ArbDefinition> onUpdate;
  final ValueChanged<ArbDefinition> onSaveChanges;
}

class TextDefinitionForm extends DefinitionForm<ArbTextDefinition> {
  const TextDefinitionForm({
    super.key,
    required super.current,
    required super.beingEdited,
    required super.onUpdate,
    required super.onDiscardChanges,
    required super.onSaveChanges,
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
    required super.onDiscardChanges,
    required super.onSaveChanges,
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
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<DefinitionForm<ArbSelectDefinition>> createState() => SelectDefinitionFormState();
}

abstract class DefinitionFormState<T extends ArbDefinition> extends State<DefinitionForm<T>>
    with DefinitionTileMixin, DefinitionFormMixin {
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tileIcon(),
            DefinitionFormMixin.leadingSeparator,
            Expanded(child: form(theme.colorScheme)),
            trailing(),
          ],
        ),
      ),
    );
  }

  Widget trailing() => Row(children: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: hasChanges ? _saveChanges : null,
        ),
        IconButton(icon: const Icon(Icons.close), onPressed: widget.onDiscardChanges),
      ]);

  void _saveChanges() => widget.onSaveChanges(formDefinition);

  bool get hasChanges;

  Widget form(ColorScheme colors);
}

class TextDefinitionFormState extends DefinitionFormState<ArbTextDefinition> {
  TextEditingController keyTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();

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
  }

  @override
  bool get hasChanges =>
      formDefinition.key != widget.current.key ||
      (formDefinition.description ?? '') != (widget.current.description ?? '');

  @override
  Widget form(ColorScheme colors) {
    return Column(
      children: [
        textField(
          colors: colors,
          label: 'Key',
          originalText: widget.beingEdited.key,
          textController: keyTextController,
          onChanged: (value) => setState(() {
            formDefinition = formDefinition.copyWith(key: value);
            widget.onUpdate(formDefinition);
          }),
        ),
        DefinitionFormMixin.verticalSeparator,
        textField(
          colors: colors,
          label: 'Description',
          originalText: widget.beingEdited.description ?? '',
          textController: descTextController,
          onChanged: (value) => setState(() {
            formDefinition = formDefinition.copyWith(description: value);
            widget.onUpdate(formDefinition);
          }),
        ),
      ],
    );
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

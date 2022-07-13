import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../../../l10n/app_localizations.dart';
import 'definition_tile_mixin.dart';
import 'placeholders_and_form.dart';

abstract class DefinitionForm<T extends ArbDefinition> extends StatefulWidget {
  const DefinitionForm({
    super.key,
    required this.current,
    required this.beingEdited,
    this.placeholderBeingEdited,
    required this.onUpdate,
    required this.onUpdatePlaceholder,
    required this.onSaveChanges,
    required this.onDiscardChanges,
  });

  final T current;
  final T beingEdited;
  final ArbPlaceholder? placeholderBeingEdited;
  final ValueChanged<ArbDefinition> onUpdate;
  final ValueChanged<ArbPlaceholder?> onUpdatePlaceholder;
  final ValueChanged<ArbDefinition> onSaveChanges;
  final VoidCallback onDiscardChanges;
}

class TextDefinitionForm extends DefinitionForm<ArbTextDefinition> {
  const TextDefinitionForm({
    super.key,
    required super.current,
    required super.beingEdited,
    required super.placeholderBeingEdited,
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
  late StateController<T> definitionController;
  late StateController<ArbPlaceholder?> placeholderController;

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
    definitionController = StateController<T>(widget.beingEdited);
    placeholderController = StateController<ArbPlaceholder?>(widget.placeholderBeingEdited);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Form(
      child: Container(
        decoration: BoxDecoration(color: colors.primaryContainer),
        padding: const EdgeInsets.all(8.0),
        child: definitionTile(
          content: form(context, loc, colors),
          trailing: trailing(),
        ),
      ),
    );
  }

  Widget trailing() => Row(children: [
        IconButton(icon: const Icon(Icons.check), onPressed: hasChanges ? _saveChanges : null),
        IconButton(icon: const Icon(Icons.close), onPressed: widget.onDiscardChanges),
      ]);

  void _saveChanges() => widget.onSaveChanges(definitionController.state);

  bool get hasChanges => definitionController.state != widget.current;

  Widget form(BuildContext context, AppLocalizations loc, ColorScheme colors);
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
    keyTextController.text = definitionController.state.key;
    descTextController.text = definitionController.state.description ?? '';
  }

  @override
  Widget form(BuildContext context, AppLocalizations loc, ColorScheme colors) {
    final formDefinition = definitionController.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textField(
          context: context,
          label: 'Key',
          originalText: formDefinition.key,
          textController: keyTextController,
          onChanged: (value) => setState(() {
            definitionController.update((state) => state.copyWith(key: value));
            widget.onUpdate(formDefinition);
          }),
          inputFormatters: [textInputKeyFormatter],
        ),
        FormMixin.verticalSeparator,
        textField(
          context: context,
          label: 'Description',
          originalText: formDefinition.description ?? '',
          textController: descTextController,
          onChanged: (value) => setState(() {
            definitionController.update((state) => state.copyWith(description: value));
            widget.onUpdate(formDefinition);
          }),
        ),
        FormMixin.verticalSeparator,
        PlaceholdersAndForm(
          loc,
          colors,
          definitionController: definitionController,
          placeholderController: placeholderController,
          onUpdatePlaceholder: widget.onUpdatePlaceholder,
        ),
      ],
    );
  }
}

class PluralDefinitionFormState extends DefinitionFormState<ArbPluralDefinition> {
  @override
  Widget form(BuildContext context, AppLocalizations loc, ColorScheme colors) {
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
  Widget form(BuildContext context, AppLocalizations loc, ColorScheme colors) {
    return Container();
  }

  @override
  bool get hasChanges => false;

  @override
  void resetState() {
    super.resetState();
  }
}

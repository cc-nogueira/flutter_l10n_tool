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
    required this.originalDefinition,
    required this.currentDefinition,
    required this.definitionBeingEdited,
    required this.onUpdateDefinition,
    required this.onSaveChanges,
    required this.onDiscardChanges,
  });

  final ArbDefinition originalDefinition;
  final T currentDefinition;
  final T definitionBeingEdited;
  final ValueChanged<ArbDefinition> onUpdateDefinition;
  final ValueChanged<ArbDefinition> onSaveChanges;
  final VoidCallback onDiscardChanges;
}

class TextDefinitionForm extends DefinitionForm<ArbTextDefinition> {
  const TextDefinitionForm({
    super.key,
    required super.originalDefinition,
    required super.currentDefinition,
    required super.definitionBeingEdited,
    required super.onUpdateDefinition,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<DefinitionForm<ArbTextDefinition>> createState() => TextDefinitionFormState();
}

class PluralDefinitionForm extends DefinitionForm<ArbPluralDefinition> {
  const PluralDefinitionForm({
    super.key,
    required super.originalDefinition,
    required super.currentDefinition,
    required super.definitionBeingEdited,
    required super.onUpdateDefinition,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<DefinitionForm<ArbPluralDefinition>> createState() => PluralDefinitionFormState();
}

class SelectDefinitionForm extends DefinitionForm<ArbSelectDefinition> {
  const SelectDefinitionForm({
    super.key,
    required super.originalDefinition,
    required super.currentDefinition,
    required super.definitionBeingEdited,
    required super.onUpdateDefinition,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<DefinitionForm<ArbSelectDefinition>> createState() => SelectDefinitionFormState();
}

abstract class DefinitionFormState<T extends ArbDefinition> extends State<DefinitionForm<T>>
    with DefinitionTileMixin, TextFormFieldMixin {
  late StateController<T> definitionController;

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
    definitionController = StateController<T>(widget.definitionBeingEdited);
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

  bool get hasChanges => definitionController.state != widget.currentDefinition;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textField(
          context: context,
          label: 'Key',
          originalText: definitionController.state.key,
          textController: keyTextController,
          onChanged: (value) => setState(() {
            definitionController.update((state) => state.copyWith(key: value));
            widget.onUpdateDefinition(definitionController.state);
          }),
          inputFormatters: [textInputKeyFormatter],
        ),
        FormMixin.verticalSeparator,
        textField(
          context: context,
          label: 'Description',
          originalText: definitionController.state.description ?? '',
          textController: descTextController,
          onChanged: (value) => setState(() {
            definitionController.update((state) => state.copyWith(description: value));
            widget.onUpdateDefinition(definitionController.state);
          }),
        ),
        FormMixin.verticalSeparator,
        PlaceholdersAndForm(
          originalDefinition: widget.originalDefinition,
          definitionController: definitionController,
          onUpdateDefinition: _onUpdateDefinition,
        ),
      ],
    );
  }

  void _onUpdateDefinition(ArbDefinition definition) {
    setState(() => widget.onUpdateDefinition(definition));
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

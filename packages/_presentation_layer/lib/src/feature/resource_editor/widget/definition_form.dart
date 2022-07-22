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
  final ArbDefinition currentDefinition;
  final T definitionBeingEdited;
  final ValueChanged<ArbDefinition> onUpdateDefinition;
  final ValueChanged<ArbDefinition> onSaveChanges;
  final VoidCallback onDiscardChanges;
}

class PlaceholdersDefinitionForm extends DefinitionForm<ArbPlaceholdersDefinition> {
  const PlaceholdersDefinitionForm({
    super.key,
    required super.originalDefinition,
    required super.currentDefinition,
    required super.definitionBeingEdited,
    required super.onUpdateDefinition,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<DefinitionForm<ArbPlaceholdersDefinition>> createState() =>
      PlaceholdersDefinitionFormState();
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
  TextEditingController keyTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();

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

  @override
  void dispose() {
    keyTextController.dispose();
    descTextController.dispose();
    super.dispose();
  }

  @mustCallSuper
  void resetState() {
    definitionController = StateController<T>(widget.definitionBeingEdited);
    keyTextController.text = definitionController.state.key;
    descTextController.text = definitionController.state.description ?? '';
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
          align: CrossAxisAlignment.start,
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

  Widget form(BuildContext context, AppLocalizations loc, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: formChildren(context, loc, colors),
    );
  }

  List<Widget> formChildren(BuildContext context, AppLocalizations loc, ColorScheme colors) {
    return [
      textField(
        context: context,
        label: 'Key',
        originalText: definitionController.state.key,
        textController: keyTextController,
        onChanged: (value) => setState(() {
          definitionController.update((state) => state.copyWith(key: value) as T);
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
          definitionController.update((state) => state.copyWith(description: value) as T);
          widget.onUpdateDefinition(definitionController.state);
        }),
      ),
    ];
  }
}

class PlaceholdersDefinitionFormState extends DefinitionFormState<ArbPlaceholdersDefinition> {
  @override
  List<Widget> formChildren(BuildContext context, AppLocalizations loc, ColorScheme colors) {
    return [
      ...super.formChildren(context, loc, colors),
      FormMixin.verticalSeparator,
      PlaceholdersAndForm(
        originalDefinition: widget.originalDefinition,
        definitionController: definitionController,
        onUpdateDefinition: (value) => setState(() => widget.onUpdateDefinition(value)),
      ),
    ];
  }
}

class PluralDefinitionFormState extends DefinitionFormState<ArbPluralDefinition> {
  TextEditingController placeholderNameTextController = TextEditingController();

  @override
  void resetState() {
    super.resetState();
    placeholderNameTextController.text = definitionController.state.parameterName;
  }

  @override
  void dispose() {
    placeholderNameTextController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formChildren(BuildContext context, AppLocalizations loc, ColorScheme colors) {
    final children = super.formChildren(context, loc, colors);
    children[0] = Row(
      children: [
        Expanded(flex: 3, child: children[0]),
        FormMixin.horizontalSeparator,
        Expanded(
          flex: 1,
          child: textField(
            context: context,
            label: 'Parameter',
            originalText: definitionController.state.parameterName,
            textController: placeholderNameTextController,
            onChanged: (value) => setState(() {
              definitionController.update((state) => state.copyWith(parameterName: value));
              widget.onUpdateDefinition(definitionController.state);
            }),
            inputFormatters: [textInputPublicVariableFormatter],
          ),
        ),
      ],
    );
    return children;
  }
}

class SelectDefinitionFormState extends DefinitionFormState<ArbSelectDefinition> {
  TextEditingController placeholderNameTextController = TextEditingController();

  @override
  void resetState() {
    super.resetState();
    placeholderNameTextController.text = definitionController.state.parameterName;
  }

  @override
  void dispose() {
    placeholderNameTextController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formChildren(BuildContext context, AppLocalizations loc, ColorScheme colors) {
    final children = super.formChildren(context, loc, colors);
    children[0] = Row(
      children: [
        Expanded(flex: 3, child: children[0]),
        FormMixin.horizontalSeparator,
        Expanded(
          flex: 1,
          child: textField(
            context: context,
            label: 'Parameter',
            originalText: definitionController.state.parameterName,
            textController: placeholderNameTextController,
            onChanged: (value) => setState(() {
              definitionController.update((state) => state.copyWith(parameterName: value));
              widget.onUpdateDefinition(definitionController.state);
            }),
            inputFormatters: [textInputPublicVariableFormatter],
          ),
        ),
      ],
    );
    return children;
  }
}

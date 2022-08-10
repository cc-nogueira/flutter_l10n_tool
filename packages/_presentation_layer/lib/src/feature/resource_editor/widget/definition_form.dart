import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../../../l10n/app_localizations.dart';
import '../builder/arb_builder.dart';
import 'definition_placeholders_and_form.dart';

abstract class DefinitionForm<D extends ArbDefinition> extends StatefulWidget {
  const DefinitionForm({
    super.key,
    required this.displayOption,
    required this.originalDefinition,
    required this.currentDefinition,
    required this.definitionBeingEdited,
    required this.onUpdateDefinition,
    required this.onSaveChanges,
    required this.onDiscardChanges,
  });

  static DefinitionForm of<T extends ArbDefinition>({
    required DisplayOption displayOption,
    required T originalDefinition,
    required T currentDefinition,
    required T definitionBeingEdited,
    required ValueChanged<ArbDefinition> onUpdateDefinition,
    required ValueChanged<ArbDefinition> onSaveChanges,
    required VoidCallback onDiscardChanges,
  }) {
    return definitionBeingEdited.map(
      newDefinition: (def) => NewDefinitionForm(
        displayOption: displayOption,
        originalDefinition: originalDefinition as ArbNewDefinition,
        currentDefinition: currentDefinition as ArbNewDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: onUpdateDefinition,
        onSaveChanges: onSaveChanges,
        onDiscardChanges: onDiscardChanges,
      ),
      placeholders: (def) => PlaceholdersDefinitionForm(
        displayOption: displayOption,
        originalDefinition: originalDefinition as ArbPlaceholdersDefinition,
        currentDefinition: currentDefinition as ArbPlaceholdersDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: onUpdateDefinition,
        onSaveChanges: onSaveChanges,
        onDiscardChanges: onDiscardChanges,
      ),
      plural: (def) => PluralDefinitionForm(
        displayOption: displayOption,
        originalDefinition: originalDefinition as ArbPluralDefinition,
        currentDefinition: currentDefinition as ArbPluralDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: onUpdateDefinition,
        onSaveChanges: onSaveChanges,
        onDiscardChanges: onDiscardChanges,
      ),
      select: (def) => SelectDefinitionForm(
        displayOption: displayOption,
        originalDefinition: originalDefinition as ArbSelectDefinition,
        currentDefinition: currentDefinition as ArbSelectDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: onUpdateDefinition,
        onSaveChanges: onSaveChanges,
        onDiscardChanges: onDiscardChanges,
      ),
    );
  }

  final DisplayOption displayOption;
  final D originalDefinition;
  final D currentDefinition;
  final D definitionBeingEdited;
  final ValueChanged<ArbDefinition> onUpdateDefinition;
  final ValueChanged<ArbDefinition> onSaveChanges;
  final VoidCallback onDiscardChanges;
}

class NewDefinitionForm extends DefinitionForm<ArbNewDefinition> {
  const NewDefinitionForm({
    super.key,
    required super.displayOption,
    required super.originalDefinition,
    required super.currentDefinition,
    required super.definitionBeingEdited,
    required super.onUpdateDefinition,
    required super.onSaveChanges,
    required super.onDiscardChanges,
  });

  @override
  State<DefinitionForm<ArbNewDefinition>> createState() => NewDefinitionFormState();
}

class PlaceholdersDefinitionForm extends DefinitionForm<ArbPlaceholdersDefinition> {
  const PlaceholdersDefinitionForm({
    super.key,
    required super.displayOption,
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
    required super.displayOption,
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
    required super.displayOption,
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

abstract class DefinitionFormState<D extends ArbDefinition> extends State<DefinitionForm<D>>
    with TextFormFieldMixin {
  late ArbDefinitionBuilder builder;
  late StateController<D> definitionController;
  TextEditingController keyTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant DefinitionForm<D> oldWidget) {
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
    definitionController = StateController<D>(widget.definitionBeingEdited);
    keyTextController.text = definitionController.state.key;
    descTextController.text = definitionController.state.description ?? '';
    builder = ArbDefinitionBuilder(
      displayOption: widget.displayOption,
      definition: definitionController.state,
    );
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
        child: builder.definitionTile(
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
      typeAndKeyWidgets(context),
      FormMixin.verticalSeparator,
      descriptionWidget(context),
    ];
  }

  Widget typeAndKeyWidgets(BuildContext context) => Row(
        children: [
          Expanded(flex: 1, child: typeWidget(context)),
          FormMixin.horizontalSeparator,
          Expanded(flex: 3, child: keyWidget(context)),
        ],
      );

  Widget typeWidget(BuildContext context) => textField(
        context: context,
        label: 'Type',
        originalText: '',
        onChanged: (value) {},
      );

  Widget keyWidget(BuildContext context) => textField(
        context: context,
        label: 'Key',
        originalText: definitionController.state.key,
        textController: keyTextController,
        onChanged: (value) =>
            onUpdateDefinition(definitionController.state.copyWith(key: value) as D),
        inputFormatters: [textInputKeyFormatter],
      );

  Widget descriptionWidget(BuildContext context) => textField(
        context: context,
        label: 'Description',
        originalText: definitionController.state.description ?? '',
        textController: descTextController,
        onChanged: (value) =>
            onUpdateDefinition(definitionController.state.copyWith(description: value) as D),
      );

  void onUpdateDefinition(D definition) {
    setState(() {
      builder.definition = definition;
      definitionController.state = definition;
      widget.onUpdateDefinition(definition);
    });
  }
}

class NewDefinitionFormState extends DefinitionFormState<ArbNewDefinition> {}

class PlaceholdersDefinitionFormState extends DefinitionFormState<ArbPlaceholdersDefinition> {
  @override
  List<Widget> formChildren(BuildContext context, AppLocalizations loc, ColorScheme colors) {
    return [
      ...super.formChildren(context, loc, colors),
      FormMixin.verticalSeparator,
      DefinitionPlaceholdersAndForm(
        originalDefinition: widget.originalDefinition,
        definitionController: definitionController,
        onUpdateDefinition: (value) => onUpdateDefinition(value as ArbPlaceholdersDefinition),
      ),
    ];
  }
}

abstract class DefinitionWithParamFormState<D extends ArbDefinition>
    extends DefinitionFormState<D> {
  TextEditingController placeholderNameTextController = TextEditingController();

  String get parameterName;
  D copyWithParameterName(String value);

  @override
  void resetState() {
    super.resetState();
    placeholderNameTextController.text = parameterName;
  }

  @override
  void dispose() {
    placeholderNameTextController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formChildren(BuildContext context, AppLocalizations loc, ColorScheme colors) {
    return [
      typeAndKeyWidgets(context),
      FormMixin.verticalSeparator,
      Row(
        children: [
          Expanded(flex: 1, child: paramWidget(context)),
          FormMixin.horizontalSeparator,
          Expanded(flex: 3, child: descriptionWidget(context)),
        ],
      )
    ];
  }

  Widget paramWidget(BuildContext context) => textField(
        context: context,
        label: 'Parameter',
        originalText: parameterName,
        textController: placeholderNameTextController,
        onChanged: (value) => onUpdateDefinition(copyWithParameterName(value)),
        inputFormatters: [textInputPublicVariableFormatter],
      );
}

class PluralDefinitionFormState extends DefinitionWithParamFormState<ArbPluralDefinition> {
  @override
  String get parameterName => definitionController.state.parameterName;

  @override
  ArbPluralDefinition copyWithParameterName(String value) =>
      definitionController.state.copyWith(parameterName: value);
}

class SelectDefinitionFormState extends DefinitionWithParamFormState<ArbSelectDefinition> {
  @override
  String get parameterName => definitionController.state.parameterName;

  @override
  ArbSelectDefinition copyWithParameterName(String value) =>
      definitionController.state.copyWith(parameterName: value);
}

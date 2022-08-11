import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/form_dropdown.dart';
import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/text_form_field_mixin.dart';
import '../../../l10n/app_localizations.dart';
import '../builder/arb_builder.dart';
import 'definition_placeholders_and_form.dart';

typedef ChangeTypeCallback = void Function(ArbDefinition definition,
    {required ArbDefinitionType type});

typedef DiscardNewDefinitionCallback = void Function({required ArbDefinition original});

class NewDefinitionForm extends StatefulWidget {
  const NewDefinitionForm({
    super.key,
    required this.onSaveNewDefinition,
    required this.onDiscardNewDefinition,
  });

  final ValueChanged<ArbDefinition> onSaveNewDefinition;
  final DiscardNewDefinitionCallback onDiscardNewDefinition;

  @override
  State<NewDefinitionForm> createState() => _NewDefinitionFormState();
}

class _NewDefinitionFormState extends State<NewDefinitionForm> {
  static const emptyDefinitions = {
    ArbDefinitionType.placeholders: ArbPlaceholdersDefinition(),
    ArbDefinitionType.plural: ArbPluralDefinition(),
    ArbDefinitionType.select: ArbSelectDefinition(),
  };

  final currentDefinitionTypeController = StateController(ArbDefinitionType.placeholders);

  final beingEditedDefinitionController = StateController<Map<ArbDefinitionType, ArbDefinition>>({
    ArbDefinitionType.placeholders: const ArbPlaceholdersDefinition(),
    ArbDefinitionType.plural: const ArbPluralDefinition(),
    ArbDefinitionType.select: const ArbSelectDefinition(),
  });

  @override
  Widget build(BuildContext context) {
    final type = currentDefinitionTypeController.state;
    final beingEdited = beingEditedDefinitionController.state[type]!;
    final emptyDef = emptyDefinitions[beingEdited.type]!;
    return DefinitionForm.of(
      originalDefinition: emptyDef,
      currentDefinition: emptyDef,
      definitionBeingEdited: beingEdited,
      onSaveChanges: widget.onSaveNewDefinition,
      onDiscardChanges: () => widget.onDiscardNewDefinition(original: emptyDef),
      onUpdateDefinition: onUpdateDefinition,
      onChangeType: onChangeType,
    );
  }

  void onUpdateDefinition(ArbDefinition definition) {
    beingEditedDefinitionController.state[definition.type] = definition;
  }

  void onChangeType(ArbDefinition definition, {required ArbDefinitionType type}) {
    if (definition.type != type) {
      final prevDefinition = beingEditedDefinitionController.state[type]!;
      final changedDefinition = prevDefinition.copyWith(
        key: definition.key,
        description: definition.description,
      );
      setState(() {
        beingEditedDefinitionController.state[type] = changedDefinition;
        currentDefinitionTypeController.state = type;
      });
    }
  }
}

abstract class DefinitionForm<D extends ArbDefinition> extends ConsumerStatefulWidget {
  const DefinitionForm({
    super.key,
    required this.originalDefinition,
    required this.currentDefinition,
    required this.definitionBeingEdited,
    required this.onUpdateDefinition,
    required this.onSaveChanges,
    required this.onDiscardChanges,
    required this.onChangeType,
  });

  static DefinitionForm of<T extends ArbDefinition>({
    required T originalDefinition,
    required T currentDefinition,
    required T definitionBeingEdited,
    required ValueChanged<ArbDefinition> onUpdateDefinition,
    required ValueChanged<ArbDefinition> onSaveChanges,
    required VoidCallback onDiscardChanges,
    required ChangeTypeCallback onChangeType,
  }) {
    return definitionBeingEdited.map(
      placeholders: (def) => PlaceholdersDefinitionForm(
        originalDefinition: originalDefinition as ArbPlaceholdersDefinition,
        currentDefinition: currentDefinition as ArbPlaceholdersDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: onUpdateDefinition,
        onSaveChanges: onSaveChanges,
        onDiscardChanges: onDiscardChanges,
        onChangeType: onChangeType,
      ),
      plural: (def) => PluralDefinitionForm(
        originalDefinition: originalDefinition as ArbPluralDefinition,
        currentDefinition: currentDefinition as ArbPluralDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: onUpdateDefinition,
        onSaveChanges: onSaveChanges,
        onDiscardChanges: onDiscardChanges,
        onChangeType: onChangeType,
      ),
      select: (def) => SelectDefinitionForm(
        originalDefinition: originalDefinition as ArbSelectDefinition,
        currentDefinition: currentDefinition as ArbSelectDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: onUpdateDefinition,
        onSaveChanges: onSaveChanges,
        onDiscardChanges: onDiscardChanges,
        onChangeType: onChangeType,
      ),
    );
  }

  final D originalDefinition;
  final D currentDefinition;
  final D definitionBeingEdited;
  final ValueChanged<ArbDefinition> onUpdateDefinition;
  final ValueChanged<ArbDefinition> onSaveChanges;
  final VoidCallback onDiscardChanges;
  final ChangeTypeCallback onChangeType;
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
    required super.onChangeType,
  });

  @override
  ConsumerState<DefinitionForm<ArbPlaceholdersDefinition>> createState() =>
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
    required super.onChangeType,
  });

  @override
  ConsumerState<DefinitionForm<ArbPluralDefinition>> createState() => PluralDefinitionFormState();
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
    required super.onChangeType,
  });

  @override
  ConsumerState<DefinitionForm<ArbSelectDefinition>> createState() => SelectDefinitionFormState();
}

abstract class DefinitionFormState<D extends ArbDefinition> extends ConsumerState<DefinitionForm<D>>
    with TextFormFieldMixin {
  late ArbDefinitionBuilder builder;
  late StateController<D> definitionController;
  TextEditingController keyTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
    builder = ArbDefinitionBuilder.of(definition: definitionController.state);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(color: colors.primaryContainer),
        padding: const EdgeInsets.all(8.0),
        child: builder.definitionTile(
          align: CrossAxisAlignment.start,
          content: form(context, loc, colors),
          trailing: trailing(context),
        ),
      ),
    );
  }

  Widget trailing(BuildContext context) => Row(children: [
        IconButton(
            icon: const Icon(Icons.check),
            onPressed: hasChanges ? () => _saveChanges(context) : null),
        IconButton(icon: const Icon(Icons.close), onPressed: widget.onDiscardChanges),
      ]);

  void _saveChanges(BuildContext context) {
    final form = _formKey.currentState!;
    form.save();
    if (form.validate()) {
      widget.onSaveChanges(definitionController.state);
    }
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: typeWidget(context)),
          FormMixin.horizontalSeparator,
          Expanded(flex: 3, child: keyWidget(context)),
        ],
      );

  Widget typeWidget(BuildContext context) => FormDropdown<ArbDefinitionType>(
        label: 'Type',
        options: const [
          ArbDefinitionType.placeholders,
          ArbDefinitionType.plural,
          ArbDefinitionType.select,
        ],
        optionLabel: (value) => value.name,
        originalValue: widget.originalDefinition.type,
        formValue: definitionController.state.type,
        validator: (value) => value == null ? '* required' : null,
        onChanged: (option) {
          if (option == null || option == definitionController.state.type) {
            return;
          }
          widget.onChangeType(definitionController.state, type: option);
        },
      );

  Widget keyWidget(BuildContext context) => textField(
        context: context,
        label: 'Key',
        originalText: definitionController.state.key,
        textController: keyTextController,
        validator: (text) => text == null || text.isEmpty ? '* required' : null,
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

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'definition_form.dart';
import 'definition_tile.dart';

abstract class DefinitionWidget<D extends ArbDefinition> extends ConsumerWidget {
  DefinitionWidget({required this.original, required this.current, super.key});

  final D original;
  final D? current;
  final _rebuildProvider = StateProvider<bool>((ref) => false);

  D get currentOrOriginal => current ?? original;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_rebuildProvider);

    final displayOption = ref.watch(displayOptionProvider);
    final definitionBeingEdited = ref.read(beingEditedDefinitionsProvider)[original];

    return definitionBeingEdited == null
        ? _tile(ref.read, displayOption, isOriginal: current == null)
        : _form(ref.read, displayOption, definitionBeingEdited);
  }

  Widget _tile(Reader read, DisplayOption displayOption, {required bool isOriginal});
  Widget _form(Reader read, DisplayOption displayOption, ArbDefinition definitionBeingEdited);

  void _edit(Reader read, ArbDefinition current) {
    _updateDefinition(read, current);
    _rebuild(read);
  }

  void _rollback(Reader read) {
    read(arbUsecaseProvider).rollbackDefinition(original: original);
  }

  void _updateDefinition(Reader read, ArbDefinition beingEdited) {
    read(arbUsecaseProvider).updateDefinitionBeingEdited(original: original, current: beingEdited);
  }

  void _discardChanges(Reader read) {
    final usecase = read(arbUsecaseProvider);
    usecase.discardDefinitionChanges(original: original);
    _rebuild(read);
  }

  void _saveChanges(Reader read, ArbDefinition value) {
    read(arbUsecaseProvider).saveDefinition(original: original, value: value);
    _rebuild(read);
  }

  void _rebuild(Reader read) => read(_rebuildProvider.notifier).update((state) => !state);
}

class NewDefinitionWidget extends DefinitionWidget<ArbNewDefinition> {
  NewDefinitionWidget({required super.original, super.key}) : super(current: null);

  @override
  Widget _tile(Reader read, DisplayOption displayOption, {required bool isOriginal}) =>
      NewDefinitionTile(
        displayOption: displayOption,
        definition: currentOrOriginal,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, currentOrOriginal),
        onRollback: () => _rollback(read),
      );

  @override
  Widget _form(Reader read, DisplayOption displayOption, ArbDefinition definitionBeingEdited) =>
      NewDefinitionForm(
        displayOption: displayOption,
        originalDefinition: original,
        currentDefinition: currentOrOriginal,
        definitionBeingEdited: definitionBeingEdited as ArbNewDefinition,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
}

class PlaceholdersDefinitionWidget extends DefinitionWidget<ArbPlaceholdersDefinition> {
  PlaceholdersDefinitionWidget({required super.original, required super.current, super.key});

  @override
  Widget _tile(Reader read, DisplayOption displayOption, {required bool isOriginal}) =>
      PlaceholdersDefinitionTile(
        displayOption: displayOption,
        definition: currentOrOriginal,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, currentOrOriginal),
        onRollback: () => _rollback(read),
      );

  @override
  Widget _form(Reader read, DisplayOption displayOption, ArbDefinition definitionBeingEdited) =>
      PlaceholdersDefinitionForm(
        displayOption: displayOption,
        originalDefinition: original,
        currentDefinition: currentOrOriginal,
        definitionBeingEdited: definitionBeingEdited as ArbPlaceholdersDefinition,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
}

class PluralDefinitionWidget extends DefinitionWidget<ArbPluralDefinition> {
  PluralDefinitionWidget({required super.original, required super.current, super.key});

  @override
  Widget _tile(Reader read, DisplayOption displayOption, {required bool isOriginal}) =>
      PluralDefinitionTile(
        displayOption: displayOption,
        definition: currentOrOriginal,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, currentOrOriginal),
        onRollback: () => _rollback(read),
      );

  @override
  Widget _form(Reader read, DisplayOption displayOption, ArbDefinition definitionBeingEdited) =>
      PluralDefinitionForm(
        displayOption: displayOption,
        originalDefinition: original,
        currentDefinition: currentOrOriginal,
        definitionBeingEdited: definitionBeingEdited as ArbPluralDefinition,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
}

class SelectDefinitionWidget extends DefinitionWidget<ArbSelectDefinition> {
  SelectDefinitionWidget({required super.original, required super.current, super.key});

  @override
  Widget _tile(Reader read, DisplayOption displayOption, {required bool isOriginal}) =>
      SelectDefinitionTile(
        displayOption: displayOption,
        definition: currentOrOriginal,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, currentOrOriginal),
        onRollback: () => _rollback(read),
      );

  @override
  Widget _form(Reader read, DisplayOption displayOption, ArbDefinition definitionBeingEdited) =>
      SelectDefinitionForm(
        displayOption: displayOption,
        originalDefinition: original,
        currentDefinition: currentOrOriginal,
        definitionBeingEdited: definitionBeingEdited as ArbSelectDefinition,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
}

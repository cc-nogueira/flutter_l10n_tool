import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'definition_form.dart';
import 'definition_tile.dart';

class DefinitionWidget<D extends ArbDefinition> extends ConsumerWidget {
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

    return definitionBeingEdited is D
        ? _form(ref.read, definitionBeingEdited)
        : _tile(ref.read, displayOption, isOriginal: current == null);
  }

  Widget _tile(Reader read, DisplayOption displayOption, {required bool isOriginal}) =>
      DefinitionTile.of(
        displayOption: displayOption,
        definition: currentOrOriginal,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, currentOrOriginal),
        onRollback: () => _rollback(read),
      );

  Widget _form(Reader read, D definitionBeingEdited) => DefinitionForm.of(
        originalDefinition: original,
        currentDefinition: currentOrOriginal,
        definitionBeingEdited: definitionBeingEdited,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
        onChangeType: (definition, {required type}) =>
            _changeDefinitionType(read, definition, type: type),
      );

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

  void _changeDefinitionType(Reader read, ArbDefinition value, {required ArbDefinitionType type}) {}

  void _rebuild(Reader read) => read(_rebuildProvider.notifier).update((state) => !state);
}

class NewDefinitionWidget extends ConsumerWidget {
  const NewDefinitionWidget({super.key, required this.onDone});

  final AsyncCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NewDefinitionForm(
      onSaveNewDefinition: ({required original, required value}) =>
          _saveNewDefinition(ref.read, original: original, value: value),
      onDiscardNewDefinition: ({required original}) => _discardNew(ref.read, original: original),
    );
  }

  void _discardNew(Reader read, {required ArbDefinition original}) {
    onDone().then((_) {
      read(arbUsecaseProvider).cancelEditingNewDefinition(original: original);
    });
  }

  void _saveNewDefinition(Reader read,
      {required ArbDefinition original, required ArbDefinition value}) {
    onDone().then((_) {
      read(arbUsecaseProvider).saveNewDefinition(original: original, value: value);
    });
  }
}

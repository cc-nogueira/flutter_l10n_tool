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
        ? _form(ref, definitionBeingEdited)
        : _tile(ref, displayOption, isOriginal: current == null);
  }

  Widget _tile(WidgetRef ref, DisplayOption displayOption, {required bool isOriginal}) =>
      DefinitionTile.of(
        displayOption: displayOption,
        definition: currentOrOriginal,
        isOriginal: isOriginal,
        onEdit: () => _edit(ref, currentOrOriginal),
        onRollback: () => _rollback(ref),
      );

  Widget _form(WidgetRef ref, D definitionBeingEdited) => DefinitionForm.of(
        originalDefinition: original,
        currentDefinition: currentOrOriginal,
        definitionBeingEdited: definitionBeingEdited,
        onUpdateDefinition: (value) => _updateDefinition(ref, value),
        onSaveChanges: (value) => _saveChanges(ref, value),
        onDiscardChanges: () => _discardChanges(ref),
        onChangeType: (definition, {required type}) =>
            _changeDefinitionType(ref, definition, type: type),
      );

  void _edit(WidgetRef ref, ArbDefinition current) {
    _updateDefinition(ref, current);
    _rebuild(ref);
  }

  void _rollback(WidgetRef ref) {
    ref.read(arbUsecaseProvider).rollbackDefinition(original: original);
  }

  void _updateDefinition(WidgetRef ref, ArbDefinition beingEdited) {
    ref
        .read(arbUsecaseProvider)
        .updateDefinitionBeingEdited(original: original, current: beingEdited);
  }

  void _discardChanges(WidgetRef ref) {
    final usecase = ref.read(arbUsecaseProvider);
    usecase.discardDefinitionChanges(original: original);
    _rebuild(ref);
  }

  void _saveChanges(WidgetRef ref, ArbDefinition value) {
    ref.read(arbUsecaseProvider).saveDefinition(original: original, value: value);
    _rebuild(ref);
  }

  void _changeDefinitionType(WidgetRef ref, ArbDefinition value,
      {required ArbDefinitionType type}) {}

  void _rebuild(WidgetRef ref) => ref.read(_rebuildProvider.notifier).update((state) => !state);
}

class NewDefinitionWidget extends ConsumerWidget {
  const NewDefinitionWidget({super.key, required this.onDone});

  final AsyncCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NewDefinitionForm(
      onSaveNewDefinition: ({required original, required value}) =>
          _saveNewDefinition(ref, original: original, value: value),
      onDiscardNewDefinition: ({required original}) => _discardNew(ref, original: original),
    );
  }

  void _discardNew(WidgetRef ref, {required ArbDefinition original}) {
    onDone().then((_) {
      ref.read(arbUsecaseProvider).cancelEditingNewDefinition(original: original);
    });
  }

  void _saveNewDefinition(WidgetRef ref,
      {required ArbDefinition original, required ArbDefinition value}) {
    onDone().then((_) {
      ref.read(arbUsecaseProvider).saveNewDefinition(original: original, value: value);
    });
  }
}

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'definition_form.dart';
import 'definition_tile.dart';

class DefinitionWidget extends ConsumerWidget {
  DefinitionWidget(this.original, {super.key});

  final ArbDefinition original;
  final _rebuildProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_rebuildProvider);

    final displayOption = ref.watch(displayOptionProvider);
    final currentDefinition =
        ref.watch(currentDefinitionsProvider.select((value) => value[original]));
    final currentOrOriginalDefinition = currentDefinition ?? original;
    final definitionBeingEdited = ref.read(beingEditedDefinitionsProvider)[original];

    return definitionBeingEdited == null
        ? _tile(ref.read, displayOption,
            definition: currentOrOriginalDefinition, isOriginal: currentDefinition == null)
        : _form(
            ref.read,
            currentDefinition: currentOrOriginalDefinition,
            definitionBeingEdited: definitionBeingEdited,
          );
  }

  Widget _tile(Reader read, DisplayOption displayOption,
      {required ArbDefinition definition, required bool isOriginal}) {
    return definition.map<DefinitionTile>(
      placeholders: (def) => PlaceholdersDefinitionTile(
        displayOption: displayOption,
        definition: def,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, definition),
        onRollback: () => _rollback(read),
      ),
      plural: (def) => PluralDefinitionTile(
        displayOption: displayOption,
        definition: def,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, definition),
        onRollback: () => _rollback(read),
      ),
      select: (def) => SelectDefinitionTile(
        displayOption: displayOption,
        definition: def,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, definition),
        onRollback: () => _rollback(read),
      ),
    );
  }

  Widget _form(
    Reader read, {
    required ArbDefinition currentDefinition,
    required ArbDefinition definitionBeingEdited,
  }) {
    return definitionBeingEdited.map<DefinitionForm>(
      placeholders: (def) => PlaceholdersDefinitionForm(
        originalDefinition: original,
        currentDefinition: currentDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
      plural: (def) => PluralDefinitionForm(
        originalDefinition: original,
        currentDefinition: currentDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
      select: (def) => SelectDefinitionForm(
        originalDefinition: original,
        currentDefinition: currentDefinition,
        definitionBeingEdited: def,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
    );
  }

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

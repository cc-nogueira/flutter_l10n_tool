import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'definition_form.dart';
import 'definition_tile.dart';

class DefinitionWidget extends ConsumerWidget {
  DefinitionWidget({required this.original, required this.current, super.key});

  final ArbDefinition original;
  final ArbDefinition? current;
  final _rebuildProvider = StateProvider<bool>((ref) => false);

  ArbDefinition get currentOrOriginal => current ?? original;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_rebuildProvider);

    final displayOption = ref.watch(displayOptionProvider);
    final definitionBeingEdited = ref.read(beingEditedDefinitionsProvider)[original];

    return definitionBeingEdited == null
        ? _tile(
            ref.read,
            displayOption,
            isOriginal: current == null,
          )
        : _form(
            ref.read,
            displayOption,
            definitionBeingEdited: definitionBeingEdited,
          );
  }

  Widget _tile(
    Reader read,
    DisplayOption displayOption, {
    required bool isOriginal,
  }) {
    return currentOrOriginal.map<DefinitionTile>(
      placeholders: (def) => PlaceholdersDefinitionTile(
        displayOption: displayOption,
        definition: def,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, def),
        onRollback: () => _rollback(read),
      ),
      plural: (def) => PluralDefinitionTile(
        displayOption: displayOption,
        definition: def,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, def),
        onRollback: () => _rollback(read),
      ),
      select: (def) => SelectDefinitionTile(
        displayOption: displayOption,
        definition: def,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, def),
        onRollback: () => _rollback(read),
      ),
    );
  }

  Widget _form(
    Reader read,
    DisplayOption displayOption, {
    required ArbDefinition definitionBeingEdited,
  }) {
    return definitionBeingEdited.map<DefinitionForm>(
      placeholders: (def) => PlaceholdersDefinitionForm(
        displayOption: displayOption,
        originalDefinition: original,
        currentDefinition: currentOrOriginal,
        definitionBeingEdited: def,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
      plural: (def) => PluralDefinitionForm(
        displayOption: displayOption,
        originalDefinition: original,
        currentDefinition: currentOrOriginal,
        definitionBeingEdited: def,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
      select: (def) => SelectDefinitionForm(
        displayOption: displayOption,
        originalDefinition: original,
        currentDefinition: currentOrOriginal,
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

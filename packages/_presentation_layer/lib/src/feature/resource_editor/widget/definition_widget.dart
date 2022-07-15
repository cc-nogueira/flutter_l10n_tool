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

    final currentDefinition =
        ref.watch(currentDefinitionsProvider.select((value) => value[original]));
    final currentOrOriginalDefinition = currentDefinition ?? original;
    final definitionBeingEdited = ref.read(beingEditedDefinitionsProvider)[original];
    final existingPlaceholderBeingEdited =
        ref.read(existingPlaceholdersBeingEditedProvider)[original];
    final formPlaceholder = ref.read(formPlaceholdersProvider)[original];

    return definitionBeingEdited == null
        ? _tile(ref.read,
            definition: currentOrOriginalDefinition, isOriginal: currentDefinition == null)
        : _form(ref.read,
            currentDefinition: currentOrOriginalDefinition,
            definitionBeingEdited: definitionBeingEdited,
            formPlaceholder: formPlaceholder,
            existingPlaceholderBeingEdited: existingPlaceholderBeingEdited);
  }

  Widget _tile(Reader read, {required ArbDefinition definition, required bool isOriginal}) {
    if (definition is ArbTextDefinition) {
      return TextDefinitionTile(
        definition: definition,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, definition),
      );
    }
    if (definition is ArbSelectDefinition) {
      return SelectDefinitionTile(
        definition: definition,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, definition),
      );
    }
    if (definition is ArbPluralDefinition) {
      return PluralDefinitionTile(
        definition: definition,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, definition),
      );
    }
    throw StateError('Illegal ArbDefinition type');
  }

  Widget _form(
    Reader read, {
    required ArbDefinition currentDefinition,
    required ArbDefinition definitionBeingEdited,
    required ArbPlaceholder? formPlaceholder,
    required ArbPlaceholder? existingPlaceholderBeingEdited,
  }) {
    if (currentDefinition is ArbTextDefinition && definitionBeingEdited is ArbTextDefinition) {
      return TextDefinitionForm(
        currentDefinition: currentDefinition,
        definitionBeingEdited: definitionBeingEdited,
        formPlaceholder: formPlaceholder,
        existingPlaceholderBeingEdited: existingPlaceholderBeingEdited,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onUpdatePlaceholder: (value) => _updateFormPlaceholder(read, value),
        onEditPlaceholder: (value) => _editPlaceholder(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
    }
    if (currentDefinition is ArbPluralDefinition && definitionBeingEdited is ArbPluralDefinition) {
      return PluralDefinitionForm(
        currentDefinition: currentDefinition,
        definitionBeingEdited: definitionBeingEdited,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onUpdatePlaceholder: (value) {},
        onEditPlaceholder: (value) {},
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
    }
    if (currentDefinition is ArbSelectDefinition && definitionBeingEdited is ArbSelectDefinition) {
      return SelectDefinitionForm(
        currentDefinition: currentDefinition,
        definitionBeingEdited: definitionBeingEdited,
        onUpdateDefinition: (value) => _updateDefinition(read, value),
        onUpdatePlaceholder: (value) {},
        onEditPlaceholder: (value) {},
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
    }
    throw StateError('Illegal ArbDefinition type');
  }

  void _edit(Reader read, ArbDefinition current) {
    _updateDefinition(read, current);
    _rebuild(read);
  }

  void _updateDefinition(Reader read, ArbDefinition beingEdited) {
    read(arbUsecaseProvider).editDefinition(original: original, current: beingEdited);
  }

  void _updateFormPlaceholder(Reader read, ArbPlaceholder? formPlaceholder) {
    read(arbUsecaseProvider)
        .updateFormPlaceholder(definition: original, placeholder: formPlaceholder);
  }

  void _editPlaceholder(Reader read, ArbPlaceholder? placeholder) {
    read(arbUsecaseProvider)
        .trackExistingPlaceholderBeingEdited(definition: original, placeholder: placeholder);
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

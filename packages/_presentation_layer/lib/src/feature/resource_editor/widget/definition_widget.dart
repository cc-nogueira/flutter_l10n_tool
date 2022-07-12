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

    final current = ref.watch(currentDefinitionsProvider.select((value) => value[original]));
    final currentOrOriginal = current ?? original;
    final beingEdited = ref.read(beingEditedDefinitionsProvider)[original];
    final placeholderBeingEdited = ref.read(beingEditedPlaceholdersProvider)[original];

    return beingEdited == null
        ? _tile(ref.read, current: currentOrOriginal)
        : _form(ref.read,
            current: currentOrOriginal,
            beingEdited: beingEdited,
            placeholderBeingEdited: placeholderBeingEdited);
  }

  Widget _tile(Reader read, {required ArbDefinition current}) {
    if (current is ArbTextDefinition) {
      return TextDefinitionTile(
        definition: current,
        onEdit: () => _edit(read, current),
      );
    }
    if (current is ArbSelectDefinition) {
      return SelectDefinitionTile(
        definition: current,
        onEdit: () => _edit(read, current),
      );
    }
    if (current is ArbPluralDefinition) {
      return PluralDefinitionTile(
        definition: current,
        onEdit: () => _edit(read, current),
      );
    }
    throw StateError('Illegal ArbDefinition type');
  }

  Widget _form(Reader read,
      {required ArbDefinition current,
      required ArbDefinition beingEdited,
      required ArbPlaceholder? placeholderBeingEdited}) {
    if (current is ArbTextDefinition && beingEdited is ArbTextDefinition) {
      return TextDefinitionForm(
        current: current,
        beingEdited: beingEdited,
        placeholderBeingEdited: placeholderBeingEdited,
        onUpdate: (value) => _updateBeingEdited(read, value),
        onUpdatePlaceholder: (value) => _updatePlaceholderBeingEdited(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
    }
    if (current is ArbPluralDefinition && beingEdited is ArbPluralDefinition) {
      return PluralDefinitionForm(
        current: current,
        beingEdited: beingEdited,
        onUpdate: (value) => _updateBeingEdited(read, value),
        onUpdatePlaceholder: (value) {},
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
    }
    if (current is ArbSelectDefinition && beingEdited is ArbSelectDefinition) {
      return SelectDefinitionForm(
        current: current,
        beingEdited: beingEdited,
        onUpdate: (value) => _updateBeingEdited(read, value),
        onUpdatePlaceholder: (value) {},
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      );
    }
    throw StateError('Illegal ArbDefinition type');
  }

  void _edit(Reader read, ArbDefinition current) {
    _updateBeingEdited(read, current);
    _rebuild(read);
  }

  void _updateBeingEdited(Reader read, ArbDefinition beingEdited) {
    read(arbUsecaseProvider).editDefinition(original: original, current: beingEdited);
  }

  void _updatePlaceholderBeingEdited(Reader read, ArbPlaceholder? beingEdited) {
    read(arbUsecaseProvider)
        .updatePlaceholderEdition(definition: original, placeholder: beingEdited);
  }

  void _discardChanges(Reader read) {
    read(arbUsecaseProvider).discardDefinitionChanges(original: original);
    _rebuild(read);
  }

  void _saveChanges(Reader read, ArbDefinition value) {
    read(arbUsecaseProvider).saveDefinition(original: original, value: value);
    _rebuild(read);
  }

  void _rebuild(Reader read) => read(_rebuildProvider.notifier).update((state) => !state);
}

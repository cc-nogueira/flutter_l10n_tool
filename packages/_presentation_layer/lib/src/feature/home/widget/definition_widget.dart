import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'definition_form.dart';
import 'definition_tile.dart';

class DefinitionWidget extends ConsumerWidget {
  DefinitionWidget(this.definition, {super.key});

  final ArbDefinition definition;
  late final definitionController = StateController<ArbDefinition>(definition);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beingEdited =
        ref.watch(beingEditedDefinitionsProvider.select((value) => value[definition]));

    if (beingEdited == null) {
      return _tile(ref.read);
    }
    definitionController.state = beingEdited;
    return _form(ref.read);
  }

  Widget _tile(Reader read) {
    if (definition is ArbTextDefinition) {
      return TextDefinitionTile(
        definition: definition as ArbTextDefinition,
        onEdit: () => _edit(read),
      );
    } else if (definition is ArbSelectDefinition) {
      return SelectDefinitionTile(
        definition: definition as ArbSelectDefinition,
        onEdit: () => _edit(read),
      );
    } else if (definition is ArbPluralDefinition) {
      return PluralDefinitionTile(
        definition: definition as ArbPluralDefinition,
        onEdit: () => _edit(read),
      );
    } else {
      throw StateError('Illegal ArbDefinition type');
    }
  }

  Widget _form(Reader read) {
    switch (definition.type) {
      case ArbDefinitionType.plural:
        return PluralDefinitionForm(
          original: definition,
          current: definitionController.state,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      case ArbDefinitionType.select:
        return SelectDefinitionForm(
          original: definition,
          current: definitionController.state,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      default:
        return TextDefinitionForm(
          original: definition,
          current: definitionController.state,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
    }
  }

  void _edit(Reader read) {
    read(arbUsecaseProvider).editDefinition(definition);
  }

  void _discardChanges(Reader read) {
    read(arbUsecaseProvider).discardDefinitionChanges(definition);
  }

  void _saveChanges(Reader read) {}
}

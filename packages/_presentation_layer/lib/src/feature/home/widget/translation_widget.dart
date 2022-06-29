import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'translation_form.dart';
import 'translation_tile.dart';

class TranslationWidget extends ConsumerWidget {
  TranslationWidget(this.locale, this.definition, this.translation, {super.key});

  final String locale;
  final ArbDefinition definition;
  final ArbTranslation? translation;
  final translationController = StateController<ArbTranslation?>(null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final displayOption = ref.watch(displayOptionProvider);
    final beingEdited = translation == null
        ? null
        : ref.watch(beingEditedTranslationsForLanguageProvider(locale)
            .select((value) => value[translation]));

    translationController.state = beingEdited;

    final isBeingEdited = beingEdited != null;
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
      child: isBeingEdited ? _form(ref.read, displayOption) : _tile(ref.read, displayOption),
    );
  }

  Widget _tile(Reader read, DisplayOption displayOption) {
    if (definition is ArbTextDefinition) {
      return TextTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: translationController.state ?? translation,
        definition: definition as ArbTextDefinition,
        onEdit: () => _edit(read),
      );
    } else if (definition is ArbSelectDefinition) {
      return SelectTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: translationController.state ?? translation,
        definition: definition as ArbSelectDefinition,
        onEdit: () => _edit(read),
      );
    } else if (definition is ArbPluralDefinition) {
      return PluralTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: translationController.state ?? translation,
        definition: definition as ArbPluralDefinition,
        onEdit: () => _edit(read),
      );
    } else {
      throw StateError('Illegal ArbDefinition type');
    }
  }

  Widget _form(Reader read, DisplayOption displayOption) {
    switch (definition.type) {
      case ArbDefinitionType.plural:
        return PluralTranslationForm(
          locale: locale,
          original: translation,
          current: translationController.state,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      case ArbDefinitionType.select:
        return SelectTranslationForm(
          locale: locale,
          original: translation,
          current: translationController.state,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      default:
        return TextTranslationForm(
          locale: locale,
          original: translation,
          current: translationController.state,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
    }
  }

  void _edit(Reader read) {
    read(arbUsecaseProvider).editTranslation(
        locale, definition, translation ?? ArbTranslation(key: definition.key, value: ''));
  }

  void _discardChanges(Reader read) {
    if (translation != null) {
      read(arbUsecaseProvider).discardTranslationChanges(locale, definition, translation!);
    }
  }

  void _saveChanges(Reader read) {}
}

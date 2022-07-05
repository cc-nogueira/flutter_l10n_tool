import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'translation_form.dart';
import 'translation_tile.dart';

class TranslationWidget extends ConsumerWidget {
  TranslationWidget(this.locale, this.definition, this.original, {super.key});

  final String locale;
  final ArbDefinition definition;
  final ArbTranslation? original;
  final _rebuildProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_rebuildProvider);

    final colors = Theme.of(context).colorScheme;
    final displayOption = ref.watch(displayOptionProvider);

    final current = ref.watch(
      currentTranslationsForLanguageProvider(locale).select((value) => value[definition]),
    );
    final currentOrOriginal = current ?? original;
    final beingEdited = ref.read(beingEditedTranslationsForLanguageProvider(locale))[definition];

    return beingEdited == null
        ? _withBorder(colors, _tile(ref.read, displayOption, current: currentOrOriginal))
        : _withBorder(
            colors,
            _form(ref.read, displayOption, current: currentOrOriginal, beingEdited: beingEdited),
          );
  }

  Widget _tile(Reader read, DisplayOption displayOption, {required ArbTranslation? current}) {
    if (definition is ArbTextDefinition) {
      return TextTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: current,
        definition: definition as ArbTextDefinition,
        onEdit: () => _edit(read, current),
      );
    } else if (definition is ArbSelectDefinition) {
      return SelectTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: current,
        definition: definition as ArbSelectDefinition,
        onEdit: () => _edit(read, current),
      );
    } else if (definition is ArbPluralDefinition) {
      return PluralTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: current,
        definition: definition as ArbPluralDefinition,
        onEdit: () => _edit(read, current),
      );
    } else {
      throw StateError('Illegal ArbDefinition type');
    }
  }

  Widget _form(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation? current,
    required ArbTranslation beingEdited,
  }) {
    switch (definition.type) {
      case ArbDefinitionType.plural:
        return PluralTranslationForm(
          locale: locale,
          current: current,
          beingEdited: beingEdited,
          onUpdate: (value) => _updateBeingEdited(read, value),
          onSaveChanges: (value) => _saveChanges(read, value),
          onDiscardChanges: () => _discardChanges(read),
        );
      case ArbDefinitionType.select:
        return SelectTranslationForm(
          locale: locale,
          current: current,
          beingEdited: beingEdited,
          onUpdate: (value) => _updateBeingEdited(read, value),
          onSaveChanges: (value) => _saveChanges(read, value),
          onDiscardChanges: () => _discardChanges(read),
        );
      default:
        return TextTranslationForm(
          locale: locale,
          current: current,
          beingEdited: beingEdited,
          onUpdate: (value) => _updateBeingEdited(read, value),
          onSaveChanges: (value) => _saveChanges(read, value),
          onDiscardChanges: () => _discardChanges(read),
        );
    }
  }

  Widget _withBorder(ColorScheme colors, Widget child) => Container(
        margin: const EdgeInsets.only(top: 12.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
        child: child,
      );

  void _edit(Reader read, ArbTranslation? current) {
    _updateBeingEdited(read, current ?? ArbTranslation(key: definition.key, value: ''));
    _rebuild(read);
  }

  void _updateBeingEdited(Reader read, ArbTranslation beingEdited) {
    read(arbUsecaseProvider).editTranslation(
      locale: locale,
      definition: definition,
      current: beingEdited,
    );
  }

  void _discardChanges(Reader read) {
    read(arbUsecaseProvider).discardTranslationChanges(locale: locale, definition: definition);
    _rebuild(read);
  }

  void _saveChanges(Reader read, ArbTranslation value) {
    read(arbUsecaseProvider).saveTranslation(locale: locale, definition: definition, value: value);
    _rebuild(read);
  }

  void _rebuild(Reader read) => read(_rebuildProvider.notifier).update((state) => !state);
}

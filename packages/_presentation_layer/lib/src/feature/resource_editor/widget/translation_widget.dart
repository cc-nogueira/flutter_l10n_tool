import 'package:_domain_layer/domain_layer.dart';
import 'package:dotted_border/dotted_border.dart';
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
    final beingEdited = ref.read(beingEditedTranslationsForLocaleProvider(locale))[definition];

    final tile = beingEdited != null
        ? _form(ref.read, displayOption, current: currentOrOriginal, beingEdited: beingEdited)
        : _tile(ref.read, displayOption, current: currentOrOriginal, isOriginal: current == null);

    return currentOrOriginal == null ? _withMissingBorder(colors, tile) : _withBorder(colors, tile);
  }

  Widget _tile(Reader read, DisplayOption displayOption,
      {required ArbTranslation? current, required bool isOriginal}) {
    if (current == null) {
      return MissingTranslationTile(
        locale: locale,
        onEdit: () {
          final empty = definition.map(
            placeholders: (def) => ArbTranslation.placeholders(key: def.key),
            plural: (def) => ArbTranslation.plural(key: def.key),
            select: (def) => ArbTranslation.select(key: def.key),
          );
          _edit(read, empty);
        },
      );
    }
    return definition.map(
      placeholders: (def) => PlaceholdersTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: current as ArbPlaceholdersTranslation,
        definition: def,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, current),
        onRollback: () => _rollback(read),
      ),
      plural: (def) => PluralTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: current as ArbPluralTranslation,
        definition: def,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, current),
        onRollback: () => _rollback(read),
      ),
      select: (def) => SelectTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: current as ArbSelectTranslation,
        definition: def,
        isOriginal: isOriginal,
        onEdit: () => _edit(read, current),
        onRollback: () => _rollback(read),
      ),
    );
  }

  Widget _form(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation? current,
    required ArbTranslation beingEdited,
  }) {
    return definition.map<TranslationForm>(
      placeholders: (_) => PlaceholdersTranslationForm(
        displayOption: displayOption,
        locale: locale,
        current: current,
        beingEdited: beingEdited,
        onUpdate: (value) => _updateBeingEdited(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
      plural: (_) => PluralTranslationForm(
        displayOption: displayOption,
        locale: locale,
        current: current,
        beingEdited: beingEdited,
        onUpdate: (value) => _updateBeingEdited(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
      select: (_) => SelectTranslationForm(
        displayOption: displayOption,
        locale: locale,
        current: current,
        beingEdited: beingEdited,
        onUpdate: (value) => _updateBeingEdited(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
    );
  }

  Widget _withBorder(ColorScheme colors, Widget child) => Container(
        margin: const EdgeInsets.only(top: 12.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
        child: child,
      );

  Widget _withMissingBorder(ColorScheme colors, Widget child) => Container(
        margin: const EdgeInsets.only(top: 12.0),
        child: DottedBorder(
          padding: const EdgeInsets.all(8.0),
          color: colors.error,
          child: child,
        ),
      );

  void _edit(Reader read, ArbTranslation current) {
    _updateBeingEdited(read, current);
    _rebuild(read);
  }

  void _rollback(Reader read) {
    read(arbUsecaseProvider).rollbackTranslation(locale: locale, definition: definition);
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

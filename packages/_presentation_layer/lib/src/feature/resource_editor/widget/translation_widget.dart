import 'package:_domain_layer/domain_layer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'translation_form.dart';
import 'translation_tile.dart';

class TranslationWidget extends ConsumerWidget {
  TranslationWidget(this.locale,
      {required this.originalDefinition,
      required this.currentDefinition,
      this.originalTranslation,
      super.key});

  final String locale;
  final ArbDefinition originalDefinition;
  final ArbDefinition? currentDefinition;
  final ArbTranslation? originalTranslation;
  final _rebuildProvider = StateProvider<bool>((ref) => false);

  ArbDefinition get currentOrOriginalDefinition => currentDefinition ?? originalDefinition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_rebuildProvider);

    final colors = Theme.of(context).colorScheme;
    final displayOption = ref.watch(displayOptionProvider);

    final currentTranslation = ref.watch(currentTranslationsProvider)[originalDefinition]?[locale];
    final currentOrOriginal = currentTranslation ?? originalTranslation;
    final beingEdited =
        ref.read(beingEditedTranslationsForLocaleProvider(locale))[originalDefinition];

    final tile = beingEdited != null
        ? _form(ref.read, displayOption, current: currentOrOriginal, beingEdited: beingEdited)
        : _tile(ref.read, displayOption,
            current: currentOrOriginal, isOriginal: currentTranslation == null);

    return currentOrOriginal == null ? _withMissingBorder(colors, tile) : _withBorder(colors, tile);
  }

  Widget _tile(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation? current,
    required bool isOriginal,
  }) {
    if (current == null) {
      return MissingTranslationTile(
        locale: locale,
        onEdit: () {
          final empty = originalDefinition.map(
            placeholders: (def) => ArbTranslation.placeholders(locale: locale, key: def.key),
            plural: (def) => ArbTranslation.plural(locale: locale, key: def.key),
            select: (def) => ArbTranslation.select(locale: locale, key: def.key),
          );
          _edit(read, empty);
        },
      );
    }
    return currentOrOriginalDefinition.map(
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
    return currentOrOriginalDefinition.map<TranslationForm>(
      placeholders: (def) => PlaceholdersTranslationForm(
        displayOption: displayOption,
        locale: locale,
        definition: def,
        current: current as ArbPlaceholdersTranslation,
        beingEdited: beingEdited as ArbPlaceholdersTranslation,
        onUpdate: (value) => _updateBeingEdited(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
      plural: (def) => PluralTranslationForm(
        displayOption: displayOption,
        locale: locale,
        definition: def,
        current: current as ArbPluralTranslation,
        beingEdited: beingEdited as ArbPluralTranslation,
        onUpdate: (value) => _updateBeingEdited(read, value),
        onSaveChanges: (value) => _saveChanges(read, value),
        onDiscardChanges: () => _discardChanges(read),
      ),
      select: (def) => SelectTranslationForm(
        displayOption: displayOption,
        locale: locale,
        definition: def,
        current: current as ArbSelectTranslation,
        beingEdited: beingEdited as ArbSelectTranslation,
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
    read(arbUsecaseProvider).rollbackTranslation(locale: locale, definition: originalDefinition);
  }

  void _updateBeingEdited(Reader read, ArbTranslation beingEdited) {
    read(arbUsecaseProvider).editTranslation(
      locale: locale,
      definition: originalDefinition,
      current: beingEdited,
    );
  }

  void _discardChanges(Reader read) {
    read(arbUsecaseProvider)
        .discardTranslationChanges(locale: locale, definition: originalDefinition);
    _rebuild(read);
  }

  void _saveChanges(Reader read, ArbTranslation value) {
    read(arbUsecaseProvider)
        .saveTranslation(locale: locale, definition: originalDefinition, value: value);
    _rebuild(read);
  }

  void _rebuild(Reader read) => read(_rebuildProvider.notifier).update((state) => !state);
}

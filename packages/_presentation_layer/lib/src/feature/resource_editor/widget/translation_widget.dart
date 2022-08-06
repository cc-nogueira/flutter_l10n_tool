import 'package:_domain_layer/domain_layer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'translation_form.dart';
import 'translation_tile.dart';

abstract class TranslationWidget<D extends ArbDefinition, T extends ArbTranslation>
    extends ConsumerWidget {
  TranslationWidget(this.locale,
      {required this.originalDefinition,
      required this.currentDefinition,
      this.originalTranslation,
      super.key});

  final String locale;
  final D originalDefinition;
  final D? currentDefinition;
  final T? originalTranslation;
  final _rebuildProvider = StateProvider<bool>((ref) => false);

  D get currentOrOriginalDefinition => currentDefinition ?? originalDefinition;

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
        : _tileOrMissing(ref.read, displayOption,
            current: currentOrOriginal, isOriginal: currentTranslation == null);

    return currentOrOriginal == null ? _withMissingBorder(colors, tile) : _withBorder(colors, tile);
  }

  Widget _tileOrMissing(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation? current,
    required bool isOriginal,
  }) {
    if (current == null) {
      return MissingTranslationTile(
        displayOption: displayOption,
        locale: locale,
        definition: originalDefinition,
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
    return _tile(read, displayOption, current: current, isOriginal: isOriginal);
  }

  Widget _tile(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation current,
    required bool isOriginal,
  });

  Widget _form(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation? current,
    required ArbTranslation beingEdited,
  });

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

class PlaceholdersTranslationWidget
    extends TranslationWidget<ArbPlaceholdersDefinition, ArbPlaceholdersTranslation> {
  PlaceholdersTranslationWidget(
    super.locale, {
    required super.originalDefinition,
    required super.currentDefinition,
    super.originalTranslation,
    super.key,
  });

  @override
  Widget _tile(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation current,
    required bool isOriginal,
  }) {
    return PlaceholdersTranslationTile(
      displayOption: displayOption,
      locale: locale,
      translation: current as ArbPlaceholdersTranslation,
      definition: currentOrOriginalDefinition,
      isOriginal: isOriginal,
      onEdit: () => _edit(read, current),
      onRollback: () => _rollback(read),
    );
  }

  @override
  Widget _form(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation? current,
    required ArbTranslation beingEdited,
  }) {
    return PlaceholdersTranslationForm(
      displayOption: displayOption,
      locale: locale,
      definition: currentOrOriginalDefinition,
      current: current as ArbPlaceholdersTranslation?,
      beingEdited: beingEdited as ArbPlaceholdersTranslation,
      onUpdate: (value) => _updateBeingEdited(read, value),
      onSaveChanges: (value) => _saveChanges(read, value),
      onDiscardChanges: () => _discardChanges(read),
    );
  }
}

class PluralTranslationWidget extends TranslationWidget<ArbPluralDefinition, ArbPluralTranslation> {
  PluralTranslationWidget(
    super.locale, {
    required super.originalDefinition,
    required super.currentDefinition,
    super.originalTranslation,
    super.key,
  });

  @override
  Widget _tile(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation current,
    required bool isOriginal,
  }) {
    return PluralTranslationTile(
      displayOption: displayOption,
      locale: locale,
      translation: current as ArbPluralTranslation,
      definition: currentOrOriginalDefinition,
      isOriginal: isOriginal,
      onEdit: () => _edit(read, current),
      onRollback: () => _rollback(read),
    );
  }

  @override
  Widget _form(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation? current,
    required ArbTranslation beingEdited,
  }) {
    return PluralTranslationForm(
      displayOption: displayOption,
      locale: locale,
      definition: currentOrOriginalDefinition,
      current: current as ArbPluralTranslation?,
      beingEdited: beingEdited as ArbPluralTranslation,
      onUpdate: (value) => _updateBeingEdited(read, value),
      onSaveChanges: (value) => _saveChanges(read, value),
      onDiscardChanges: () => _discardChanges(read),
    );
  }
}

class SelectTranslationWidget extends TranslationWidget<ArbSelectDefinition, ArbSelectTranslation> {
  SelectTranslationWidget(
    super.locale, {
    required super.originalDefinition,
    required super.currentDefinition,
    super.originalTranslation,
    super.key,
  });

  final knownCasesController = StateController(<String>{});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final knownCases =
        ref.read(analysisProvider).knownCasesPerSelectDefinition[originalDefinition.key] ??
            <String>{};
    knownCasesController.state = knownCases;
    return super.build(context, ref);
  }

  @override
  Widget _tile(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation current,
    required bool isOriginal,
  }) {
    return SelectTranslationTile(
      displayOption: displayOption,
      locale: locale,
      translation: current as ArbSelectTranslation,
      definition: currentOrOriginalDefinition,
      isOriginal: isOriginal,
      knownCases: knownCasesController.state,
      onEdit: () => _edit(read, current),
      onRollback: () => _rollback(read),
    );
  }

  @override
  Widget _form(
    Reader read,
    DisplayOption displayOption, {
    required ArbTranslation? current,
    required ArbTranslation beingEdited,
  }) {
    return SelectTranslationForm(
      displayOption: displayOption,
      locale: locale,
      definition: currentOrOriginalDefinition,
      current: current as ArbSelectTranslation?,
      beingEdited: beingEdited as ArbSelectTranslation,
      knownCases: knownCasesController.state,
      onUpdate: (value) => _updateBeingEdited(read, value),
      onSaveChanges: (value) => _saveChanges(read, value),
      onDiscardChanges: () => _discardChanges(read),
    );
  }
}

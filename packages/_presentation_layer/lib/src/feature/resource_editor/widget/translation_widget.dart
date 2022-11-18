import 'package:_domain_layer/domain_layer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/warning_theme_extension.dart';
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
    final warning = Theme.of(context).extension<WarningTheme>();
    final displayOption = ref.watch(displayOptionProvider);

    final currentTranslation = ref.watch(currentTranslationsProvider)[originalDefinition]?[locale];
    final currentOrOriginal = currentTranslation ?? originalTranslation;
    final beingEdited =
        ref.read(beingEditedTranslationsForLocaleProvider(locale))[originalDefinition];

    final tile = beingEdited != null
        ? _form(ref, displayOption, current: currentOrOriginal, beingEdited: beingEdited)
        : _tileOrMissing(ref, displayOption,
            current: currentOrOriginal, isOriginal: currentTranslation == null);

    return currentOrOriginal == null
        ? _withMissingBorder(colors, warning, tile)
        : _withBorder(colors, tile);
  }

  Widget _tileOrMissing(
    WidgetRef ref,
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
          _edit(ref, empty);
        },
      );
    }
    return _tile(ref, displayOption, current: current, isOriginal: isOriginal);
  }

  Widget _tile(
    WidgetRef ref,
    DisplayOption displayOption, {
    required ArbTranslation current,
    required bool isOriginal,
  });

  Widget _form(
    WidgetRef ref,
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

  Widget _withMissingBorder(ColorScheme colors, WarningTheme? warning, Widget child) => Container(
        margin: const EdgeInsets.only(top: 12.0),
        child: DottedBorder(
          padding: const EdgeInsets.all(8.0),
          color: warning?.iconColor ?? colors.error,
          child: child,
        ),
      );

  void _edit(WidgetRef ref, ArbTranslation current) {
    _updateBeingEdited(ref, current);
    _rebuild(ref);
  }

  void _rollback(WidgetRef ref) {
    ref
        .read(arbUsecaseProvider)
        .rollbackTranslation(locale: locale, definition: originalDefinition);
  }

  void _updateBeingEdited(WidgetRef ref, ArbTranslation beingEdited) {
    ref.read(arbUsecaseProvider).editTranslation(
          locale: locale,
          definition: originalDefinition,
          current: beingEdited,
        );
  }

  void _discardChanges(WidgetRef ref) {
    ref
        .read(arbUsecaseProvider)
        .discardTranslationChanges(locale: locale, definition: originalDefinition);
    _rebuild(ref);
  }

  void _saveChanges(WidgetRef ref, ArbTranslation value) {
    ref.read(arbUsecaseProvider).saveTranslation(definition: originalDefinition, value: value);
    _rebuild(ref);
  }

  void _rebuild(WidgetRef ref) => ref.read(_rebuildProvider.notifier).update((state) => !state);
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
    WidgetRef ref,
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
      onEdit: () => _edit(ref, current),
      onRollback: () => _rollback(ref),
      onSave: (value) => _saveChanges(ref, value),
    );
  }

  @override
  Widget _form(
    WidgetRef ref,
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
      onUpdate: (value) => _updateBeingEdited(ref, value),
      onSaveChanges: (value) => _saveChanges(ref, value),
      onDiscardChanges: () => _discardChanges(ref),
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
    WidgetRef ref,
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
      onEdit: () => _edit(ref, current),
      onRollback: () => _rollback(ref),
      onSave: (value) => _saveChanges(ref, value),
    );
  }

  @override
  Widget _form(
    WidgetRef ref,
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
      onUpdate: (value) => _updateBeingEdited(ref, value),
      onSaveChanges: (value) => _saveChanges(ref, value),
      onDiscardChanges: () => _discardChanges(ref),
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
    WidgetRef ref,
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
      onEdit: () => _edit(ref, current),
      onRollback: () => _rollback(ref),
      onSave: (value) => _saveChanges(ref, value),
    );
  }

  @override
  Widget _form(
    WidgetRef ref,
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
      onUpdate: (value) => _updateBeingEdited(ref, value),
      onSaveChanges: (value) => _saveChanges(ref, value),
      onDiscardChanges: () => _discardChanges(ref),
    );
  }
}

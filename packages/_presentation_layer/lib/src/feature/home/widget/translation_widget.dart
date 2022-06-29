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
  late final translationController = StateController<ArbTranslation>(
      translation ?? ArbTranslation(key: definition.key, value: ''));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final displayOption = ref.watch(displayOptionProvider);
    final beingEdited = ref.watch(beingEditedTranslationsForLanguageProvider(locale)
        .select((value) => value[_currentTranslation]));

    late final Widget child;
    if (beingEdited == null) {
      child = _tile(ref.read, displayOption);
    } else {
      _currentTranslation = beingEdited;
      child = _form(ref.read, displayOption);
    }

    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
      child: child,
    );
  }

  Widget _tile(Reader read, DisplayOption displayOption) {
    if (definition is ArbTextDefinition) {
      return TextTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: _currentTranslation,
        definition: definition as ArbTextDefinition,
        onEdit: () => _edit(read),
      );
    } else if (definition is ArbSelectDefinition) {
      return SelectTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: _currentTranslation,
        definition: definition as ArbSelectDefinition,
        onEdit: () => _edit(read),
      );
    } else if (definition is ArbPluralDefinition) {
      return PluralTranslationTile(
        displayOption: displayOption,
        locale: locale,
        translation: _currentTranslation,
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
          current: _currentTranslation,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      case ArbDefinitionType.select:
        return SelectTranslationForm(
          locale: locale,
          original: translation,
          current: _currentTranslation,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
      default:
        return TextTranslationForm(
          locale: locale,
          original: translation,
          current: _currentTranslation,
          onDiscardChanges: () => _discardChanges(read),
          onSaveChanges: () => _saveChanges(read),
        );
    }
  }

  ArbTranslation get _currentTranslation => translationController.state;

  set _currentTranslation(ArbTranslation translation) => translationController.state = translation;

  void _edit(Reader read) {
    read(arbUsecaseProvider).editTranslation(locale, definition, _currentTranslation);
  }

  void _discardChanges(Reader read) {
    final current = _currentTranslation;
    _currentTranslation = translation ?? ArbTranslation(key: definition.key, value: '');
    read(arbUsecaseProvider).discardTranslationChanges(locale, definition, current);
  }

  void _saveChanges(Reader read) {}
}

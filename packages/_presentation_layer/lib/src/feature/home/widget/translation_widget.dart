import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TranslationWidget extends StatelessWidget {
  const TranslationWidget(this.project, this.definition, this.localeTranslations, {super.key});

  final Project project;
  final ArbDefinition definition;
  final ArbLocaleTranslations localeTranslations;

  @override
  Widget build(BuildContext context) {
    switch (definition.type) {
      case ArbDefinitionType.plural:
        return _PluralTranslationWidget(project, definition, localeTranslations);
      case ArbDefinitionType.select:
        return _SelectTranslationWidget(project, definition, localeTranslations);
      default:
        return _TextTranslationWidget(project, definition, localeTranslations);
    }
  }
}

abstract class _TranslationWidget extends ConsumerStatefulWidget {
  const _TranslationWidget(this.project, this.definition, this.localeTranslations);

  final Project project;
  final ArbDefinition definition;
  final ArbLocaleTranslations localeTranslations;

  ArbTranslation? get translation => localeTranslations.translations[definition.key];
  String get locale => localeTranslations.locale;
}

class _TextTranslationWidget extends _TranslationWidget {
  const _TextTranslationWidget(super.project, super.resource, super.localeTranslations);

  @override
  ConsumerState<_TextTranslationWidget> createState() => _TextResourceTranslationState();
}

class _SelectTranslationWidget extends _TranslationWidget {
  const _SelectTranslationWidget(super.project, super.resource, super.localeTranslations);

  @override
  ConsumerState<_SelectTranslationWidget> createState() => _SelectTranslationState();
}

class _PluralTranslationWidget extends _TranslationWidget {
  const _PluralTranslationWidget(super.project, super.resource, super.localeTranslations);

  @override
  ConsumerState<_PluralTranslationWidget> createState() => _PluralTranslationState();
}

abstract class _ResourceTranslationState<T extends _TranslationWidget> extends ConsumerState<T> {
  late ArbTranslation? beingEdited;

  @override
  void initState() {
    super.initState();
    resetState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      resetState();
    }
  }

  void resetState() {
    beingEdited = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final translation = widget.translation;
    beingEdited = translation == null
        ? null
        : ref.watch(
            beingEditedTranslationsForLanguageProvider(widget.locale)
                .select((value) => value[translation]),
          );
    return tile(colors);
  }

  Widget tile(ColorScheme colors) {
    final displayTranslation = beingEdited ?? widget.translation;
    const leading = Icon(Icons.translate);
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        title: Text(widget.locale),
        subtitle: translationDetails(displayTranslation?.value),
        leading: leading,
        trailing: trailing(),
      ),
    );
  }

  Widget trailing() {
    return beingEdited == null
        ? IconButton(
            icon: const Icon(Icons.edit),
            iconSize: 20,
            onPressed: _editTranslation,
          )
        : beingEdited == widget.translation
            ? IconButton(icon: const Icon(Icons.close), onPressed: _discardChanges)
            : IconButton(icon: const Icon(Icons.check), onPressed: () {});
  }

  bool get isModified => false;

  void _editTranslation() {
    final translation = widget.translation;
    if (translation != null) {
      ref.read(arbUsecaseProvider).editTranslation(widget.locale, widget.definition, translation);
    }
  }

  void _discardChanges() {
    final translation = widget.translation;
    if (translation != null) {
      ref
          .read(arbUsecaseProvider)
          .discardTranslationChanges(widget.locale, widget.definition, translation);
    }
  }

  Widget? translationDetails(String? value);
}

class _TextResourceTranslationState extends _ResourceTranslationState<_TextTranslationWidget> {
  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class _SelectTranslationState extends _ResourceTranslationState<_SelectTranslationWidget> {
  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class _PluralTranslationState extends _ResourceTranslationState<_PluralTranslationWidget> {
  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

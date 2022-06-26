import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResourceTranslationWidget extends StatelessWidget {
  const ResourceTranslationWidget(this.project, this.resource, this.localeTranslations,
      {super.key});

  final Project project;
  final ArbResourceDefinition resource;
  final ArbLocaleTranslations localeTranslations;

  @override
  Widget build(BuildContext context) {
    switch (resource.type) {
      case ArbResourceType.plural:
        return _PluralResourceTranslationWidget(project, resource, localeTranslations);
      case ArbResourceType.select:
        return _SelectResourceTranslationWidget(project, resource, localeTranslations);
      default:
        return _TextResourceTranslationWidget(project, resource, localeTranslations);
    }
  }
}

abstract class _ResourceTranslationWidget extends ConsumerStatefulWidget {
  const _ResourceTranslationWidget(this.project, this.resource, this.localeTranslations);

  final Project project;
  final ArbResourceDefinition resource;
  final ArbLocaleTranslations localeTranslations;

  ArbResource? get translation => localeTranslations.translations[resource.key];
  String get locale => localeTranslations.locale;
}

class _TextResourceTranslationWidget extends _ResourceTranslationWidget {
  const _TextResourceTranslationWidget(super.project, super.resource, super.localeTranslations);

  @override
  ConsumerState<_TextResourceTranslationWidget> createState() => _TextResourceTranslationState();
}

class _SelectResourceTranslationWidget extends _ResourceTranslationWidget {
  const _SelectResourceTranslationWidget(super.project, super.resource, super.localeTranslations);

  @override
  ConsumerState<_SelectResourceTranslationWidget> createState() =>
      _SelectResourceTranslationState();
}

class _PluralResourceTranslationWidget extends _ResourceTranslationWidget {
  const _PluralResourceTranslationWidget(super.project, super.resource, super.localeTranslations);

  @override
  ConsumerState<_PluralResourceTranslationWidget> createState() =>
      _PluralResourceTranslationState();
}

abstract class _ResourceTranslationWidgetState<T extends _ResourceTranslationWidget>
    extends ConsumerState<T> {
  late ArbResource? beingEdited;

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
            beingEditedTranslationsProvider(widget.locale).select((value) => value[translation]));
    return tile(colors, beingEdited ?? translation);
  }

  Widget tile(ColorScheme colors, ArbResource? translation) {
    const leading = Icon(Icons.translate);
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        title: Text(widget.locale),
        subtitle: translationDetails(translation?.value),
        leading: leading,
        trailing: trailling(beingEdited),
      ),
    );
  }

  Widget trailling(ArbResource? beingEdited) {
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
      ref
          .read(resourceUsecaseProvider)
          .editTranslation(widget.locale, widget.resource, translation);
    }
  }

  void _discardChanges() {
    final translation = widget.translation;
    if (translation != null) {
      ref
          .read(resourceUsecaseProvider)
          .discardTranslationChanges(widget.locale, widget.resource, translation);
    }
  }

  Widget? translationDetails(String? value);
}

class _TextResourceTranslationState
    extends _ResourceTranslationWidgetState<_TextResourceTranslationWidget> {
  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class _SelectResourceTranslationState
    extends _ResourceTranslationWidgetState<_SelectResourceTranslationWidget> {
  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class _PluralResourceTranslationState
    extends _ResourceTranslationWidgetState<_PluralResourceTranslationWidget> {
  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

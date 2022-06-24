import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

abstract class ResourceTranslationWidget extends StatelessWidget {
  factory ResourceTranslationWidget(
    Project project,
    ArbResourceDefinition resource,
    ArbLocaleTranslations localeTranslations,
  ) {
    switch (resource.type) {
      case ArbResourceType.plural:
        return PluralResourceTranslationWidget(project, resource, localeTranslations);
      case ArbResourceType.select:
        return SelectResourceTranslationWidget(project, resource, localeTranslations);
      default:
        return TextResourceTranslationWidget(project, resource, localeTranslations);
    }
  }

  const ResourceTranslationWidget._(this.project, this.resource, this.localeTranslations);

  final Project project;
  final ArbResourceDefinition resource;
  final ArbLocaleTranslations localeTranslations;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return tile(colors);
  }

  Widget tile(ColorScheme colors) {
    const leading = Icon(Icons.translate);
    final trailling = IconButton(
      icon: const Icon(Icons.edit),
      iconSize: 20,
      onPressed: () {},
    );
    final translation = localeTranslations.translations[resource.key];
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        title: Text(localeTranslations.locale),
        subtitle: translationDetails(translation?.value),
        leading: leading,
        trailing: trailling,
      ),
    );
  }

  Widget? translationDetails(String? value);
}

class TextResourceTranslationWidget extends ResourceTranslationWidget {
  const TextResourceTranslationWidget(
    Project project,
    ArbResourceDefinition resource,
    ArbLocaleTranslations localeTranslations,
  ) : super._(project, resource, localeTranslations);

  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class SelectResourceTranslationWidget extends ResourceTranslationWidget {
  const SelectResourceTranslationWidget(
    Project project,
    ArbResourceDefinition resource,
    ArbLocaleTranslations localeTranslations,
  ) : super._(project, resource, localeTranslations);

  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class PluralResourceTranslationWidget extends ResourceTranslationWidget {
  const PluralResourceTranslationWidget(
    Project project,
    ArbResourceDefinition resource,
    ArbLocaleTranslations localeTranslations,
  ) : super._(project, resource, localeTranslations);

  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

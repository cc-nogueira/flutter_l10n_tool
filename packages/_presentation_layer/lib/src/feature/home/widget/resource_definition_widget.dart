import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

abstract class ResourceDefinitionWidget extends StatelessWidget {
  factory ResourceDefinitionWidget(ArbResourceDefinition resource) {
    switch (resource.type) {
      case ArbResourceType.plural:
        return PluralResourceDefinitionWidget(resource);
      case ArbResourceType.select:
        return SelectResourceDefinitionWidget(resource);
      default:
        return TextResourceDefinitionWidget(resource);
    }
  }

  const ResourceDefinitionWidget._(this.resource);

  final ArbResourceDefinition resource;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return keyTile(colors);
  }

  Widget keyTile(ColorScheme colors) {
    final title = SelectableText(resource.key);
    final subtitle = SelectableText(resource.description ?? '');
    const leading = Icon(Icons.key);
    return ListTile(
        title: title, subtitle: subtitle, leading: leading, tileColor: colors.primaryContainer);
  }

  Widget? translationDetails(String? value);
}

class TextResourceDefinitionWidget extends ResourceDefinitionWidget {
  const TextResourceDefinitionWidget(ArbResourceDefinition resource) : super._(resource);

  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class SelectResourceDefinitionWidget extends ResourceDefinitionWidget {
  const SelectResourceDefinitionWidget(ArbResourceDefinition resource) : super._(resource);

  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class PluralResourceDefinitionWidget extends ResourceDefinitionWidget {
  const PluralResourceDefinitionWidget(ArbResourceDefinition resource) : super._(resource);

  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

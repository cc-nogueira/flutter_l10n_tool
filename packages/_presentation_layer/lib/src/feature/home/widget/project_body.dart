import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/message_widget.dart';

class ProjectBody extends ConsumerWidget {
  const ProjectBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final project = ref.watch(projectProvider);
    final selected = ref.watch(selectedResourceProvider);
    if (project.hasError) {
      return _errorBody(context, colors, project);
    }
    if (project.isNotReady) {
      return _notReadyBody();
    }

    return _body(colors, project, selected);
  }

  Widget _body(ColorScheme colors, Project project, ArbResourceDefinition? resource) {
    return resource == null
        ? const MessageWidget('Localization App')
        : ResourceDefinitionWidget(project, resource, colors: colors);
  }

  Widget _notReadyBody() => const MessageWidget('Localization App');

  Widget _errorBody(BuildContext context, ColorScheme colors, Project project) {
    late final String message;
    if (project.l10nException != null) {
      message = 'Project configuration error: ${project.l10nException!.message(context)}';
    } else {
      message = 'Project loading error: ${project.loadError}';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: colors.errorContainer,
          padding: const EdgeInsets.all(16),
          child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
        ),
      ],
    );
  }
}

abstract class ResourceDefinitionWidget extends StatelessWidget {
  factory ResourceDefinitionWidget(
    Project project,
    ArbResourceDefinition resource, {
    required ColorScheme colors,
  }) {
    switch (resource.type) {
      case ArbResourceType.plural:
        return PluralResourceDefinitionWidget(project, resource, colors: colors);
      case ArbResourceType.select:
        return SelectResourceDefinitionWidget(project, resource, colors: colors);
      default:
        return TextResourceDefinitionWidget(project, resource, colors: colors);
    }
  }

  const ResourceDefinitionWidget._(this.project, this.resource, this.colors);

  final Project project;
  final ArbResourceDefinition resource;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        keyTile(),
        ...translations(),
      ],
    );
  }

  Widget keyTile() {
    final title = SelectableText(resource.key);
    final subtitle = SelectableText(resource.description ?? '');
    const leading = Icon(Icons.key);
    return ListTile(
        title: title, subtitle: subtitle, leading: leading, tileColor: colors.primaryContainer);
  }

  List<Widget> translations() {
    const leading = Icon(Icons.translate);
    final trailling = IconButton(
      icon: const Icon(Icons.edit),
      iconSize: 20,
      onPressed: () {},
    );
    final widgets = <Widget>[];
    for (final translationsEntry in project.translations.entries) {
      final localeTranslations = translationsEntry.value;
      final translation = localeTranslations.translations[resource.key];
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 12.0),
          decoration: BoxDecoration(border: Border.all(color: colors.onBackground)),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            title: Text(localeTranslations.locale),
            subtitle: translationDetails(translation?.value),
            leading: leading,
            trailing: trailling,
          ),
        ),
      );
    }
    return widgets;
  }

  Widget? translationDetails(String? value);
}

class TextResourceDefinitionWidget extends ResourceDefinitionWidget {
  const TextResourceDefinitionWidget(
    Project project,
    ArbResourceDefinition resource, {
    required ColorScheme colors,
  }) : super._(project, resource, colors);

  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class SelectResourceDefinitionWidget extends ResourceDefinitionWidget {
  const SelectResourceDefinitionWidget(
    Project project,
    ArbResourceDefinition resource, {
    required ColorScheme colors,
  }) : super._(project, resource, colors);

  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

class PluralResourceDefinitionWidget extends ResourceDefinitionWidget {
  const PluralResourceDefinitionWidget(
    Project project,
    ArbResourceDefinition resource, {
    required ColorScheme colors,
  }) : super._(project, resource, colors);

  @override
  Widget? translationDetails(String? value) => value == null ? null : SelectableText(value);
}

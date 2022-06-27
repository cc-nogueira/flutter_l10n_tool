import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResourceDefinitionWidget extends StatelessWidget {
  const ResourceDefinitionWidget(this.resourceDefinition, {super.key});

  final ArbResourceDefinition resourceDefinition;

  @override
  Widget build(BuildContext context) {
    switch (resourceDefinition.type) {
      case ArbResourceType.plural:
        return _PluralResourceDefinitionWidget(resourceDefinition);
      case ArbResourceType.select:
        return _SelectResourceDefinitionWidget(resourceDefinition);
      default:
        return _TextResourceDefinitionWidget(resourceDefinition);
    }
  }
}

abstract class _ResourceDefinitionWidget extends ConsumerStatefulWidget {
  const _ResourceDefinitionWidget(this.resourceDefinition);

  final ArbResourceDefinition resourceDefinition;
}

class _TextResourceDefinitionWidget extends _ResourceDefinitionWidget {
  const _TextResourceDefinitionWidget(super.resourceDefinition);

  @override
  ConsumerState<_TextResourceDefinitionWidget> createState() => _TextResourceDefinitionState();
}

class _SelectResourceDefinitionWidget extends _ResourceDefinitionWidget {
  const _SelectResourceDefinitionWidget(super.resourceDefinition);

  @override
  ConsumerState<_SelectResourceDefinitionWidget> createState() => _SelectResourceDefinitionState();
}

class _PluralResourceDefinitionWidget extends _ResourceDefinitionWidget {
  const _PluralResourceDefinitionWidget(super.resourceDefinition);

  @override
  ConsumerState<_PluralResourceDefinitionWidget> createState() => _PluralResourceDefinitionState();
}

abstract class _ResourceDefinitionState<T extends _ResourceDefinitionWidget>
    extends ConsumerState<T> {
  late ArbResourceDefinition? beingEdited;

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
    final resourceDefinition = widget.resourceDefinition;
    beingEdited = ref
        .watch(beingEditedResourceDefinitionsProvider.select((value) => value[resourceDefinition]));

    return tile(colors);
  }

  Widget tile(ColorScheme colors) {
    final displayDefinition = beingEdited ?? widget.resourceDefinition;
    final title = SelectableText(displayDefinition.key);
    final subtitle = SelectableText(displayDefinition.description ?? '');
    const leading = Icon(Icons.key);
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing(),
      tileColor: colors.primaryContainer,
    );
  }

  Widget trailing() {
    return beingEdited == null
        ? IconButton(
            icon: const Icon(Icons.edit),
            iconSize: 20,
            onPressed: _editDefinition,
          )
        : beingEdited == widget.resourceDefinition
            ? IconButton(icon: const Icon(Icons.close), onPressed: _discardChanges)
            : IconButton(icon: const Icon(Icons.check), onPressed: () {});
  }

  void _editDefinition() {
    ref.read(resourceUsecaseProvider).editResource(widget.resourceDefinition);
  }

  void _discardChanges() {
    ref.read(resourceUsecaseProvider).discardResourceDefinitionChanges(widget.resourceDefinition);
  }

  Widget? definitionDetails(String? value);
}

class _TextResourceDefinitionState extends _ResourceDefinitionState<_TextResourceDefinitionWidget> {
  @override
  Widget? definitionDetails(String? value) => value == null ? null : SelectableText(value);
}

class _SelectResourceDefinitionState
    extends _ResourceDefinitionState<_SelectResourceDefinitionWidget> {
  @override
  Widget? definitionDetails(String? value) => value == null ? null : SelectableText(value);
}

class _PluralResourceDefinitionState
    extends _ResourceDefinitionState<_PluralResourceDefinitionWidget> {
  @override
  Widget? definitionDetails(String? value) => value == null ? null : SelectableText(value);
}

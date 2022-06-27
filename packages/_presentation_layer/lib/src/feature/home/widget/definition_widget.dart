import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefinitionWidget extends StatelessWidget {
  const DefinitionWidget(this.rdefinition, {super.key});

  final ArbDefinition rdefinition;

  @override
  Widget build(BuildContext context) {
    switch (rdefinition.type) {
      case ArbDefinitionType.plural:
        return _PluralDefinitionWidget(rdefinition);
      case ArbDefinitionType.select:
        return _SelectDefinitionWidget(rdefinition);
      default:
        return _TextDefinitionWidget(rdefinition);
    }
  }
}

abstract class _DefinitionWidget extends ConsumerStatefulWidget {
  const _DefinitionWidget(this.definition);

  final ArbDefinition definition;
}

class _TextDefinitionWidget extends _DefinitionWidget {
  const _TextDefinitionWidget(super.resourceDefinition);

  @override
  ConsumerState<_TextDefinitionWidget> createState() => _TextDefinitionState();
}

class _SelectDefinitionWidget extends _DefinitionWidget {
  const _SelectDefinitionWidget(super.resourceDefinition);

  @override
  ConsumerState<_SelectDefinitionWidget> createState() => _SelectDefinitionState();
}

class _PluralDefinitionWidget extends _DefinitionWidget {
  const _PluralDefinitionWidget(super.resourceDefinition);

  @override
  ConsumerState<_PluralDefinitionWidget> createState() => _PluralDefinitionState();
}

abstract class _DefinitionState<T extends _DefinitionWidget> extends ConsumerState<T> {
  late ArbDefinition? beingEdited;

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
    final resourceDefinition = widget.definition;
    beingEdited =
        ref.watch(beingEditedDefinitionsProvider.select((value) => value[resourceDefinition]));

    return tile(colors);
  }

  Widget tile(ColorScheme colors) {
    final displayDefinition = beingEdited ?? widget.definition;
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
        : beingEdited == widget.definition
            ? IconButton(icon: const Icon(Icons.close), onPressed: _discardChanges)
            : IconButton(icon: const Icon(Icons.check), onPressed: () {});
  }

  void _editDefinition() {
    ref.read(arbUsecaseProvider).editDefinition(widget.definition);
  }

  void _discardChanges() {
    ref.read(arbUsecaseProvider).discardDefinitionChanges(widget.definition);
  }

  Widget? definitionDetails(String? value);
}

class _TextDefinitionState extends _DefinitionState<_TextDefinitionWidget> {
  @override
  Widget? definitionDetails(String? value) => value == null ? null : SelectableText(value);
}

class _SelectDefinitionState extends _DefinitionState<_SelectDefinitionWidget> {
  @override
  Widget? definitionDetails(String? value) => value == null ? null : SelectableText(value);
}

class _PluralDefinitionState extends _DefinitionState<_PluralDefinitionWidget> {
  @override
  Widget? definitionDetails(String? value) => value == null ? null : SelectableText(value);
}

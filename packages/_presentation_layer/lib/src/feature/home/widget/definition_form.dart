import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import 'definition_form_mixin.dart';
import 'definition_tile_mixin.dart';

abstract class DefinitionForm extends StatefulWidget {
  const DefinitionForm({
    super.key,
    required this.original,
    required this.current,
    required this.onDiscardChanges,
    required this.onSaveChanges,
  });

  final ArbDefinition original;
  final ArbDefinition current;
  final VoidCallback? onDiscardChanges;
  final VoidCallback? onSaveChanges;
}

class TextDefinitionForm extends DefinitionForm {
  const TextDefinitionForm({
    super.key,
    required super.original,
    required super.current,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<TextDefinitionForm> createState() => TextDefinitionFormState();
}

class PluralDefinitionForm extends DefinitionForm {
  const PluralDefinitionForm({
    super.key,
    required super.original,
    required super.current,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<PluralDefinitionForm> createState() => PluralDefinitionFormState();
}

class SelectDefinitionForm extends DefinitionForm {
  const SelectDefinitionForm({
    super.key,
    required super.original,
    required super.current,
    required super.onDiscardChanges,
    required super.onSaveChanges,
  });

  @override
  State<SelectDefinitionForm> createState() => SelectDefinitionFormState();
}

abstract class DefinitionFormState<T extends DefinitionForm> extends State<T>
    with DefinitionTileMixin, DefinitionFormMixin {
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

  void resetState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        title(theme.textTheme),
        const SizedBox(height: 4.0),
        form(theme.colorScheme),
      ],
    );
  }

  Widget title(TextTheme theme) {
    return tileTitle(
      theme,
      title: widget.current.key,
      trailing: Row(children: [
        IconButton(
            icon: const Icon(Icons.check), onPressed: hasChanges ? widget.onSaveChanges : null),
        IconButton(icon: const Icon(Icons.close), onPressed: widget.onDiscardChanges),
      ]),
    );
  }

  bool get hasChanges;

  Widget form(ColorScheme colors);
}

class TextDefinitionFormState extends DefinitionFormState<TextDefinitionForm> {
  TextEditingController translationTextController = TextEditingController();

  @override
  void dispose() {
    translationTextController.dispose();
    super.dispose();
  }

  @override
  void resetState() {
    translationTextController.text = widget.current.key;
  }

  @override
  bool get hasChanges => translationTextController.text != (widget.current.key);

  @override
  Widget form(ColorScheme colors) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.only(
          left: DefinitionTileMixin.leadingSize + DefinitionTileMixin.leadingSeparation,
          right: DefinitionTileMixin.leadingSize,
        ),
        child: textField(
          colors: colors,
          label: 'Key',
          originalText: widget.original.key,
          textController: translationTextController,
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }
}

class PluralDefinitionFormState extends DefinitionFormState<PluralDefinitionForm> {
  @override
  Widget form(ColorScheme colors) {
    return Container();
  }

  @override
  bool get hasChanges => false;

  @override
  void resetState() {}
}

class SelectDefinitionFormState extends DefinitionFormState<SelectDefinitionForm> {
  @override
  Widget form(ColorScheme colors) {
    return Container();
  }

  @override
  bool get hasChanges => false;

  @override
  void resetState() {}
}

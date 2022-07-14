import 'dart:collection';

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';
import '../../../l10n/app_localizations.dart';
import 'placeholder_buttons.dart';
import 'placeholder_form.dart';

GlobalKey newPlaceholderKey = LabeledGlobalKey('newPlaceholderKey');
GlobalKey savePlaceholderKey = LabeledGlobalKey('savePlaceholderKey');
GlobalKey stackKey = LabeledGlobalKey('stackKey');

class PlaceholdersAndForm extends StatefulWidget {
  const PlaceholdersAndForm(
    this.loc,
    this.colors, {
    super.key,
    required this.definitionController,
    required this.formPlaceholderController,
    required this.placeholderBeingEditedController,
    required this.onUpdateDefinition,
    required this.onUpdatePlaceholder,
    required this.onEditPlaceholder,
  });

  @override
  State<PlaceholdersAndForm> createState() => _PlaceholdersAndFormState();

  final AppLocalizations loc;
  final ColorScheme colors;
  final ValueChanged<ArbDefinition> onUpdateDefinition;
  final ValueChanged<ArbPlaceholder?> onUpdatePlaceholder;
  final ValueChanged<ArbPlaceholder?> onEditPlaceholder;
  final StateController<ArbTextDefinition> definitionController;
  final StateController<ArbPlaceholder?> formPlaceholderController;
  final StateController<ArbPlaceholder?> placeholderBeingEditedController;
}

class _PlaceholdersAndFormState extends State<PlaceholdersAndForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    resetState();
  }

  @override
  void didUpdateWidget(covariant PlaceholdersAndForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      resetState();
    }
  }

  void resetState() {
    if (!_controller.isAnimating) {
      if (widget.formPlaceholderController.state == null) {
        _controller.value = 0;
      } else {
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedPlaceholdersAndForm(
      widget.loc,
      widget.colors,
      animation: _controller.view,
      newPlaceholderCallback: _onNewPlaceholder,
      editPlaceholderCallback: _onEditPlaceholder,
      discardChangesCallback: _onDiscardChanges,
      updateCallback: _onUpdate,
      saveChangesCallback: _onSaveChanges,
      deleteCallback: _onDelete,
      definitionController: widget.definitionController,
      formPlaceholderController: widget.formPlaceholderController,
      placeholderBeingEditedController: widget.placeholderBeingEditedController,
    );
  }

  void _onNewPlaceholder() {
    final placeholder = ArbPlaceholder.generic();
    widget.formPlaceholderController.state = placeholder;
    widget.onUpdatePlaceholder(placeholder);
    _controller.forward(from: 0.0);
  }

  void _onEditPlaceholder(ArbPlaceholder placeholder) {
    widget.formPlaceholderController.state = placeholder;
    widget.placeholderBeingEditedController.state = placeholder;
    widget.onUpdatePlaceholder(placeholder);
    widget.onEditPlaceholder(placeholder);
    _controller.forward(from: 0.0);
  }

  void _onDiscardChanges() {
    _controller.reverse(from: 1.0).then((_) {
      widget.formPlaceholderController.state = null;
      widget.placeholderBeingEditedController.state = null;
      widget.onUpdatePlaceholder(null);
    });
  }

  void _onUpdate(ArbPlaceholder? placeholder) {
    widget.formPlaceholderController.state = placeholder;
    widget.onUpdatePlaceholder(placeholder);
  }

  void _onSaveChanges(ArbPlaceholder placeholder) async {
    final beingEdited = widget.placeholderBeingEditedController.state;
    if (beingEdited == null) {
      await _onSaveNewPlaceholder(placeholder);
    } else {
      await _onSaveEditionOfPlaceholder(placeholder, beingEdited: beingEdited);
    }
    widget.onUpdateDefinition(widget.definitionController.state);
    _onDiscardChanges();
  }

  Future<void> _onSaveNewPlaceholder(ArbPlaceholder placeholder) async {
    final placeholders = List<ArbPlaceholder>.from(widget.definitionController.state.placeholders);
    final foundIndex = placeholders.indexWhere((element) => element.key == placeholder.key);
    if (foundIndex != -1) {
      final replace = await _confirmReplaceDialog();
      if (replace != true) {
        return;
      }
      placeholders[foundIndex] = placeholder;
    } else {
      placeholders.add(placeholder);
      placeholders.sort((a, b) => a.key.compareTo(b.key));
    }
    widget.definitionController.update(
      (state) => state.copyWith(placeholders: UnmodifiableListView(placeholders)),
    );
  }

  Future<void> _onSaveEditionOfPlaceholder(
    ArbPlaceholder placeholder, {
    required ArbPlaceholder beingEdited,
  }) async {
    final placeholders = List<ArbPlaceholder>.from(widget.definitionController.state.placeholders);
    final foundIndex = placeholders.indexWhere((element) => element.key == beingEdited.key);
    if (foundIndex == -1) {
      return;
    }
    if (placeholder.key == beingEdited.key) {
      placeholders[foundIndex] = placeholder;
    } else {
      String? action;
      action = await _confirmUpdateOrAddDialog();
      if (action == "update") {
        placeholders[foundIndex] = placeholder;
      } else if (action == "add") {
        placeholders.add(placeholder);
      } else {
        return;
      }
      placeholders.sort((a, b) => a.key.compareTo(b.key));
    }
    widget.definitionController.update(
      (state) => state.copyWith(placeholders: UnmodifiableListView(placeholders)),
    );
  }

  Future<bool?> _confirmReplaceDialog() {
    return showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Please confirm'),
            content: const Text('There already exists a placeholder with this name. Replace it?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Replace'),
              )
            ],
          );
        });
  }

  Future<String?> _confirmUpdateOrAddDialog() {
    return showDialog<String>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Please confirm'),
            content: const Text('Placeholder name changed. Update placeholder or add a new one?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop("update"),
                child: const Text('Update'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop("add"),
                child: const Text('Add'),
              )
            ],
          );
        });
  }

  void _onDelete(ArbPlaceholder placeholder) {
    final placeholders = [
      for (final each in widget.definitionController.state.placeholders)
        if (each.key != placeholder.key) each
    ];
    setState(() {
      widget.definitionController.update(
        (state) => state.copyWith(placeholders: UnmodifiableListView(placeholders)),
      );
      widget.onUpdateDefinition(widget.definitionController.state);
    });
  }
}

class _AnimatedPlaceholdersAndForm extends AnimatedWidget {
  _AnimatedPlaceholdersAndForm(
    this.loc,
    this.colors, {
    required Animation<double> animation,
    required this.newPlaceholderCallback,
    required this.editPlaceholderCallback,
    required this.discardChangesCallback,
    required this.saveChangesCallback,
    required this.definitionController,
    required this.formPlaceholderController,
    required this.placeholderBeingEditedController,
    required this.updateCallback,
    required this.deleteCallback,
  }) : super(listenable: animation);

  final AppLocalizations loc;
  final ColorScheme colors;
  final VoidCallback newPlaceholderCallback;
  final VoidCallback discardChangesCallback;
  final ValueChanged<ArbPlaceholder> editPlaceholderCallback;
  final ValueChanged<ArbPlaceholder?> updateCallback;
  final ValueChanged<ArbPlaceholder> saveChangesCallback;
  final ValueChanged<ArbPlaceholder> deleteCallback;
  final StateController<ArbTextDefinition> definitionController;
  final StateController<ArbPlaceholder?> formPlaceholderController;
  final StateController<ArbPlaceholder?> placeholderBeingEditedController;
  final StateController<Offset> startTargetOffset = StateController(Offset.zero);
  final StateController<Offset> finalTargetOffset = StateController(Offset.zero);
  final StateController<RenderBox?> startTargetRenderBox = StateController(null);
  final StateController<RenderBox?> finalTargetRenderBox = StateController(null);
  Animation<double> get animation => listenable as Animation<double>;

  bool get isInitial => animation.value == 0.0;
  bool get isAnimating => animation.value > 0.0 && animation.value < 1.0;
  bool get isFinal => animation.value == 1.0;

  bool get isEdition => placeholderBeingEditedController.state != null;

  @override
  Widget build(BuildContext context) {
    if (isInitial || isFinal) {
      startTargetRenderBox.state = null;
    }
    return Stack(
      key: stackKey,
      children: [
        _placeholders(),
        _transitioningButton(),
      ],
    );
  }

  Widget _transitioningButton() {
    if (isAnimating && startTargetRenderBox.state == null) {
      _readPositions();
    }
    if (!isAnimating || startTargetRenderBox.state == null) {
      return Container();
    }

    final startSize = startTargetRenderBox.state!.size;
    final finalSize = finalTargetRenderBox.state!.size;
    final sizeDiff = (finalSize - startSize) as Offset;
    final startOffset = startTargetOffset.state;
    final finalOffset = finalTargetOffset.state;
    final dist = finalOffset - startOffset;

    return Positioned(
        top: startOffset.dy + animation.value * dist.dy,
        left: startOffset.dx + animation.value * dist.dx,
        child: SizedBox(
          width: startSize.width + animation.value * sizeDiff.dx,
          height: startSize.height + animation.value * sizeDiff.dy,
          child: _flightWidget(),
        ));
  }

  Widget _flightWidget() {
    return animation.value < 0.8
        ? NewPlaceholderButton(loc: loc, colors: colors)
        : SavePlaceholderButton(loc: loc, colors: colors);
  }

  void _readPositions() {
    final startTarget = newPlaceholderKey.currentContext?.findRenderObject();
    final finalTarget = savePlaceholderKey.currentContext?.findRenderObject();
    final stackWidget = stackKey.currentContext?.findRenderObject();
    if (startTarget is RenderBox && finalTarget is RenderBox && stackWidget != null) {
      startTargetRenderBox.state = startTarget;
      finalTargetRenderBox.state = finalTarget;
      startTargetOffset.state = startTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
      finalTargetOffset.state = finalTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
    }
  }

  Widget _placeholders() {
    final formPlaceholder = formPlaceholderController.state;
    final arbDefinition = definitionController.state;
    final beingEdited = placeholderBeingEditedController.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Placeholders: ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          child: Wrap(
            spacing: 8.0,
            children: [
              for (final each in arbDefinition.placeholders)
                _placeholderTag(colors, each, beingEdited: beingEdited),
              NewPlaceholderButton(
                key: newPlaceholderKey,
                loc: loc,
                colors: colors,
                onPressed: newPlaceholderCallback,
                hide: !isInitial,
              ),
            ],
          ),
        ),
        if (!isInitial && formPlaceholder != null)
          SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: animation,
            child: Opacity(
              opacity: animation.value,
              child: PlaceholderForm(
                original: beingEdited,
                formPlaceholder: formPlaceholder,
                onUpdate: updateCallback,
                onSave: saveChangesCallback,
                onDiscard: discardChangesCallback,
                showSaveButton: isFinal || isEdition,
                showPlaceholder: isFinal || !isEdition,
                saveButtonKey: savePlaceholderKey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholderTag(
    ColorScheme colors,
    ArbPlaceholder placeholder, {
    required ArbPlaceholder? beingEdited,
  }) {
    return inputChip(
      colors: colors,
      text: placeholder.key,
      selected: placeholder.key == beingEdited?.key,
      onPressed: () => editPlaceholderCallback(placeholder),
      onDelete: () => deleteCallback(placeholder),
    );
  }
}

import 'dart:collection';

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/arb_chip.dart';
import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_button.dart';
import '../../../l10n/app_localizations.dart';
import 'definition_placeholder_form.dart';

/// Show existing placeholders, actions and a dynamic form for placeholder edition.
///
/// Interacts with [ArbUsecase] to update the placeholder under use interaction and to track the
/// existing placeholder being edited (or none) for an ArbDefinition.
class DefinitionPlaceholdersAndForm extends ConsumerWidget {
  /// Const constructor.
  const DefinitionPlaceholdersAndForm({
    super.key,
    required this.originalDefinition,
    required this.definitionController,
    required this.onUpdateDefinition,
  });

  /// Original definition is used as Key to placeholders providers.
  final ArbDefinition originalDefinition;

  final StateController<ArbPlaceholdersDefinition> definitionController;
  final ValueChanged<ArbDefinition> onUpdateDefinition;

  /// Build method read placeholders providers (without watching them) and renders
  /// the internal [_DefinitionPlaceholdersAndForm] widget.
  ///
  /// Also register callbacks to interact with [ArbUsecase].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final formPlaceholder = ref.read(formPlaceholdersProvider)[originalDefinition];
    final existingPlaceholderBeingEdited =
        ref.read(existingPlaceholdersBeingEditedProvider)[originalDefinition];
    return _DefinitionPlaceholdersAndForm(
      loc,
      colors,
      definitionController: definitionController,
      formPlaceholder: formPlaceholder,
      existingPlaceholderBeingEdited: existingPlaceholderBeingEdited,
      onUpdateDefinition: onUpdateDefinition,
      onUpdatePlaceholder: (value) => _updateFormPlaceholder(ref, value),
      onEditPlaceholder: (value) => _editPlaceholder(ref, value),
    );
  }

  /// Internal - update the placeholder under user edition through its usecase.
  void _updateFormPlaceholder(WidgetRef ref, ArbPlaceholder? formPlaceholder) {
    ref
        .read(arbUsecaseProvider)
        .updateFormPlaceholder(definition: originalDefinition, placeholder: formPlaceholder);
  }

  /// Internal - track the placeholder being edited (or none) through its usecase.
  void _editPlaceholder(WidgetRef ref, ArbPlaceholder? placeholder) {
    ref.read(arbUsecaseProvider).trackExistingPlaceholderBeingEdited(
        definition: originalDefinition, placeholder: placeholder);
  }
}

class _DefinitionPlaceholdersAndForm extends StatefulWidget {
  /// Const constructor.
  _DefinitionPlaceholdersAndForm(
    this.loc,
    this.colors, {
    required this.definitionController,
    required ArbPlaceholder? formPlaceholder,
    required ArbPlaceholder? existingPlaceholderBeingEdited,
    required this.onUpdateDefinition,
    required this.onUpdatePlaceholder,
    required this.onEditPlaceholder,
  })  : formPlaceholderController = StateController(formPlaceholder),
        existingPlaceholderBeingEditedController = StateController(existingPlaceholderBeingEdited);

  @override
  State<_DefinitionPlaceholdersAndForm> createState() => _DefinitionPlaceholdersAndFormState();

  /// AppLocalizations is "cached" here because it is used many times by the state object.
  final AppLocalizations loc;

  /// The color schem is "cached" here because it is used many times by the state object.
  final ColorScheme colors;

  final StateController<ArbPlaceholdersDefinition> definitionController;
  final StateController<ArbPlaceholder?> formPlaceholderController;
  final StateController<ArbPlaceholder?> existingPlaceholderBeingEditedController;
  final ValueChanged<ArbDefinition> onUpdateDefinition;
  final ValueChanged<ArbPlaceholder?> onUpdatePlaceholder;
  final ValueChanged<ArbPlaceholder?> onEditPlaceholder;

  bool get formPlaceholderHasChanges {
    final formPlaceholder = formPlaceholderController.state;
    if (formPlaceholder == null) {
      return false;
    }
    final beingEdited = existingPlaceholderBeingEditedController.state ?? ArbPlaceholder.generic();
    return formPlaceholder != beingEdited;
  }
}

class _DefinitionPlaceholdersAndFormState extends State<_DefinitionPlaceholdersAndForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const kFlightAnimationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kFlightAnimationDuration);
    resetState();
  }

  @override
  void didUpdateWidget(covariant _DefinitionPlaceholdersAndForm oldWidget) {
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
      addCallback: _onAdd,
      replaceCallback: _onReplace,
      deleteCallback: _onDelete,
      definitionController: widget.definitionController,
      formPlaceholderController: widget.formPlaceholderController,
      existingPlaceholderBeingEditedController: widget.existingPlaceholderBeingEditedController,
    );
  }

  void _onNewPlaceholder() {
    final placeholder = ArbPlaceholder.generic();
    widget.formPlaceholderController.state = placeholder;
    widget.onUpdatePlaceholder(placeholder);
    _controller.forward(from: 0.0);
  }

  void _onEditPlaceholder(ArbPlaceholder placeholder) {
    if (widget.formPlaceholderHasChanges) {
      _alertPendingChanges();
      return;
    }
    widget.formPlaceholderController.state = placeholder;
    widget.existingPlaceholderBeingEditedController.state = placeholder;
    widget.onUpdatePlaceholder(placeholder);
    widget.onEditPlaceholder(placeholder);
    _controller.forward(from: 0.0);
  }

  void _onDiscardChanges() {
    _controller.reverse(from: 1.0).then((_) {
      widget.formPlaceholderController.state = null;
      widget.existingPlaceholderBeingEditedController.state = null;
      widget.onEditPlaceholder(null);
      widget.onUpdatePlaceholder(null);
    });
  }

  void _onUpdate(ArbPlaceholder? placeholder) {
    widget.formPlaceholderController.state = placeholder;
    widget.onUpdatePlaceholder(placeholder);
  }

  Future<void> _onAdd(ArbPlaceholder placeholder) async {
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
    _updateDefintionPlaceholders(placeholders);
  }

  Future<void> _onReplace(ArbPlaceholder placeholder) async {
    final beingEdited = widget.existingPlaceholderBeingEditedController.state!;
    final placeholders = List<ArbPlaceholder>.from(widget.definitionController.state.placeholders);
    final foundIndex = placeholders.indexWhere((element) => element.key == beingEdited.key);
    if (foundIndex == -1) {
      return;
    }
    if (placeholder.key == beingEdited.key) {
      placeholders[foundIndex] = placeholder;
    } else {
      final repeatedIndex = placeholders.indexWhere((element) => element.key == placeholder.key);
      if (repeatedIndex != -1) {
        final replace = await _confirmReplaceDialog();
        if (replace != true) {
          return;
        }
        placeholders.removeAt(repeatedIndex);
      }
      placeholders[foundIndex] = placeholder;
      placeholders.sort((a, b) => a.key.compareTo(b.key));
    }
    _updateDefintionPlaceholders(placeholders);
  }

  void _onDelete(ArbPlaceholder placeholder) {
    final placeholders = [
      for (final each in widget.definitionController.state.placeholders)
        if (each.key != placeholder.key) each
    ];
    setState(() => _updateDefintionPlaceholders(placeholders));
  }

  void _updateDefintionPlaceholders(List<ArbPlaceholder> placeholders) {
    widget.definitionController.update(
      (state) => state.copyWith(placeholders: UnmodifiableListView(placeholders)),
    );
    widget.onUpdateDefinition(widget.definitionController.state);
    _onDiscardChanges();
  }

  Future<void> _alertPendingChanges() {
    return showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Please save or discard changes'),
            content: const Text(
              'There are pending changes in the placeholder being edited.\n'
              'Please save or discard changes before editing another placeholder.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        });
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
}

class _AnimatedPlaceholdersAndForm extends AnimatedWidget {
  _AnimatedPlaceholdersAndForm(
    this.loc,
    this.colors, {
    required Animation<double> animation,
    required this.newPlaceholderCallback,
    required this.editPlaceholderCallback,
    required this.discardChangesCallback,
    required this.addCallback,
    required this.replaceCallback,
    required this.definitionController,
    required this.formPlaceholderController,
    required this.existingPlaceholderBeingEditedController,
    required this.updateCallback,
    required this.deleteCallback,
  }) : super(listenable: animation);

  final AppLocalizations loc;
  final ColorScheme colors;
  final VoidCallback newPlaceholderCallback;
  final VoidCallback discardChangesCallback;
  final ValueChanged<ArbPlaceholder> editPlaceholderCallback;
  final ValueChanged<ArbPlaceholder?> updateCallback;
  final ValueChanged<ArbPlaceholder> addCallback;
  final ValueChanged<ArbPlaceholder> replaceCallback;
  final ValueChanged<ArbPlaceholder> deleteCallback;
  final StateController<ArbPlaceholdersDefinition> definitionController;
  final StateController<ArbPlaceholder?> formPlaceholderController;
  final StateController<ArbPlaceholder?> existingPlaceholderBeingEditedController;
  final StateController<Offset> startTargetOffset = StateController(Offset.zero);
  final StateController<Offset> finalTargetOffset = StateController(Offset.zero);
  final StateController<RenderBox?> startTargetRenderBox = StateController(null);
  final StateController<RenderBox?> finalTargetRenderBox = StateController(null);

  final _stackKey = LabeledGlobalKey('stackKey');
  final _newPlaceholderKey = LabeledGlobalKey('newPlaceholderKey');
  final _savePlaceholderKey = LabeledGlobalKey('savePlaceholderKey');
  final _selectedPlaceholderKey = LabeledGlobalKey('selectedPlaceholderKey');
  final _placeholderInputKey = LabeledGlobalKey('placeholderInputKey');

  Animation<double> get animation => listenable as Animation<double>;

  bool get isInitial => animation.value == 0.0;
  bool get isAnimating => animation.value > 0.0 && animation.value < 1.0;
  bool get isFinal => animation.value == 1.0;

  bool get isEdition => existingPlaceholderBeingEditedController.state != null;

  @override
  Widget build(BuildContext context) {
    if (isInitial || isFinal) {
      startTargetRenderBox.state = null;
    }
    return Stack(
      key: _stackKey,
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
    if (isEdition) {
      return textInputChip(
          colors: colors,
          text: existingPlaceholderBeingEditedController.state!.key,
          align: Alignment.centerLeft,
          onPressed: () {});
    }
    final showNewButton = animation.status == AnimationStatus.reverse && animation.value < 0.8 ||
        animation.value < 0.3;
    return showNewButton
        ? FormButton(text: loc.label_new, colors: colors, onPressed: () {})
        : FormButton(text: loc.label_add_placeholder, colors: colors, onPressed: null);
  }

  void _readPositions() {
    final startTarget = isEdition
        ? _selectedPlaceholderKey.currentContext?.findRenderObject()
        : _newPlaceholderKey.currentContext?.findRenderObject();
    final finalTarget = isEdition
        ? _placeholderInputKey.currentContext?.findRenderObject()
        : _savePlaceholderKey.currentContext?.findRenderObject();
    final stackWidget = _stackKey.currentContext?.findRenderObject();
    if (startTarget is RenderBox && finalTarget is RenderBox && stackWidget != null) {
      startTargetRenderBox.state = startTarget;
      finalTargetRenderBox.state = finalTarget;
      startTargetOffset.state = startTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
      finalTargetOffset.state = finalTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
    }
  }

  Widget _placeholders() {
    final arbDefinition = definitionController.state;
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
                _placeholderTag(each, beingEdited: existingPlaceholderBeingEditedController.state),
              FormButton(
                key: _newPlaceholderKey,
                colors: colors,
                tonal: true,
                text: loc.label_new,
                onPressed: newPlaceholderCallback,
                hide: !isInitial && !isEdition,
                opacity: 1.0 - animation.value,
              ),
            ],
          ),
        ),
        if (!isInitial && formPlaceholderController.state != null)
          SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: animation,
            child: Opacity(
              opacity: animation.value,
              child: DefinitionPlaceholderForm(
                original: existingPlaceholderBeingEditedController.state,
                formPlaceholder: formPlaceholderController.state!,
                onUpdate: updateCallback,
                addCallback: addCallback,
                replaceCallback: replaceCallback,
                onDiscard: discardChangesCallback,
                showPlaceholderInput: isFinal || !isEdition,
                showAddButton: isFinal || isEdition,
                placeholderInputKey: _placeholderInputKey,
                addButtonKey: _savePlaceholderKey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholderTag(ArbPlaceholder placeholder, {required ArbPlaceholder? beingEdited}) {
    final selected = placeholder.key == beingEdited?.key;
    return ArbPlaceholderChip(placeholder,
        key: selected ? _selectedPlaceholderKey : null,
        selected: selected,
        onPressed: editPlaceholderCallback,
        onDelete: deleteCallback);
  }
}

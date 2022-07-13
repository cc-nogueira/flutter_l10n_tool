import 'dart:collection';

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_mixin.dart';
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
    required this.placeholderController,
    required this.onUpdatePlaceholder,
  });

  @override
  State<PlaceholdersAndForm> createState() => _PlaceholdersAndFormState();

  final AppLocalizations loc;
  final ColorScheme colors;
  final ValueChanged<ArbPlaceholder?> onUpdatePlaceholder;
  final StateController<ArbTextDefinition> definitionController;
  final StateController<ArbPlaceholder?> placeholderController;
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
    if (widget.placeholderController.state == null) {
      _controller.value = 0;
    } else {
      _controller.value = 1.0;
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
      discardChangesCallback: _onDiscardChanges,
      saveChangesCallback: _onSaveChanges,
      definitionController: widget.definitionController,
      placeholderController: widget.placeholderController,
      onUpdatePlaceholder: widget.onUpdatePlaceholder,
    );
  }

  void _onNewPlaceholder() {
    widget.placeholderController.state = ArbPlaceholder.generic();
    _controller.forward(from: 0.0);
  }

  void _onDiscardChanges() {
    _controller.reverse(from: 1.0).then((_) {
      widget.placeholderController.state = null;
      widget.onUpdatePlaceholder(null);
    });
  }

  void _onSaveChanges(ArbPlaceholder placeholder) {
    final placeholders = List<ArbPlaceholder>.from(widget.definitionController.state.placeholders);
    placeholders.add(placeholder);
    placeholders.sort((a, b) => a.key.compareTo(b.key));
    widget.definitionController.update(
        (definition) => definition.copyWith(placeholders: UnmodifiableListView(placeholders)));
    _onDiscardChanges();
  }
}

class _AnimatedPlaceholdersAndForm extends AnimatedWidget {
  _AnimatedPlaceholdersAndForm(
    this.loc,
    this.colors, {
    required Animation<double> animation,
    required this.newPlaceholderCallback,
    required this.discardChangesCallback,
    required this.saveChangesCallback,
    required this.definitionController,
    required this.placeholderController,
    required this.onUpdatePlaceholder,
  }) : super(listenable: animation);

  final AppLocalizations loc;
  final ColorScheme colors;
  final VoidCallback newPlaceholderCallback;
  final VoidCallback discardChangesCallback;
  final ValueChanged<ArbPlaceholder> saveChangesCallback;
  final ValueChanged<ArbPlaceholder?> onUpdatePlaceholder;
  final StateController<ArbTextDefinition> definitionController;
  final StateController<ArbPlaceholder?> placeholderController;
  final StateController<Offset> startTargetOffset = StateController(Offset.zero);
  final StateController<Offset> finalTargetOffset = StateController(Offset.zero);
  final StateController<RenderBox?> startTargetRenderBox = StateController(null);
  final StateController<RenderBox?> finalTargetRenderBox = StateController(null);
  Animation<double> get animation => listenable as Animation<double>;

  bool get isInitial => animation.value == 0.0;
  bool get isAnimating => animation.value > 0.0 && animation.value < 1.0;
  bool get isFinal => animation.value == 1.0;

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
    final placeholder = placeholderController.state;
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
              _placeholderTag(colors, ArbPlaceholder.generic(key: 'label')),
              _placeholderTag(colors, ArbPlaceholder.generic(key: 'name')),
              for (final each in arbDefinition.placeholders) _placeholderTag(colors, each),
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
        if (!isInitial && placeholder != null)
          SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: animation,
            child: Opacity(
              opacity: animation.value,
              child: PlaceholderForm(
                placeholder: placeholder,
                onUpdate: onUpdatePlaceholder,
                onSave: saveChangesCallback,
                onDiscard: discardChangesCallback,
                showSaveButton: isFinal,
                saveButtonKey: savePlaceholderKey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholderTag(ColorScheme colors, ArbPlaceholder placeholder) {
    return inputChip(
      colors: colors,
      text: placeholder.key,
      selected: false,
      onPressed: () {},
      onDelete: () {},
    );
  }
}

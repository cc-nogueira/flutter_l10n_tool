import 'dart:collection';

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/arb_chip.dart';
import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_button.dart';
import '../../../l10n/app_localizations.dart';
import '../builder/arb_builder.dart';
import 'translation_plural_form.dart';

/// Show existing plurals, actions and a dynamic form for plurals edition.
///
/// Interacts with [ArbUsecase] to update these plurals under use interaction and to track the
/// existing plurals being edited (or none) for an [ArbPluralTranslation].
class TranslationPluralsAndForm extends ConsumerWidget {
  /// Const constructor.
  const TranslationPluralsAndForm({
    super.key,
    required this.translationBuilder,
    required this.definition,
    required this.locale,
    required this.translationController,
    required this.onUpdateTranslation,
  });

  final ArbPluralTranslationBuilder translationBuilder;

  /// Original definition is used as Key to translations providers.
  final ArbPluralDefinition definition;

  final String locale;
  final StateController<ArbPluralTranslation> translationController;
  final ValueChanged<ArbTranslation> onUpdateTranslation;

  /// Build method read plural providers (without watching them) and renders
  /// the internal [_TranslationPluralsAndForm] widget.
  ///
  /// Also register callbacks to interact with [ArbUsecase].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final formPlural = ref.read(formPluralsProvider)[definition]?[locale];
    final existingPluralBeingEdited =
        ref.read(existingPluralsBeingEditedProvider)[definition]?[locale];
    return _TranslationPluralsAndForm(
      loc,
      colors,
      definition: definition,
      translationBuilder: translationBuilder,
      translationController: translationController,
      formPlural: formPlural,
      existingPluralBeingEdited: existingPluralBeingEdited,
      onUpdateTranslation: onUpdateTranslation,
      onUpdatePlural: (value) => _updateFormPlural(ref.read, locale, value),
      onEditPlural: (value) => _editPlural(ref.read, locale, value),
    );
  }

  /// Internal - update the plural under user edition through its usecase.
  void _updateFormPlural(Reader read, String locale, ArbPlural? formPlural) {
    read(arbUsecaseProvider)
        .updateFormPlural(definition: definition, locale: locale, plural: formPlural);
  }

  /// Internal - track the plural being edited (or none) through its usecase.
  void _editPlural(Reader read, String locale, ArbPlural? plural) {
    read(arbUsecaseProvider)
        .trackExistingPluralBeingEdited(definition: definition, locale: locale, plural: plural);
  }
}

class _TranslationPluralsAndForm extends StatefulWidget {
  /// Const constructor.
  _TranslationPluralsAndForm(
    this.loc,
    this.colors, {
    required this.definition,
    required this.translationBuilder,
    required this.translationController,
    required ArbPlural? formPlural,
    required ArbPlural? existingPluralBeingEdited,
    required this.onUpdateTranslation,
    required this.onUpdatePlural,
    required this.onEditPlural,
  })  : formPluralController = StateController(formPlural),
        availablePluralOptionsController = StateController([]),
        existingPluralBeingEditedController = StateController(existingPluralBeingEdited);

  @override
  State<_TranslationPluralsAndForm> createState() => _TranslationPluralsAndFormState();

  /// AppLocalizations is "cached" here because it is used many times by the state object.
  final AppLocalizations loc;

  /// The color schem is "cached" here because it is used many times by the state object.
  final ColorScheme colors;

  final ArbPluralDefinition definition;
  final ArbPluralTranslationBuilder translationBuilder;
  final StateController<ArbPluralTranslation> translationController;
  final StateController<ArbPlural?> formPluralController;
  final StateController<List<ArbPluralOption>> availablePluralOptionsController;
  final StateController<ArbPlural?> existingPluralBeingEditedController;
  final ValueChanged<ArbTranslation> onUpdateTranslation;
  final ValueChanged<ArbPlural?> onUpdatePlural;
  final ValueChanged<ArbPlural?> onEditPlural;

  bool get formPluralHasChanges {
    final formPlural = formPluralController.state;
    if (formPlural == null) {
      return false;
    }
    final beingEdited = existingPluralBeingEditedController.state ?? '';
    return formPlural != beingEdited;
  }
}

class _TranslationPluralsAndFormState extends State<_TranslationPluralsAndForm>
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
  void didUpdateWidget(covariant _TranslationPluralsAndForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      resetState();
    }
  }

  void resetState() {
    if (!_controller.isAnimating) {
      if (widget.formPluralController.state == null) {
        _controller.value = 0;
      } else {
        _controller.value = 1.0;
      }
    }
    widget.availablePluralOptionsController.state = _availableOptions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedPluralsAndForm(
      widget.loc,
      widget.colors,
      animation: _controller.view,
      translationBuilder: widget.translationBuilder,
      definition: widget.definition,
      newPluralCallback: _onNewPlural,
      editPluralCallback: _onEditPlural,
      discardChangesCallback: _onDiscardChanges,
      updateCallback: _onUpdate,
      addCallback: _onAdd,
      replaceCallback: _onReplace,
      deleteCallback: _onDelete,
      translationController: widget.translationController,
      formPluralController: widget.formPluralController,
      availablePluralOptionsController: widget.availablePluralOptionsController,
      existingPluralBeingEditedController: widget.existingPluralBeingEditedController,
    );
  }

  List<ArbPluralOption> _availableOptions() {
    final existingOptions = [
      for (final option in widget.translationController.state.options) option.option
    ];
    return [
      for (final option in ArbPluralOption.values)
        if (!existingOptions.contains(option)) option,
    ];
  }

  void _onNewPlural() {
    final availableOptions = _availableOptions();
    if (availableOptions.isEmpty) {
      return;
    }
    final plural = ArbPlural(option: availableOptions.first);
    widget.formPluralController.state = plural;
    widget.availablePluralOptionsController.state = availableOptions;
    widget.onUpdatePlural(plural);
    _controller.forward(from: 0.0);
  }

  void _onEditPlural(ArbPlural plural) {
    if (widget.formPluralHasChanges) {
      _alertPendingChanges();
      return;
    }
    final availableOptions = _availableOptions();
    availableOptions.add(plural.option);
    availableOptions.sort((a, b) => a.index.compareTo(b.index));
    widget.availablePluralOptionsController.state = availableOptions;
    widget.formPluralController.state = plural;
    widget.existingPluralBeingEditedController.state = plural;
    widget.onUpdatePlural(plural);
    widget.onEditPlural(plural);
    _controller.forward(from: 0.0);
  }

  void _onDiscardChanges() {
    _controller.reverse(from: 1.0).then((_) {
      widget.formPluralController.state = null;
      widget.availablePluralOptionsController.state = _availableOptions();
      widget.existingPluralBeingEditedController.state = null;
      widget.onEditPlural(null);
      widget.onUpdatePlural(null);
    });
  }

  void _onUpdate(ArbPlural? plural) {
    widget.formPluralController.state = plural;
    widget.onUpdatePlural(plural);
  }

  Future<void> _onAdd(ArbPlural plural) async {
    final plurals = List<ArbPlural>.from(widget.translationController.state.options);
    final foundIndex = plurals.indexWhere((element) => element.option == plural.option);
    if (foundIndex != -1) {
      final replace = await _confirmReplaceDialog();
      if (replace != true) {
        return;
      }
      plurals[foundIndex] = plural;
    } else {
      plurals.add(plural);
      plurals.sort((a, b) => a.option.index.compareTo(b.option.index));
    }
    _updateTranslationPlurals(plurals);
  }

  Future<void> _onReplace(ArbPlural plural) async {
    final beingEdited = widget.existingPluralBeingEditedController.state!;
    final plurals = List<ArbPlural>.from(widget.translationController.state.options);
    final foundIndex = plurals.indexWhere((element) => element.option == beingEdited.option);
    if (foundIndex == -1) {
      return;
    }
    if (plural.option == beingEdited.option) {
      plurals[foundIndex] = plural;
    } else {
      final repeatedIndex = plurals.indexWhere((element) => element.option == plural.option);
      if (repeatedIndex != -1) {
        final replace = await _confirmReplaceDialog();
        if (replace != true) {
          return;
        }
        plurals.removeAt(repeatedIndex);
      }
      plurals[foundIndex] = plural;
      plurals.sort((a, b) => a.option.index.compareTo(b.option.index));
    }
    _updateTranslationPlurals(plurals);
  }

  void _onDelete(ArbPlural plural) {
    final plurals = [
      for (final each in widget.translationController.state.options)
        if (each.option != plural.option) each
    ];
    setState(() => _updateTranslationPlurals(plurals));
  }

  void _updateTranslationPlurals(List<ArbPlural> plurals) {
    widget.translationController.update(
      (state) => state.copyWith(options: UnmodifiableListView(plurals)),
    );
    widget.onUpdateTranslation(widget.translationController.state);
    _onDiscardChanges();
  }

  Future<void> _alertPendingChanges() {
    return showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Please save or discard changes'),
            content: const Text(
              'There are pending changes in the plural being edited.\n'
              'Please save or discard changes before editing another plural.',
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
            content: const Text('There already exists a plural with this name. Replace it?'),
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

class _AnimatedPluralsAndForm extends AnimatedWidget {
  _AnimatedPluralsAndForm(
    this.loc,
    this.colors, {
    required Animation<double> animation,
    required this.translationBuilder,
    required this.definition,
    required this.newPluralCallback,
    required this.editPluralCallback,
    required this.discardChangesCallback,
    required this.addCallback,
    required this.replaceCallback,
    required this.translationController,
    required this.formPluralController,
    required this.availablePluralOptionsController,
    required this.existingPluralBeingEditedController,
    required this.updateCallback,
    required this.deleteCallback,
  }) : super(listenable: animation);

  final AppLocalizations loc;
  final ColorScheme colors;
  final ArbPluralTranslationBuilder translationBuilder;
  final ArbPluralDefinition definition;
  final VoidCallback newPluralCallback;
  final VoidCallback discardChangesCallback;
  final ValueChanged<ArbPlural> editPluralCallback;
  final ValueChanged<ArbPlural?> updateCallback;
  final ValueChanged<ArbPlural> addCallback;
  final ValueChanged<ArbPlural> replaceCallback;
  final ValueChanged<ArbPlural> deleteCallback;
  final StateController<ArbPluralTranslation> translationController;
  final StateController<ArbPlural?> formPluralController;
  final StateController<List<ArbPluralOption>> availablePluralOptionsController;
  final StateController<ArbPlural?> existingPluralBeingEditedController;
  final StateController<Offset> startTargetOffset = StateController(Offset.zero);
  final StateController<Offset> finalTargetOffset = StateController(Offset.zero);
  final StateController<RenderBox?> startTargetRenderBox = StateController(null);
  final StateController<RenderBox?> finalTargetRenderBox = StateController(null);

  final _stackKey = LabeledGlobalKey('pluralStackKey');
  final _newPluralKey = LabeledGlobalKey('newPluralKey');
  final _savePluralKey = LabeledGlobalKey('savePluralKey');
  final _selectedPlaceholderKey = LabeledGlobalKey('selectedPluralKey');
  final _pluralInputKey = LabeledGlobalKey('pluralInputKey');

  Animation<double> get animation => listenable as Animation<double>;

  bool get isInitial => animation.value == 0.0;
  bool get isAnimating => animation.value > 0.0 && animation.value < 1.0;
  bool get isFinal => animation.value == 1.0;

  bool get isEdition => existingPluralBeingEditedController.state != null;

  @override
  Widget build(BuildContext context) {
    if (isInitial || isFinal) {
      startTargetRenderBox.state = null;
    }
    return Stack(
      key: _stackKey,
      children: [
        _plurals(),
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
          text: existingPluralBeingEditedController.state!.option.name,
          align: Alignment.centerLeft,
          onPressed: () {});
    }
    final showNewButton = animation.status == AnimationStatus.reverse && animation.value < 0.8 ||
        animation.value < 0.3;
    return showNewButton
        ? FormButton(text: loc.label_new, colors: colors, onPressed: () {})
        : FormButton(text: loc.label_add_plural, colors: colors, onPressed: null);
  }

  void _readPositions() {
    final startTarget = isEdition
        ? _selectedPlaceholderKey.currentContext?.findRenderObject()
        : _newPluralKey.currentContext?.findRenderObject();
    final finalTarget = isEdition
        ? _pluralInputKey.currentContext?.findRenderObject()
        : _savePluralKey.currentContext?.findRenderObject();
    final stackWidget = _stackKey.currentContext?.findRenderObject();
    if (startTarget is RenderBox && finalTarget is RenderBox && stackWidget != null) {
      startTargetRenderBox.state = startTarget;
      finalTargetRenderBox.state = finalTarget;
      startTargetOffset.state = startTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
      finalTargetOffset.state = finalTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
    }
  }

  Widget _plurals() {
    final arbTranslation = translationController.state;
    final availableOptions = availablePluralOptionsController.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Plurals: ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 12.0,
            children: [
              for (final each in arbTranslation.options)
                _pluralTag(each, beingEdited: existingPluralBeingEditedController.state),
              if (availableOptions.isNotEmpty)
                FormButton(
                  key: _newPluralKey,
                  colors: colors,
                  tonal: true,
                  text: loc.label_new,
                  onPressed: newPluralCallback,
                  hide: !isInitial && !isEdition,
                  opacity: 1.0 - animation.value,
                ),
            ],
          ),
        ),
        if (!isInitial && formPluralController.state != null)
          SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: animation,
            child: Opacity(
              opacity: animation.value,
              child: TranslationPluralForm(
                definition: definition,
                availableOptions: availableOptions,
                original: existingPluralBeingEditedController.state,
                formPlural: formPluralController.state!,
                onUpdate: updateCallback,
                addCallback: addCallback,
                replaceCallback: replaceCallback,
                onDiscard: discardChangesCallback,
                showPluralInput: isFinal || !isEdition,
                showAddButton: isFinal || isEdition,
                pluralInputKey: _pluralInputKey,
                addButtonKey: _savePluralKey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _pluralTag(ArbPlural plural, {required ArbPlural? beingEdited}) {
    final selected = plural.option == beingEdited?.option;
    return ArbChip(translationBuilder.arbOptionWidget(plural),
        key: selected ? _selectedPlaceholderKey : null,
        selected: selected,
        onPressed: () => editPluralCallback(plural),
        onDelete: plural.option == ArbPluralOption.other ? null : () => deleteCallback(plural));
  }
}

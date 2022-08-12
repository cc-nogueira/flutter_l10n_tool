import 'dart:collection';

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/arb_chip.dart';
import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_button.dart';
import '../../../l10n/app_localizations.dart';
import '../builder/arb_translation_builder.dart';
import 'translation_select_form.dart';

/// Show existing select options, actions and a dynamic form for plurals edition.
///
/// Interacts with [ArbUsecase] to update these select options under use interaction and to track the
/// existing selection being edited (or none) for an [ArbSelectTranslation].
class TranslationSelectsAndForm extends ConsumerWidget {
  /// Const constructor.
  const TranslationSelectsAndForm({
    super.key,
    required this.translationBuilder,
    required this.definition,
    required this.locale,
    required this.translationController,
    required this.onUpdateTranslation,
  });

  final ArbSelectTranslationBuilder translationBuilder;

  /// Original definition is used as Key to translations providers.
  final ArbSelectDefinition definition;

  final String locale;
  final StateController<ArbSelectTranslation> translationController;
  final ValueChanged<ArbSelectTranslation> onUpdateTranslation;

  /// Build method read plural providers (without watching them) and renders
  /// the internal [_TranslationSelectsAndForm] widget.
  ///
  /// Also register callbacks to interact with [ArbUsecase].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final formOption = ref.read(formSelectsProvider)[definition]?[locale];
    final existingOptionBeingEdited =
        ref.read(existingSelectsBeingEditedProvider)[definition]?[locale];
    final knownCases =
        ref.read(analysisProvider).knownCasesPerSelectDefinition[definition.key] ?? <String>{};
    return _TranslationSelectsAndForm(
      loc,
      colors,
      definition: definition,
      translationBuilder: translationBuilder,
      translationController: translationController,
      formOption: formOption,
      existingOptionBeingEdited: existingOptionBeingEdited,
      knownCases: knownCases,
      onUpdateTranslation: onUpdateTranslation,
      onUpdateOption: (value) => _updateFormOption(ref.read, locale, value),
      onEditOption: (value) => _editOption(ref.read, locale, value),
    );
  }

  /// Internal - update the plural under user edition through its usecase.
  void _updateFormOption(Reader read, String locale, ArbSelectCase? formSelect) {
    read(arbUsecaseProvider)
        .updateFormSelect(definition: definition, locale: locale, option: formSelect);
  }

  /// Internal - track the plural being edited (or none) through its usecase.
  void _editOption(Reader read, String locale, ArbSelectCase? selection) {
    read(arbUsecaseProvider)
        .trackExistingSelectBeingEdited(definition: definition, locale: locale, option: selection);
  }
}

class _TranslationSelectsAndForm extends StatefulWidget {
  /// Const constructor.
  _TranslationSelectsAndForm(
    this.loc,
    this.colors, {
    required this.definition,
    required this.translationBuilder,
    required this.translationController,
    required ArbSelectCase? formOption,
    required ArbSelectCase? existingOptionBeingEdited,
    required this.knownCases,
    required this.onUpdateTranslation,
    required this.onUpdateOption,
    required this.onEditOption,
  })  : formOptionController = StateController(formOption),
        existingOptionBeingEditedController = StateController(existingOptionBeingEdited);

  @override
  State<_TranslationSelectsAndForm> createState() => _TranslationSelectsAndFormState();

  /// AppLocalizations is "cached" here because it is used many times by the state object.
  final AppLocalizations loc;

  /// The color schem is "cached" here because it is used many times by the state object.
  final ColorScheme colors;

  final ArbSelectDefinition definition;
  final ArbSelectTranslationBuilder translationBuilder;
  final StateController<ArbSelectTranslation> translationController;
  final StateController<ArbSelectCase?> formOptionController;
  final StateController<ArbSelectCase?> existingOptionBeingEditedController;
  final Set<String> knownCases;
  final ValueChanged<ArbSelectTranslation> onUpdateTranslation;
  final ValueChanged<ArbSelectCase?> onUpdateOption;
  final ValueChanged<ArbSelectCase?> onEditOption;

  bool get formPluralHasChanges {
    final formPlural = formOptionController.state;
    if (formPlural == null) {
      return false;
    }
    final beingEdited = existingOptionBeingEditedController.state ?? '';
    return formPlural != beingEdited;
  }
}

class _TranslationSelectsAndFormState extends State<_TranslationSelectsAndForm>
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
  void didUpdateWidget(covariant _TranslationSelectsAndForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      resetState();
    }
  }

  void resetState() {
    if (!_controller.isAnimating) {
      if (widget.formOptionController.state == null) {
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
    return _AnimatedSelectsAndForm(
      widget.loc,
      widget.colors,
      animation: _controller.view,
      translationBuilder: widget.translationBuilder,
      definition: widget.definition,
      newCallback: _onNewOption,
      editCallback: _onEditOption,
      editMissingCallback: _onEditMissingOption,
      discardChangesCallback: _onDiscardChanges,
      updateCallback: _onUpdate,
      addCallback: _onAdd,
      replaceCallback: _onReplace,
      deleteCallback: _onDelete,
      translationController: widget.translationController,
      formOptionController: widget.formOptionController,
      existingOptionBeingEditedController: widget.existingOptionBeingEditedController,
      knownCases: widget.knownCases,
    );
  }

  void _onNewOption() {
    const option = ArbSelectCase(option: '');
    widget.formOptionController.state = option;
    widget.onUpdateOption(option);
    _controller.forward(from: 0.0);
  }

  void _onEditOption(ArbSelectCase selection) {
    if (widget.formPluralHasChanges) {
      _alertPendingChanges();
      return;
    }
    widget.formOptionController.state = selection;
    widget.existingOptionBeingEditedController.state = selection;
    widget.onUpdateOption(selection);
    widget.onEditOption(selection);
    _controller.forward(from: 0.0);
  }

  void _onEditMissingOption(ArbSelectCase selectCase) {
    if (widget.formPluralHasChanges) {
      _alertPendingChanges();
      return;
    }
    widget.formOptionController.state = selectCase;
    widget.onUpdateOption(selectCase);
    _controller.forward(from: 0.0);
  }

  void _onDiscardChanges() {
    _controller.reverse(from: 1.0).then((_) {
      widget.formOptionController.state = null;
      widget.existingOptionBeingEditedController.state = null;
      widget.onEditOption(null);
      widget.onUpdateOption(null);
    });
  }

  void _onUpdate(ArbSelectCase? selection) {
    widget.formOptionController.state = selection;
    widget.onUpdateOption(selection);
  }

  Future<void> _onAdd(ArbSelectCase selection) async {
    final selections = List<ArbSelectCase>.from(widget.translationController.state.options);
    final foundIndex = selections.indexWhere((element) => element.option == selection.option);
    if (foundIndex != -1) {
      final replace = await _confirmReplaceDialog();
      if (replace != true) {
        return;
      }
      selections[foundIndex] = selection;
    } else {
      selections.add(selection);
      selections.sort((a, b) => a.option.compareTo(b.option));
    }
    _updateTranslationSelects(selections);
  }

  Future<void> _onReplace(ArbSelectCase selection) async {
    final beingEdited = widget.existingOptionBeingEditedController.state!;
    final selections = List<ArbSelectCase>.from(widget.translationController.state.options);
    final foundIndex = selections.indexWhere((element) => element.option == beingEdited.option);
    if (foundIndex == -1) {
      return;
    }
    if (selection.option == beingEdited.option) {
      selections[foundIndex] = selection;
    } else {
      final repeatedIndex = selections.indexWhere((element) => element.option == selection.option);
      if (repeatedIndex != -1) {
        final replace = await _confirmReplaceDialog();
        if (replace != true) {
          return;
        }
        selections.removeAt(repeatedIndex);
      }
      selections[foundIndex] = selection;
      selections.sort((a, b) => a.option.compareTo(b.option));
    }
    _updateTranslationSelects(selections);
  }

  void _onDelete(ArbSelectCase selection) {
    final selections = [
      for (final each in widget.translationController.state.options)
        if (each.option != selection.option) each
    ];
    setState(() => _updateTranslationSelects(selections));
  }

  void _updateTranslationSelects(List<ArbSelectCase> selections) {
    widget.translationController.update(
      (state) => state.copyWith(options: UnmodifiableListView(selections)),
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
              'There are pending changes in the select being edited.\n'
              'Please save or discard changes before editing another select option.',
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
            content: const Text('There already exists a select option with this name. Replace it?'),
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

class _AnimatedSelectsAndForm extends AnimatedWidget {
  _AnimatedSelectsAndForm(
    this.loc,
    this.colors, {
    required Animation<double> animation,
    required this.translationBuilder,
    required this.definition,
    required this.newCallback,
    required this.editCallback,
    required this.editMissingCallback,
    required this.discardChangesCallback,
    required this.addCallback,
    required this.replaceCallback,
    required this.translationController,
    required this.formOptionController,
    required this.existingOptionBeingEditedController,
    required this.knownCases,
    required this.updateCallback,
    required this.deleteCallback,
  }) : super(listenable: animation);

  final AppLocalizations loc;
  final ColorScheme colors;
  final ArbSelectTranslationBuilder translationBuilder;
  final ArbSelectDefinition definition;
  final VoidCallback newCallback;
  final VoidCallback discardChangesCallback;
  final ValueChanged<ArbSelectCase> editCallback;
  final ValueChanged<ArbSelectCase> editMissingCallback;
  final ValueChanged<ArbSelectCase?> updateCallback;
  final ValueChanged<ArbSelectCase> addCallback;
  final ValueChanged<ArbSelectCase> replaceCallback;
  final ValueChanged<ArbSelectCase> deleteCallback;
  final StateController<ArbSelectTranslation> translationController;
  final StateController<ArbSelectCase?> formOptionController;
  final StateController<ArbSelectCase?> existingOptionBeingEditedController;
  final Set<String> knownCases;
  final StateController<Offset> startTargetOffset = StateController(Offset.zero);
  final StateController<Offset> finalTargetOffset = StateController(Offset.zero);
  final StateController<RenderBox?> startTargetRenderBox = StateController(null);
  final StateController<RenderBox?> finalTargetRenderBox = StateController(null);

  final _stackKey = LabeledGlobalKey('optionStackKey');
  final _newOptionKey = LabeledGlobalKey('newOptionKey');
  final _saveOptionKey = LabeledGlobalKey('saveOptionKey');
  final _selectedOptionKey = LabeledGlobalKey('selectedOptionKey');
  final _optionInputKey = LabeledGlobalKey('optionInputKey');

  Animation<double> get animation => listenable as Animation<double>;

  bool get isInitial => animation.value == 0.0;
  bool get isAnimating => animation.value > 0.0 && animation.value < 1.0;
  bool get isFinal => animation.value == 1.0;

  bool get isEdition => existingOptionBeingEditedController.state != null;

  @override
  Widget build(BuildContext context) {
    if (isInitial || isFinal) {
      startTargetRenderBox.state = null;
    }
    return Stack(
      key: _stackKey,
      children: [
        _options(),
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
          text: existingOptionBeingEditedController.state!.option,
          align: Alignment.centerLeft,
          onPressed: () {});
    }
    final showNewButton = animation.status == AnimationStatus.reverse && animation.value < 0.8 ||
        animation.value < 0.3;
    return showNewButton
        ? FormButton(text: loc.label_new, colors: colors, onPressed: () {})
        : FormButton(text: loc.label_add_select, colors: colors, onPressed: null);
  }

  void _readPositions() {
    final startTarget = isEdition
        ? _selectedOptionKey.currentContext?.findRenderObject()
        : _newOptionKey.currentContext?.findRenderObject();
    final finalTarget = isEdition
        ? _optionInputKey.currentContext?.findRenderObject()
        : _saveOptionKey.currentContext?.findRenderObject();
    final stackWidget = _stackKey.currentContext?.findRenderObject();
    if (startTarget is RenderBox && finalTarget is RenderBox && stackWidget != null) {
      startTargetRenderBox.state = startTarget;
      finalTargetRenderBox.state = finalTarget;
      startTargetOffset.state = startTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
      finalTargetOffset.state = finalTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
    }
  }

  Widget _options() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select cases: ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 12.0,
            children: [
              for (final each in translationController.state.options)
                _optionTag(each, beingEdited: existingOptionBeingEditedController.state),
              for (final each in _missingCases())
                _optionTag(each,
                    beingEdited: existingOptionBeingEditedController.state, missing: true),
              if (animation.value < 1.0)
                FormButton(
                  key: _newOptionKey,
                  colors: colors,
                  tonal: true,
                  text: loc.label_new,
                  onPressed: newCallback,
                  hide: !isInitial && !isEdition,
                  opacity: 1.0 - animation.value,
                ),
            ],
          ),
        ),
        if (!isInitial && formOptionController.state != null)
          SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: animation,
            child: Opacity(
              opacity: animation.value,
              child: TranslationSelectForm(
                definition: definition,
                original: existingOptionBeingEditedController.state,
                formOption: formOptionController.state!,
                onUpdate: updateCallback,
                addCallback: addCallback,
                replaceCallback: replaceCallback,
                onDiscard: discardChangesCallback,
                showOptionInput: isFinal || !isEdition,
                showAddButton: isFinal || isEdition,
                optionInputKey: _optionInputKey,
                addButtonKey: _saveOptionKey,
              ),
            ),
          ),
      ],
    );
  }

  List<ArbSelectCase> _missingCases() {
    final existingCases = <String>{};
    for (final arbSelect in translationController.state.options) {
      existingCases.add(arbSelect.option);
    }
    return [
      for (final known in knownCases)
        if (!existingCases.contains(known)) ArbSelectCase(option: known),
    ];
  }

  Widget _optionTag(ArbSelectCase arbSelect,
      {required ArbSelectCase? beingEdited, bool missing = false}) {
    final selected = arbSelect.option == beingEdited?.option;
    return ArbChip(translationBuilder.arbOptionWidget(arbSelect),
        key: selected ? _selectedOptionKey : null,
        selected: selected,
        missing: missing,
        onPressed: missing ? () => editMissingCallback(arbSelect) : () => editCallback(arbSelect),
        onDelete: missing ? null : () => deleteCallback(arbSelect));
  }
}

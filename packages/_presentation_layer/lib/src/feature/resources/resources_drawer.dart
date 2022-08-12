import 'package:_core_layer/notifiers.dart';
import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/navigation/navigation_drawer_option.dart';
import '../../common/widget/buttons.dart';
import '../../common/widget/navigation_drawer.dart';
import '../../l10n/app_localizations.dart';
import '../../provider/presentation_providers.dart';

final _filterProvider = StateProvider((_) => [false, false, false, false]);
final _considerLocalesProvider = StateProvider(((ref) => true));

class ResourcesDrawer extends NavigationDrawer {
  const ResourcesDrawer({super.key}) : super(NavigationDrawerTopOption.resources);

  @override
  String titleText(AppLocalizations loc) => loc.title_resources_drawer;

  @override
  EdgeInsetsGeometry get headerChildPadding => const EdgeInsets.only(left: 16, right: 4.0);

  @override
  Widget? headerChild(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _localeOption(colors, ref),
        _filterButtons(context, ref),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _localeOption(ColorScheme colors, WidgetRef ref) {
    final considerLocales = ref.watch(_considerLocalesProvider);
    final style = considerLocales
        ? TextStyle(color: colors.onPrimaryContainer)
        : TextStyle(color: colors.secondary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 23,
          child: FittedBox(child: Text('Analyse only selected locales:', style: style)),
        ),
        Switch(
          value: considerLocales,
          onChanged: (value) => ref.read(_considerLocalesProvider.notifier).state = value == true,
        ),
      ],
    );
  }

  Widget _filterButtons(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final selectedFilters = ref.watch(_filterProvider);
    return Row(
      children: [
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.start,
          minimumSize: const Size(0, 36),
          showSelectedMark: false,
          noSplash: true,
          selectedColor: Colors.white,
          selected: selectedFilters[1],
          child: const Icon(Icons.edit, size: 16),
          onPressed: () => _onFilterPressed(ref.read, 1),
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.center,
          minimumSize: const Size(0, 36),
          showSelectedMark: false,
          selectedColor: Colors.white,
          noSplash: true,
          selected: selectedFilters[2],
          child: const Icon(Icons.save, size: 16),
          onPressed: () => _onFilterPressed(ref.read, 2),
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.center,
          minimumSize: const Size(0, 36),
          showSelectedMark: false,
          noSplash: true,
          selectedColor: Colors.white,
          selected: selectedFilters[0],
          child: const Icon(Icons.add_box, size: 16),
          onPressed: () => _onFilterPressed(ref.read, 0),
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.end,
          minimumSize: const Size(0, 36),
          showSelectedMark: false,
          selectedColor: Colors.amberAccent,
          noSplash: true,
          selected: selectedFilters[3],
          child: const Icon(Icons.warning_amber, size: 16),
          onPressed: () => _onFilterPressed(ref.read, 3),
        ),
        clearFiltersButton(colors, () => _onFilterPressed(ref.read)),
      ],
    );
  }

  void _onFilterPressed(Reader read, [int? idx]) {
    read(_filterProvider.notifier).update(
      (state) => [
        for (int i = 0; i < state.length; ++i)
          idx == null
              ? false
              : i == idx
                  ? !state[i]
                  : state[i],
      ],
    );
  }

  List<ArbDefinition> _filteredDefinitions({
    required List<ArbDefinition> originalDefinitions,
    required SetState<ArbDefinition> newDefinitions,
    required ArbDefinition? selected,
    required List<String> locales,
    required List<bool> selectedFilters,
    required EditionsState<ArbDefinition, ArbDefinition> currentDefinitions,
    required EditionsState<ArbDefinition, ArbDefinition> beingEditedDefinitions,
    required EditionsOneToMapState<ArbDefinition, String, ArbTranslation> currentTranslations,
    required EditionsOneToManyState<ArbDefinition, String> beingEditedTranslations,
    required EditionsOneToManyState<ArbDefinition, ArbWarning> warnings,
  }) {
    final filters = [
      if (selectedFilters[0]) (ArbDefinition def) => _isNewDefinition(locales, newDefinitions, def),
      if (selectedFilters[1])
        (ArbDefinition def) =>
            _isBeingEdited(locales, beingEditedDefinitions, beingEditedTranslations, def),
      if (selectedFilters[2])
        (ArbDefinition def) => _isModified(locales, currentDefinitions, currentTranslations, def),
      if (selectedFilters[3]) (ArbDefinition def) => _hasWarnings(locales, warnings, def),
    ];
    if (filters.isEmpty) {
      return [...newDefinitions, ...originalDefinitions];
    }
    return [
      for (final def in newDefinitions)
        if (def == selected || filters.any((filter) => filter(def))) def,
      for (final def in originalDefinitions)
        if (def == selected || filters.any((filter) => filter(def))) def,
    ];
  }

  @override
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final colors = Theme.of(context).colorScheme;
    final project = ref.watch(projectProvider);

    final considerLocales = ref.watch(_considerLocalesProvider);
    final localesToAnalyse =
        considerLocales ? ref.watch(selectedLocalesProvider) : ref.watch(allLocalesProvider);
    final newDefinitions = ref.watch(newDefinitionsProvider);
    final currentDefinitions = ref.watch(currentDefinitionsProvider);
    final currentTranslations = ref.watch(currentTranslationsProvider);
    final beingEditedTranslations = ref.watch(beingEditedTranslationLocalesProvider);
    final beingEditedDefinitions = ref.watch(beingEditedDefinitionsProvider);
    final warnings = ref.watch(analysisWarningsProvider);
    final selected = ref.watch(selectedDefinitionProvider);
    final isEditingNewDefinition = ref.watch(editNewDefinitionProvider);

    final selectedFilters = ref.watch(_filterProvider);
    final definitions = _filteredDefinitions(
      originalDefinitions: project.template.definitions,
      newDefinitions: newDefinitions,
      selected: selected,
      currentDefinitions: currentDefinitions,
      beingEditedDefinitions: beingEditedDefinitions,
      currentTranslations: currentTranslations,
      beingEditedTranslations: beingEditedTranslations,
      warnings: warnings,
      selectedFilters: selectedFilters,
      locales: localesToAnalyse,
    );

    return [
      Expanded(
        child: Container(
          decoration: const BoxDecoration(color: Colors.black12),
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTileTheme(
            style: ListTileStyle.drawer,
            child: FocusTraversalGroup(
              child: ListView.builder(
                primary: false,
                itemCount: definitions.length,
                itemBuilder: (ctx, index) {
                  final definition = definitions[index];
                  final current = currentDefinitions[definition];
                  final hasWarnings = _hasWarnings(localesToAnalyse, warnings, definition);
                  final isNew = _isNewDefinition(localesToAnalyse, newDefinitions, definition);
                  final isBeingEdited = _isBeingEdited(localesToAnalyse, beingEditedDefinitions,
                      beingEditedTranslations, definition);
                  final isModified = _isModified(
                      localesToAnalyse, currentDefinitions, currentTranslations, definition);
                  return _itemBuilder(
                    ctx,
                    ref.read,
                    colors,
                    definition,
                    current: current,
                    isNew: isNew,
                    isBeingEdited: isBeingEdited,
                    isSelected: !isEditingNewDefinition && definition == selected,
                    isModified: isModified,
                    hasWarnings: hasWarnings,
                  );
                },
              ),
            ),
          ),
        ),
      )
    ];
  }

  bool _isNewDefinition(
    List<String> locales,
    SetState<ArbDefinition> newDefinitions,
    ArbDefinition definition,
  ) =>
      newDefinitions.contains(definition);

  bool _isBeingEdited(
    List<String> locales,
    EditionsState<ArbDefinition, ArbDefinition> beingEditedDefinitions,
    EditionsOneToManyState<ArbDefinition, String> beingEditedTranslations,
    ArbDefinition definition,
  ) =>
      beingEditedDefinitions.containsKey(definition) ||
      _hasActiveTranslationsBeingEdited(
        locales,
        beingEditedTranslations[definition],
      );

  bool _hasActiveTranslationsBeingEdited(List<String> locales, Set<String>? beingEdited) =>
      beingEdited != null && locales.any((locale) => beingEdited.contains(locale));

  bool _isModified(
    List<String> locales,
    EditionsState<ArbDefinition, ArbDefinition> currentDefinitions,
    EditionsOneToMapState<ArbDefinition, String, ArbTranslation> currentTranslations,
    ArbDefinition definition,
  ) {
    return currentDefinitions[definition] != null ||
        _hasActiveModifiedTranslations(
          locales,
          currentTranslations[definition]?.keys,
        );
  }

  bool _hasActiveModifiedTranslations(List<String> locales, Iterable<String>? modified) =>
      modified != null && modified.any((locale) => locales.contains(locale));

  bool _hasWarnings(
    List<String> locales,
    EditionsOneToManyState<ArbDefinition, ArbWarning> warnings,
    ArbDefinition definition,
  ) {
    final warns = warnings[definition];
    return warns != null && warns.any((warn) => locales.contains(warn.locale));
  }

  Widget _itemBuilder(
    BuildContext context,
    Reader read,
    ColorScheme colors,
    ArbDefinition definition, {
    required ArbDefinition? current,
    required bool isSelected,
    required bool isNew,
    required bool isBeingEdited,
    required bool isModified,
    required bool hasWarnings,
  }) {
    final leading = isNew
        ? const Icon(Icons.add_box, size: 14)
        : isBeingEdited
            ? const Icon(Icons.edit, size: 14)
            : isModified
                ? const Icon(Icons.save, size: 14)
                : const SizedBox(width: 12);
    final color = hasWarnings ? Colors.amberAccent : null;
    final style = isSelected
        ? TextStyle(fontWeight: FontWeight.w600, color: color)
        : hasWarnings
            ? TextStyle(color: color)
            : null;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      selectedTileColor: colors.secondaryContainer,
      selectedColor: colors.onSecondaryContainer,
      minLeadingWidth: 14,
      leading: leading,
      trailing: isSelected ? const Icon(Icons.keyboard_double_arrow_right) : null,
      selected: isSelected,
      title: Text(current?.key ?? definition.key, style: style),
      onTap: () => _onResourceTap(read, definition),
    );
  }

  void _onResourceTap(Reader read, ArbDefinition definition) {
    final isCtrlPressed =
        RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlRight);
    if (isCtrlPressed) {
      read(arbUsecaseProvider).toggle(definition);
    } else {
      read(arbUsecaseProvider).select(definition);
    }
  }
}

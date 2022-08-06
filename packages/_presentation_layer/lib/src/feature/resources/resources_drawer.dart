import 'package:_core_layer/notifiers.dart';
import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/navigation/navigation_drawer_option.dart';
import '../../common/widget/buttons.dart';
import '../../common/widget/navigation_drawer.dart';
import '../../l10n/app_localizations.dart';

final filterProvider = StateProvider((_) => [false, false, false]);

class ResourcesDrawer extends NavigationDrawer {
  const ResourcesDrawer({super.key}) : super(NavigationDrawerTopOption.resources);

  @override
  String titleText(AppLocalizations loc) => loc.title_resources_drawer;

  @override
  Widget? headerChild(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filterButtons(context, ref),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _filterButtons(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final selectedFilters = ref.watch(filterProvider);
    return Row(
      children: [
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.start,
          minimumSize: const Size(0, 32),
          showSelectedMark: false,
          noSplash: true,
          selectedColor: Colors.white,
          selected: selectedFilters[0],
          child: const Icon(Icons.edit, size: 16),
          onPressed: () => _onFilterPressed(ref.read, 0),
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.center,
          minimumSize: const Size(0, 32),
          showSelectedMark: false,
          selectedColor: Colors.white,
          noSplash: true,
          selected: selectedFilters[1],
          child: const Icon(Icons.save, size: 16),
          onPressed: () => _onFilterPressed(ref.read, 1),
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.end,
          minimumSize: const Size(0, 32),
          showSelectedMark: false,
          selectedColor: Colors.amberAccent,
          noSplash: true,
          selected: selectedFilters[2],
          child: const Icon(Icons.warning_amber, size: 16),
          onPressed: () => _onFilterPressed(ref.read, 2),
        ),
        IconButton(
          icon: const Icon(Icons.backspace_outlined, size: 20),
          onPressed: () => _onFilterPressed(ref.read),
          splashRadius: 20,
          color: colors.secondary,
        ),
      ],
    );
  }

  void _onFilterPressed(Reader read, [int? idx]) {
    read(filterProvider.notifier).update(
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

  List<ArbDefinition> _filteredDefinitions(
    List<ArbDefinition> definitions, {
    required ArbDefinition? selected,
    required EditionsState<ArbDefinition, ArbDefinition> currentDefinitions,
    required EditionsState<ArbDefinition, ArbDefinition> beingEditedDefinitions,
    required EditionsOneToMapState<ArbDefinition, String, ArbTranslation> currentTranslations,
    required EditionsOneToManyState<ArbDefinition, String> beingEditedTranslations,
    required EditionsOneToManyState<ArbDefinition, WarningType> warnings,
    required List<bool> selectedFilters,
  }) {
    final filters = [
      if (selectedFilters[0])
        (ArbDefinition def) =>
            beingEditedTranslations.containsKey(def) || beingEditedDefinitions.containsKey(def),
      if (selectedFilters[1])
        (ArbDefinition def) =>
            currentDefinitions.containsKey(def) || currentTranslations.containsKey(def),
      if (selectedFilters[2]) (ArbDefinition def) => warnings.containsKey(def),
    ];
    if (filters.isEmpty) {
      return definitions;
    }
    return [
      for (final def in definitions)
        if (def == selected || filters.any((filter) => filter(def))) def,
    ];
  }

  @override
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final colors = Theme.of(context).colorScheme;
    final project = ref.watch(projectProvider);

    final currentDefinitions = ref.watch(currentDefinitionsProvider);
    final currentTranslations = ref.watch(currentTranslationsProvider);
    final beingEditedTranslations = ref.watch(beingEditedTranslationLocalesProvider);
    final beingEditedDefinitions = ref.watch(beingEditedDefinitionsProvider);
    final warnings = ref.watch(analysisWarningsProvider);
    final selected = ref.watch(selectedDefinitionProvider);

    final selectedFilters = ref.watch(filterProvider);
    final definitions = _filteredDefinitions(
      project.template.definitions,
      selected: selected,
      currentDefinitions: currentDefinitions,
      beingEditedDefinitions: beingEditedDefinitions,
      currentTranslations: currentTranslations,
      beingEditedTranslations: beingEditedTranslations,
      warnings: warnings,
      selectedFilters: selectedFilters,
    );

    return [
      Expanded(
        child: ListTileTheme(
          style: ListTileStyle.drawer,
          child: FocusTraversalGroup(
            child: ListView.builder(
              primary: false,
              itemCount: definitions.length,
              itemBuilder: (ctx, index) {
                final definition = definitions[index];
                final current = currentDefinitions[definition];
                final isBeingEdited = beingEditedTranslations.containsKey(definition) ||
                    beingEditedDefinitions.containsKey(definition);
                final hasModifiedTranslations = currentTranslations.containsKey(definition);
                final hasWarnings = warnings[definition] != null;
                return _itemBuilder(
                  ctx,
                  ref.read,
                  colors,
                  definition,
                  current: current,
                  isBeingEdited: isBeingEdited,
                  isSelected: definition == selected,
                  isModified: current != null || hasModifiedTranslations,
                  hasWarnings: hasWarnings,
                );
              },
            ),
          ),
        ),
      )
    ];
  }

  Widget _itemBuilder(
    BuildContext context,
    Reader read,
    ColorScheme colors,
    ArbDefinition definition, {
    required ArbDefinition? current,
    required bool isSelected,
    required bool isBeingEdited,
    required bool isModified,
    required bool hasWarnings,
  }) {
    final leading = isBeingEdited
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

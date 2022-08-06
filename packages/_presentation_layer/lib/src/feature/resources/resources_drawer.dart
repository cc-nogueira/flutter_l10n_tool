import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/navigation/navigation_drawer_option.dart';
import '../../common/widget/navigation_drawer.dart';
import '../../l10n/app_localizations.dart';

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
        ToggleButtons(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          isSelected: const [false],
          children: const [
            Icon(Icons.save),
          ],
        )
      ],
    );
  }

  @override
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final colors = Theme.of(context).colorScheme;
    final project = ref.watch(projectProvider);
    final definitions = project.template.definitions;

    final currentDefinitions = ref.watch(currentDefinitionsProvider);
    final currentTranslations = ref.watch(currentTranslationsProvider);
    final beingEditedTranslations = ref.watch(beingEditedTranslationLocalesProvider);
    final beingEditedDefinitions = ref.watch(beingEditedDefinitionsProvider);
    final selected = ref.watch(selectedDefinitionProvider);
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
                return _itemBuilder(
                  ctx,
                  ref.read,
                  colors,
                  definition,
                  current: current,
                  isBeingEdited: isBeingEdited,
                  isSelected: definition == selected,
                  isModified: current != null || hasModifiedTranslations,
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
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      selectedTileColor: colors.secondaryContainer,
      selectedColor: colors.onSecondaryContainer,
      minLeadingWidth: 14,
      leading: isBeingEdited
          ? const Icon(Icons.edit, size: 14)
          : isModified
              ? const Icon(Icons.save, size: 14)
              : const SizedBox(width: 12),
      trailing: isSelected ? const Icon(Icons.keyboard_double_arrow_right) : null,
      selected: isSelected,
      title: Text(
        current?.key ?? definition.key,
        style: isSelected ? const TextStyle(fontWeight: FontWeight.w600) : null,
      ),
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

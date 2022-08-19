import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/navigation/navigation_drawer_option.dart';
import '../../../common/widget/navigation_drawer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../provider/presentation_providers.dart';
import '../../resources/widget/analyse_selected_locales_only_switch.dart';

class ChangeControlDrawer extends NavigationDrawer {
  const ChangeControlDrawer({super.key}) : super(NavigationDrawerTopOption.changeControl);

  @override
  String titleText(AppLocalizations loc) => loc.title_change_control_drawer;

  @override
  EdgeInsetsGeometry get headerChildPadding => const EdgeInsets.only(left: 16, right: 4.0);

  @override
  Widget headerChild(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        AnalyseSelectedLocalesOnlySwitch(),
        SizedBox(height: 4),
      ],
    );
  }

  List<ArbTrashedResource> _filteredResources({
    required Map<ArbDefinition, ArbTrashedResource> trashedResources,
    ArbTrashedResource? selected,
    required List<String> locales,
  }) {
    return [];
  }

  // @override
  List<Widget> children2(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final colors = Theme.of(context).colorScheme;

    final considerLocales = ref.watch(analyseSelectedLocalesOnlyProvider);
    final localesToAnalyse =
        considerLocales ? ref.watch(activeLocalesProvider) : ref.watch(allLocalesProvider);
    final trashedResources =
        <ArbDefinition, ArbTrashedResource>{}; //ref.watch(newDefinitionsProvider);
    const ArbTrashedResource? selected = null; //ref.watch(selectedDefinitionProvider);

    final filteredResources = _filteredResources(
      trashedResources: trashedResources,
      selected: selected,
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
                itemCount: filteredResources.length,
                itemBuilder: (ctx, index) {
                  final trashed = filteredResources[index];
                  return _itemBuilder(
                    ctx,
                    ref.read,
                    colors,
                    trashed,
                    isSelected: trashed == selected,
                  );
                },
              ),
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
    ArbTrashedResource trashed, {
    required bool isSelected,
  }) {
    final style = isSelected ? const TextStyle(fontWeight: FontWeight.w600) : null;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      selectedTileColor: colors.secondaryContainer,
      selectedColor: colors.onSecondaryContainer,
      minLeadingWidth: 14,
      trailing: isSelected ? const Icon(Icons.keyboard_double_arrow_right) : null,
      selected: isSelected,
      title: Text(trashed.definition.key, style: style),
      onTap: () => _onResourceTap(read, trashed),
    );
  }

  void _onResourceTap(Reader read, ArbTrashedResource trashed) {
    final isCtrlPressed =
        RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlRight);
    if (isCtrlPressed) {
      //read(arbUsecaseProvider).toggle(definition);
    } else {
      //read(arbUsecaseProvider).select(definition);
    }
  }
}

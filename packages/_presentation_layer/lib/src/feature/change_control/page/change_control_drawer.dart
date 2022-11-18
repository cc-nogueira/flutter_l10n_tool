import 'package:_core_layer/notifiers.dart';
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

  static const staged = ArbDefinition.placeholders(key: 'Staged Changes');
  static const changes = ArbDefinition.placeholders(key: 'Changes');

  @override
  String titleText(AppLocalizations loc) => loc.title_change_control_drawer;

  @override
  EdgeInsetsGeometry get headerChildPadding => const EdgeInsets.only(left: 16, right: 4.0);

  List<ArbDefinition> _stagedResources() {
    return [];
  }

  List<ArbDefinition> _changedResources({
    required SetState<ArbDefinition> newDefinitions,
    required EditionsState<ArbDefinition, ArbDefinition> currentDefinitions,
    required EditionsOneToMapState<ArbDefinition, String, ArbTranslation> currentTranslations,
    required Map<ArbDefinition, ArbTrashedResource> trashedResources,
    required List<String> locales,
  }) {
    final resourcesSet = <ArbDefinition>{
      ...currentDefinitions.keys,
      ...currentTranslations.keys,
      ...trashedResources.keys,
    };

    final resourcesSorted = List<ArbDefinition>.from(resourcesSet);
    resourcesSorted.sort(((a, b) => a.key.compareTo(b.key)));

    final resources = <ArbDefinition>{
      ...newDefinitions,
      ...resourcesSorted,
    };

    return resources.toList();
  }

  @override
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final colors = Theme.of(context).colorScheme;

    final considerLocales = ref.watch(analyseSelectedLocalesOnlyProvider);
    final localesToAnalyse =
        considerLocales ? ref.watch(activeLocalesProvider) : ref.watch(allLocalesProvider);
    final selected = ref.watch(selectedChangeDefinitionProvider);
    final newDefinitions = ref.watch(newDefinitionsProvider);
    final currentDefinitions = ref.watch(currentDefinitionsProvider);
    final currentTranslations = ref.watch(currentTranslationsProvider);
    final trashedResources =
        <ArbDefinition, ArbTrashedResource>{}; //ref.watch(newDefinitionsProvider);

    final changedResources = _changedResources(
      newDefinitions: newDefinitions,
      currentDefinitions: currentDefinitions,
      currentTranslations: currentTranslations,
      trashedResources: trashedResources,
      locales: localesToAnalyse,
    );

    final stagedResources = _stagedResources();

    final resources = <ArbDefinition>[];
    if (stagedResources.isNotEmpty) {
      resources.add(staged);
      resources.addAll(stagedResources);
    }
    if (changedResources.isNotEmpty) {
      resources.add(changes);
      resources.addAll(changedResources);
    }

    return [
      Expanded(
        child: Container(
          decoration: BoxDecoration(color: colors.background),
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTileTheme(
            style: ListTileStyle.drawer,
            child: FocusTraversalGroup(
              child: ListView.builder(
                primary: false,
                itemCount: resources.length,
                itemBuilder: (ctx, index) {
                  final definition = resources[index];
                  return _itemBuilder(
                    ref,
                    colors,
                    definition,
                    isSelected: definition == selected,
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
    WidgetRef ref,
    ColorScheme colors,
    ArbDefinition definition, {
    required bool isSelected,
  }) {
    if (definition == staged || definition == changes) {
      return ResourceGroupTile(colors: colors, name: definition.key);
    }
    return ResourceTile(
      colors: colors,
      name: definition.key,
      isSelected: isSelected,
      onTap: () => _onResourceTap(ref, definition),
    );
  }

  void _onResourceTap(WidgetRef ref, ArbDefinition definition) {
    final isCtrlPressed =
        RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlRight);
    if (isCtrlPressed) {
      ref.read(changeControlUsecaseProvider).toggle(definition);
    } else {
      ref.read(changeControlUsecaseProvider).select(definition);
    }
  }
}

class ResourceTile extends StatelessWidget {
  const ResourceTile({
    super.key,
    required this.colors,
    required this.name,
    this.isSelected = false,
    this.onTap,
  });

  final ColorScheme colors;
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: tilePadding,
        decoration: BoxDecoration(color: tileColor),
        child: tileChild,
      ),
    );
  }

  Widget get tileChild => tileText;

  Widget get tileText => Text(name, style: textStyle);

  TextStyle get textStyle => isSelected
      ? TextStyle(fontWeight: FontWeight.w600, color: textColor)
      : TextStyle(color: textColor);

  EdgeInsets get tilePadding => const EdgeInsets.only(left: 12, top: 2, bottom: 4);

  Color? get tileColor => null;

  Color get textColor => colors.onBackground;
}

class ResourceGroupTile extends ResourceTile {
  const ResourceGroupTile({super.key, required super.colors, required super.name});

  @override
  Widget get tileChild => Row(children: [
        Icon(Icons.keyboard_arrow_down, color: textColor),
        tileText,
      ]);

  @override
  EdgeInsets get tilePadding => const EdgeInsets.only(bottom: 2);

  @override
  Color get tileColor => Colors.black12;
}

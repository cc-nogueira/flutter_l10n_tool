import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../common/navigation_drawer_option.dart';
import '../widget/navigation_drawer.dart';

class ResourcesDrawer extends NavigationDrawer {
  const ResourcesDrawer({super.key}) : super(NavigationDrawerTopOption.preferences);

  @override
  String titleText(AppLocalizations loc) => loc.title_resources_drawer;

  @override
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final colors = Theme.of(context).colorScheme;
    final project = ref.watch(projectProvider);
    final resources = project.template.resourceDefinitions;
    final selected = ref.watch(selectedResourceProvider);
    return [
      Expanded(
        child: ListTileTheme(
          style: ListTileStyle.drawer,
          child: FocusTraversalGroup(
            child: ListView.builder(
              itemCount: resources.length,
              itemBuilder: (ctx, index) {
                final resource = resources[index];
                return _itemBuilder(ctx, ref.read, colors, resource, resource == selected);
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
    ArbResourceDefinition resource,
    bool isSelected,
  ) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      selectedTileColor: colors.secondaryContainer,
      selectedColor: colors.onSecondaryContainer,
      trailing: isSelected ? const Icon(Icons.keyboard_double_arrow_right) : null,
      selected: isSelected,
      title: Text(
        resource.key,
        style: isSelected ? const TextStyle(fontWeight: FontWeight.w600) : null,
      ),
      onTap: () => read(selectedResourceProvider.notifier).state = resource,
    );
  }
}

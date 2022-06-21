import 'package:_domain_layer/domain_layer.dart';
import 'package:extended_text/extended_text.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../load_project/page/load_project_dialog.dart';
import '../common/navigation_drawer_option.dart';
import '../widget/navigation_drawer.dart';

class ProjectSelectorDrawer extends NavigationDrawer {
  const ProjectSelectorDrawer({super.key}) : super(NavigationDrawerTopOption.projectSelector);

  static const Widget _verticalSpacer = SizedBox(height: 4.0);

  @override
  String titleText(AppLocalizations loc) => loc.title_project_selector_drawer;

  @override
  List<Widget> headerChildren(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final projectLoaded = ref.watch(isProjectLoadedProvider);
    if (projectLoaded) {
      return [];
    }
    final colors = Theme.of(context).colorScheme;
    final nameStyle = TextStyle(fontWeight: FontWeight.w400, color: colors.onSurface);
    return [
      Text('(${loc.message_no_project_selected})', style: nameStyle),
    ];
  }

  @override
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final textButtonStyle = TextButton.styleFrom(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.normal),
    );
    final elevatedButtonStyle = ElevatedButton.styleFrom(
      onPrimary: Theme.of(context).colorScheme.onSecondaryContainer,
      primary: Theme.of(context).colorScheme.secondaryContainer,
      textStyle: const TextStyle(fontWeight: FontWeight.normal),
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

    return [
      _CloseProjectButton(style: textButtonStyle),
      const Divider(),
      _OpenProjectButton(style: textButtonStyle),
      _verticalSpacer,
      _RecentListWidget(textButtonStyle: textButtonStyle, elevatedButtonStyle: elevatedButtonStyle),
    ];
  }
}

class _CloseProjectButton extends ConsumerWidget {
  const _CloseProjectButton({required this.style});

  final ButtonStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectLoaded = ref.watch(isProjectLoadedProvider);
    final loc = AppLocalizations.of(context);
    return TextButton.icon(
      style: style,
      icon: const Icon(Icons.close),
      label: Text(loc.label_close_project),
      onPressed: projectLoaded ? () => _onPressed(ref.read) : null,
    );
  }

  void _onPressed(Reader read) => read(projectUsecaseProvider).closeProject();
}

class _OpenProjectButton extends ConsumerWidget {
  const _OpenProjectButton({required this.style});

  final ButtonStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    return TextButton.icon(
      style: style,
      icon: const Icon(Icons.folder_outlined),
      label: Text('${loc.label_open_project} ...'),
      onPressed: () => _onPressed(context, loc, ref.read),
    );
  }

  void _onPressed(BuildContext context, AppLocalizations loc, Reader read) async {
    final projectPath = await getDirectoryPath(confirmButtonText: loc.label_choose);
    if (projectPath == null) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => LoadProjectDialog(projectPath, loc),
    );
  }
}

class _RecentListWidget extends ConsumerWidget {
  const _RecentListWidget({required this.textButtonStyle, required this.elevatedButtonStyle});

  static final _showRecentProvider = StateProvider((_) => false);

  final ButtonStyle textButtonStyle;
  final ButtonStyle elevatedButtonStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showRecent = ref.watch(_showRecentProvider);
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    if (showRecent) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              children: [
                ElevatedButton.icon(
                  style: elevatedButtonStyle,
                  icon: const Icon(Icons.folder_special_outlined),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(loc.label_open_recent),
                      Icon(showRecent ? Icons.arrow_drop_down_circle_outlined : Icons.arrow_right),
                    ],
                  ),
                  onPressed: () => _toggleShowRecent(ref.read),
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: _recentList(context, ref, loc, colors),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return TextButton.icon(
      style: textButtonStyle,
      icon: const Icon(Icons.folder_special_outlined),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(loc.label_open_recent),
          const Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: Icon(Icons.arrow_right),
          ),
        ],
      ),
      onPressed: () => _toggleShowRecent(ref.read),
    );
  }

  List<Widget> _recentList(
      BuildContext context, WidgetRef ref, AppLocalizations loc, ColorScheme colors) {
    final recentList = ref.watch(recentProjectsProvider);
    final project = ref.watch(projectProvider);
    return [
      for (final recent in recentList)
        ListTile(
          hoverColor: recent == project ? Colors.transparent : colors.surfaceVariant,
          title: Text(
            recent.name,
            style: recent == project ? TextStyle(color: colors.onSurfaceVariant) : null,
          ),
          subtitle: ExtendedText(
            recent.path,
            maxLines: 1,
            overflowWidget: const TextOverflowWidget(
              position: TextOverflowPosition.start,
              child: Text('...'),
            ),
          ),
          onTap: () => _openRecent(context, ref.read, loc, recent),
        ),
    ];
  }

  void _openRecent(BuildContext context, Reader read, AppLocalizations loc, Project project) {
    if (read(projectProvider) == project) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.message_project_already_selected)),
      );
    } else {
      //read(projectProvider.notifier).state = project;
      _toggleShowRecent(read);
    }
  }

  void _toggleShowRecent(Reader read) =>
      read(_showRecentProvider.notifier).update((state) => !state);
}

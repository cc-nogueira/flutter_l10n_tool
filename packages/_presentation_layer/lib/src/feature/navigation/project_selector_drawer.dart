import 'package:_domain_layer/domain_layer.dart';
import 'package:extended_text/extended_text.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/translations.dart';

import '../project/widget/load_project_dialog.dart';
import 'navigation_drawer.dart';
import 'navigation_drawer_option.dart';

class ProjectSelectorDrawer extends NavigationDrawer {
  const ProjectSelectorDrawer({super.key}) : super(NavigationDrawerOption.projectSelector);

  static const Widget _verticalSpacer = SizedBox(height: 4.0);

  @override
  String titleText(Translations tr) => tr.title_project_selector_drawer;

  @override
  List<Widget> headerChildren(BuildContext context, WidgetRef ref, Translations tr) {
    final projectLoaded = ref.watch(isProjectLoadedProvider);
    if (projectLoaded) {
      return [];
    }
    final colors = Theme.of(context).colorScheme;
    final nameStyle = TextStyle(fontWeight: FontWeight.w400, color: colors.onSurface);
    return [
      const SizedBox(height: 12),
      Text('(${tr.message_no_project_selected})', style: nameStyle),
    ];
  }

  @override
  List<Widget> children(BuildContext context, WidgetRef ref, Translations tr) {
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
    final tr = Translations.of(context);
    return TextButton.icon(
      style: style,
      icon: const Icon(Icons.close),
      label: Text(tr.label_close_project),
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
    final tr = Translations.of(context);
    return TextButton.icon(
      style: style,
      icon: const Icon(Icons.folder_outlined),
      label: Text('${tr.label_open_project} ...'),
      onPressed: () => _onPressed(context, tr, ref.read),
    );
  }

  void _onPressed(BuildContext context, Translations tr, Reader read) async {
    final projectPath = await getDirectoryPath(confirmButtonText: tr.label_choose);
    if (projectPath == null) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => LoadProjectDialog(projectPath, tr),
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
    final tr = Translations.of(context);
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
                      Text(tr.label_open_recent),
                      Icon(showRecent ? Icons.arrow_drop_down_circle_outlined : Icons.arrow_right),
                    ],
                  ),
                  onPressed: () => _toggleShowRecent(ref.read),
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: _recentList(context, ref, tr, colors),
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
          Text(tr.label_open_recent),
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
      BuildContext context, WidgetRef ref, Translations tr, ColorScheme colors) {
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
          onTap: () => _openRecent(context, ref.read, tr, recent),
        ),
    ];
  }

  void _openRecent(BuildContext context, Reader read, Translations tr, Project project) {
    if (read(projectProvider) == project) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.message_project_already_selected)),
      );
    } else {
      //read(projectProvider.notifier).state = project;
      _toggleShowRecent(read);
    }
  }

  void _toggleShowRecent(Reader read) =>
      read(_showRecentProvider.notifier).update((state) => !state);
}

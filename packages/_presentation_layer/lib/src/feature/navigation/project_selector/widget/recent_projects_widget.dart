import 'package:_domain_layer/domain_layer.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

class RecentProjectsWidget extends ConsumerWidget {
  const RecentProjectsWidget({
    super.key,
    required this.textButtonStyle,
    required this.elevatedButtonStyle,
  });

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

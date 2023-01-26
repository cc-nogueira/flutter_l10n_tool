import 'package:_domain_layer/domain_layer.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../show_project_loading/page/show_project_loading_dialog.dart';

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
    return showRecent
        ? Expanded(child: _buildShowRecent(context, ref, loc))
        : _openRecentButton(ref, loc.label_open_recent, false);
  }

  Widget _openRecentButton(WidgetRef ref, String text, bool showRecent) => showRecent
      ? ElevatedButton.icon(
          style: elevatedButtonStyle,
          icon: const Icon(Icons.folder_special_outlined),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text),
              const Icon(Icons.arrow_drop_down_circle_outlined),
            ],
          ),
          onPressed: () => _toggleShowRecent(ref),
        )
      : TextButton.icon(
          style: textButtonStyle,
          icon: const Icon(Icons.folder_special_outlined),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text),
              const Padding(padding: EdgeInsets.only(right: 4.0), child: Icon(Icons.arrow_right)),
            ],
          ),
          onPressed: () => _toggleShowRecent(ref),
        );

  Widget _buildShowRecent(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
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
              _openRecentButton(ref, loc.label_open_recent, true),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: _recentList(context, constraints, ref, loc, colors),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _recentList(
    BuildContext context,
    BoxConstraints constraints,
    WidgetRef ref,
    AppLocalizations loc,
    ColorScheme colors,
  ) {
    final project = ref.watch(projectProvider);
    final recentList = ref.watch(recentProjectsProvider);
    return [
      for (final recent in recentList)
        _recent(context, constraints, ref, loc, colors, recent, recent.path == project.path),
    ];
  }

  Widget _recent(
    BuildContext context,
    BoxConstraints constraints,
    WidgetRef ref,
    AppLocalizations loc,
    ColorScheme colors,
    RecentProject recent,
    bool isCurrent,
  ) {
    const maxLines = 1;
    const paddingLeft = 16.0;
    const paddingRight = 8.0;

    final textTheme = Theme.of(context).textTheme;
    final subColor = isCurrent ? colors.secondary : textTheme.bodySmall!.color;
    final titleStyle = isCurrent ? TextStyle(color: colors.secondary) : null;
    final subStyle = textTheme.bodyMedium!.copyWith(color: subColor);
    final tile = ListTile(
      contentPadding: const EdgeInsets.only(left: paddingLeft, right: paddingRight),
      hoverColor: isCurrent ? Colors.transparent : colors.surfaceVariant,
      title: Text(recent.name, style: titleStyle),
      subtitle: ExtendedText(
        recent.path,
        maxLines: maxLines,
        style: subStyle,
        overflowWidget: const TextOverflowWidget(
          position: TextOverflowPosition.start,
          child: Text('...'),
        ),
      ),
      trailing: IconButton(
          onPressed: () => _removeRecentProject(ref, recent), icon: Icon(Icons.remove_circle_outline, color: subColor)),
      onTap: () => _openRecent(context, ref, loc, recent, isCurrent),
    );

    final maxSize = constraints.maxWidth - paddingLeft - paddingRight;
    final hasOverflow = _hasTextOverflow(recent.path, subStyle, maxSize, maxLines);
    return hasOverflow ? Tooltip(message: recent.path, child: tile) : tile;
  }

  bool _hasTextOverflow(String text, TextStyle style, double maxWidth, int maxLines) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  void _openRecent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
    RecentProject project,
    bool isCurrent,
  ) async {
    ref.read(projectUsecaseProvider).loadProject(projectPath: project.path);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ShowProjectLoadingDialog(),
    );
  }

  void _toggleShowRecent(WidgetRef ref) => ref.read(_showRecentProvider.notifier).update((state) => !state);

  void _removeRecentProject(WidgetRef ref, RecentProject value) =>
      ref.read(recentProjectsUsecaseProvider).remove(value);
}

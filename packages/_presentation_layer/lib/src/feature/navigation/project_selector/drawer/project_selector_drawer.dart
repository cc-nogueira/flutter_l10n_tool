import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../common/navigation_drawer_option.dart';
import '../../widget/navigation_drawer.dart';
import '../widget/close_project_button.dart';
import '../widget/open_project_button.dart';
import '../widget/recent_projects_widget.dart';

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
      CloseProjectButton(style: textButtonStyle),
      const Divider(),
      OpenProjectButton(style: textButtonStyle),
      _verticalSpacer,
      RecentProjectsWidget(
          textButtonStyle: textButtonStyle, elevatedButtonStyle: elevatedButtonStyle),
    ];
  }
}

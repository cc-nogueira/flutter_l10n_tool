import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/navigation/navigation_drawer_option.dart';
import '../../../common/widget/navigation_drawer.dart' as common;
import '../../../l10n/app_localizations.dart';
import '../widget/close_project_button.dart';
import '../widget/open_project_button.dart';
import '../widget/recent_projects_widget.dart';

class ProjectSelectorDrawer extends common.NavigationDrawer {
  const ProjectSelectorDrawer({super.key})
      : super(NavigationDrawerTopOption.projectSelector, bodyDependOnProjectLoaded: false);

  static const Widget _verticalSpacer = SizedBox(height: 4.0);

  @override
  String titleText(AppLocalizations loc) => loc.title_project_selector_drawer;

  @override
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final textButtonStyle = TextButton.styleFrom(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.normal),
    );
    final elevatedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      textStyle: const TextStyle(fontWeight: FontWeight.normal),
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

    return [
      CloseProjectButton(style: textButtonStyle),
      const Divider(),
      OpenProjectButton(style: textButtonStyle),
      _verticalSpacer,
      RecentProjectsWidget(textButtonStyle: textButtonStyle, elevatedButtonStyle: elevatedButtonStyle),
    ];
  }
}

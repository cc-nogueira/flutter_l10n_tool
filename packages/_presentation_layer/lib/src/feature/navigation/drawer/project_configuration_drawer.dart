import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../project/widget/configuration_form.dart';
import '../../project/widget/project_configuration_buttons.dart';
import '../../project/widget/project_configuration_toggle_buttons.dart';
import 'navigation_drawer.dart';
import 'navigation_drawer_option.dart';

class ProjectConfigurationDrawer extends NavigationDrawer {
  const ProjectConfigurationDrawer({super.key})
      : super(
          NavigationDrawerOption.configuration,
          childrenPadding: const EdgeInsets.only(left: 8.0),
        );

  @override
  String titleText(AppLocalizations loc) => loc.title_project_configuration_drawer;

  @override
  List<Widget> headerChildren(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final projectLoaded = ref.watch(isProjectLoadedProvider);
    if (projectLoaded) {
      return [];
    }
    final colors = Theme.of(context).colorScheme;
    final nameStyle = TextStyle(fontWeight: FontWeight.w400, color: colors.onSurface);
    return [
      const SizedBox(height: 12),
      Text('(${loc.message_no_project_selected})', style: nameStyle),
    ];
  }

  @override
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final projectLoaded = ref.watch(isProjectLoadedProvider);
    return [Expanded(child: _ProjectConfigurationWidget(projectLoaded: projectLoaded))];
  }
}

class _ProjectConfigurationWidget extends ConsumerWidget {
  _ProjectConfigurationWidget({required this.projectLoaded});

  final bool projectLoaded;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!projectLoaded) {
      return Container();
    }

    return ListView(
      padding: const EdgeInsets.only(left: 4.0, right: 12.0),
      children: [
        _configurationToggleButtons(),
        const SizedBox(height: 24),
        _configurationForm(),
        const SizedBox(height: 24),
        _configurationButtons(),
      ],
    );
  }

  Widget _configurationToggleButtons() => const ProjectConfigurationToggleButtons();

  Widget _configurationForm() => Form(
        key: _formKey,
        child: const ConfigurationForm(),
      );

  Widget _configurationButtons() => const ProjectConfigurationButtons();
}

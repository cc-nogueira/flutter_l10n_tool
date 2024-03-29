import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/navigation/navigation_drawer_option.dart';
import '../../../common/widget/form_mixin.dart';
import '../../../common/widget/navigation_drawer.dart' as common;
import '../../../l10n/app_localizations.dart';
import '../widget/configuration_buttons.dart';
import '../widget/configuration_form.dart';
import '../widget/configuration_toggle_buttons.dart';

class ProjectConfigurationDrawer extends common.NavigationDrawer {
  const ProjectConfigurationDrawer({super.key})
      : super(
          NavigationDrawerTopOption.configuration,
          childrenPadding: const EdgeInsets.only(left: 8.0),
        );

  @override
  String titleText(AppLocalizations loc) => loc.title_project_configuration_drawer;

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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0, right: 8.0),
          child: _configurationToggleButtons(),
        ),
        FormMixin.verticalSeparator,
        Expanded(
          child: ListView(
            primary: false,
            padding: const EdgeInsets.only(left: 4.0, right: 12.0),
            children: [
              _configurationForm(),
              const SizedBox(height: 24),
              _configurationButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _configurationToggleButtons() => const ConfigurationToggleButtons();

  Widget _configurationForm() => Form(
        key: _formKey,
        child: const ConfigurationForm(),
      );

  Widget _configurationButtons() => const ConfigurationButtons();
}

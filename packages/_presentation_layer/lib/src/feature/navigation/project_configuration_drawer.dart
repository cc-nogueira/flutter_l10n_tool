import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/translations.dart';
import '../project/widget/configuration_form.dart';
import 'navigation_drawer.dart';
import 'navigation_drawer_option.dart';

final _formConfigurationProvider = StateProvider<L10nConfiguration>((ref) {
  final actualConfiguration = ref.watch(projectConfigurationProvider);
  return actualConfiguration.copyWith();
});

class ProjectConfigurationDrawer extends NavigationDrawer {
  const ProjectConfigurationDrawer({super.key})
      : super(
          NavigationDrawerOption.configuration,
          padding: const EdgeInsets.only(left: 8.0),
        );

  @override
  String titleText(Translations tr) => tr.title_project_configuration_drawer;

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

    final isFromYamlFile =
        ref.watch(_formConfigurationProvider.select((conf) => conf.isFromYamlFile == true));
    return ListView(
      padding: const EdgeInsets.only(left: 4.0, right: 12.0),
      children: [
        Text(isFromYamlFile ? 'Configuration from l10n.yaml' : 'Default configuration'),
        const SizedBox(height: 24),
        _configurationForm(isFromYamlFile),
      ],
    );
  }

  Widget _configurationForm(bool isFromYamlFile) {
    return Form(
      key: _formKey,
      child: ConfigurationForm(_formConfigurationProvider, isFromYamlFile: isFromYamlFile),
    );
  }
}

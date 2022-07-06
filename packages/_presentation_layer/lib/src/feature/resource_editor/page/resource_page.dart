import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/message_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../widget/definition_widget.dart';
import '../widget/resource_bar.dart';
import '../widget/translation_widget.dart';

class ResourcePage extends ConsumerWidget {
  const ResourcePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final definition = ref.watch(selectedDefinitionProvider);
    final project = ref.watch(projectProvider);
    final translations = project.translations.values.toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (definition == null) Expanded(child: _noResourceSelected(context, loc)),
          if (definition != null) ...[
            const ResourceBar(),
            DefinitionWidget(definition),
            Expanded(
              child: ListView.builder(
                shrinkWrap: false,
                itemBuilder: (_, idx) => _itemBuilder(definition, translations[idx]),
                itemCount: translations.length,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _itemBuilder(ArbDefinition definition, ArbLocaleTranslations localeTranslations) =>
      TranslationWidget(
        localeTranslations.locale,
        definition,
        localeTranslations.translations[definition.key],
      );

  Widget _noResourceSelected(BuildContext context, AppLocalizations loc) {
    return const MessageWidget('No resource selected');
  }
}

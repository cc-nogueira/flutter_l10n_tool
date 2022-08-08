import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/message_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../../../provider/presentation_providers.dart';
import '../widget/definition_widget.dart';
import '../widget/resource_bar.dart';
import '../widget/translation_widget.dart';

class ResourcePage extends ConsumerWidget {
  const ResourcePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originalDefinition = ref.watch(selectedDefinitionProvider);
    if (originalDefinition == null) {
      final loc = AppLocalizations.of(context);
      return Padding(padding: const EdgeInsets.all(8.0), child: _noResourceSelected(context, loc));
    }
    return originalDefinition.map(
      placeholders: (def) => _PlaceholdersResourcePage(def),
      plural: (def) => _PluralResourcePage(def),
      select: (def) => _SelectResourcePage(def),
    );
  }

  Widget _noResourceSelected(BuildContext context, AppLocalizations loc) {
    return Column(
      children: const [
        ResourceBar(),
        Expanded(child: MessageWidget('No resource selected')),
      ],
    );
  }
}

abstract class _ResourcePage extends ConsumerWidget {
  const _ResourcePage();

  ArbDefinition get originalDefinition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDefinition =
        ref.watch(currentDefinitionsProvider.select((value) => value[originalDefinition]));
    final selectedTranslations = ref.watch(selectedLocaleTranslationsProvider);
    //final translations = ref.watch(projectProvider).translations.values.toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const ResourceBar(),
          definitionWidget(currentDefinition),
          Expanded(
            child: ListView.builder(
              shrinkWrap: false,
              itemBuilder: (_, idx) =>
                  _itemBuilder(originalDefinition, currentDefinition, selectedTranslations[idx]),
              itemCount: selectedTranslations.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget definitionWidget(ArbDefinition? current) => originalDefinition.map(
        placeholders: (original) => PlaceholdersDefinitionWidget(
          original: original,
          current: current as ArbPlaceholdersDefinition?,
        ),
        plural: (original) => PluralDefinitionWidget(
          original: original,
          current: current as ArbPluralDefinition?,
        ),
        select: (original) => SelectDefinitionWidget(
          original: original,
          current: current as ArbSelectDefinition?,
        ),
      );

  Widget _itemBuilder(
    ArbDefinition originalDefinition,
    ArbDefinition? currentDefinition,
    ArbLocaleTranslations localeTranslations,
  ) =>
      originalDefinition.map(
        placeholders: (original) => PlaceholdersTranslationWidget(
          localeTranslations.locale,
          originalDefinition: original,
          currentDefinition: currentDefinition as ArbPlaceholdersDefinition?,
          originalTranslation: localeTranslations.translations[originalDefinition.key]
              as ArbPlaceholdersTranslation?,
        ),
        plural: (original) => PluralTranslationWidget(
          localeTranslations.locale,
          originalDefinition: original,
          currentDefinition: currentDefinition as ArbPluralDefinition?,
          originalTranslation:
              localeTranslations.translations[originalDefinition.key] as ArbPluralTranslation?,
        ),
        select: (original) => SelectTranslationWidget(localeTranslations.locale,
            originalDefinition: original,
            currentDefinition: currentDefinition as ArbSelectDefinition?,
            originalTranslation:
                localeTranslations.translations[originalDefinition.key] as ArbSelectTranslation?),
      );
}

class _PlaceholdersResourcePage extends _ResourcePage {
  const _PlaceholdersResourcePage(this.originalDefinition);

  @override
  final ArbPlaceholdersDefinition originalDefinition;
}

class _PluralResourcePage extends _ResourcePage {
  const _PluralResourcePage(this.originalDefinition);

  @override
  final ArbPluralDefinition originalDefinition;
}

class _SelectResourcePage extends _ResourcePage {
  const _SelectResourcePage(this.originalDefinition);

  @override
  final ArbSelectDefinition originalDefinition;
}

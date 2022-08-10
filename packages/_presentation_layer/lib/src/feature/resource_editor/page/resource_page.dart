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
    if (ref.watch(editNewDefinitionProvider)) {
      return const _NewResourcePage();
    }
    final originalDefinition = ref.watch(selectedDefinitionProvider);
    if (originalDefinition == null) {
      return const _NoResouceSelectedPage();
    }
    return _ResourcePage(originalDefinition);
  }
}

class _ResourcePage<D extends ArbDefinition> extends ConsumerWidget with _NewResourceMixin {
  const _ResourcePage(this.originalDefinition);

  final D originalDefinition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDefinition =
        ref.watch(currentDefinitionsProvider.select((value) => value[originalDefinition])) as D?;
    final selectedTranslations = ref.watch(selectedLocaleTranslationsProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResourceBar(),
            DefinitionWidget<D>(original: originalDefinition, current: currentDefinition),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 72),
                shrinkWrap: false,
                itemBuilder: (_, idx) =>
                    _itemBuilder(originalDefinition, currentDefinition, selectedTranslations[idx]),
                itemCount: selectedTranslations.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _fab(ref.read),
    );
  }

  Widget? _fab(Reader read) => FloatingActionButton(
        onPressed: () => newResourceDefinition(read),
        child: const Icon(Icons.add),
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

class _NewResourcePage extends ConsumerWidget {
  const _NewResourcePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ResourceBar(),
          NewDefinitionWidget(),
        ],
      ),
    );
  }
}

class _NoResouceSelectedPage extends ConsumerWidget with _NewResourceMixin {
  const _NoResouceSelectedPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(padding: const EdgeInsets.all(8.0), child: _noResourceSelected(context, loc)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => newResourceDefinition(ref.read),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _noResourceSelected(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ResourceBar(),
        Expanded(child: MessageWidget('No resource selected')),
      ],
    );
  }
}

mixin _NewResourceMixin {
  void newResourceDefinition(Reader read) {
    final arbUsecase = read(arbUsecaseProvider);
    arbUsecase.editNewDefinition();
  }
}

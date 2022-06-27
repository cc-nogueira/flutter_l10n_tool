import 'package:riverpod/riverpod.dart';

import '../entity/project/arb_resource.dart';
import '../provider/providers.dart';

part 'notifier/being_edited_resource_notifier.dart';
part 'notifier/selected_resource_notifier.dart';

class ResourceUsecase {
  ResourceUsecase(this.read);

  final Reader read;

  void select(ArbResourceDefinition? resourceDefinition) {
    _selectedResourceNotifier()._select(resourceDefinition);
  }

  void clearSelection() {
    _selectedResourceNotifier()._clearSelection();
  }

  void editResource(ArbResourceDefinition resourceDefinition) {
    _beindEditedResourceDefinitionsNotifier()._edit(resourceDefinition);
  }

  void discardResourceDefinitionChanges(ArbResourceDefinition resourceDefinition) {
    _beindEditedResourceDefinitionsNotifier()._discardChanges(resourceDefinition);
  }

  void changeResource(ArbResource resource) {}

  void editTranslation(
    String locale,
    ArbResourceDefinition resourceDefinition,
    ArbResource translation,
  ) {
    _beingEditedTranslationsNotifier(locale)._edit(translation);
    _beingEditedResourcesNotifier()._add(resourceDefinition, translation);
  }

  void discardTranslationChanges(
    String locale,
    ArbResourceDefinition resourceDefinition,
    ArbResource translation,
  ) {
    _beingEditedTranslationsNotifier(locale)._discardChanges(translation);
    _beingEditedResourcesNotifier()._remove(resourceDefinition, translation);
  }

  SelectedResourceNotifier _selectedResourceNotifier() => read(selectedResourceProvider.notifier);

  BeingEditedResourcesNotifier _beingEditedResourcesNotifier() =>
      read(beingEditedResourcesProvider.notifier);

  BeingEditedResourceDefinitionsNotifier _beindEditedResourceDefinitionsNotifier() =>
      read(beingEditedResourceDefinitionsProvider.notifier);

  BeingEditedTranslationsNotifier _beingEditedTranslationsNotifier(String locale) =>
      read(beingEditedTranslationsProvider(locale).notifier);
}

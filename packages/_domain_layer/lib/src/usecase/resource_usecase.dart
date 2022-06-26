import 'package:riverpod/riverpod.dart';

import '../entity/project/arb_resource.dart';
import '../provider/providers.dart';

part 'notifier/being_edited_resource_notifier.dart';
part 'notifier/selected_resource_notifier.dart';

class ResourceUsecase {
  ResourceUsecase(this.read);

  final Reader read;

  void select(ArbResourceDefinition? resourceDefinition) =>
      read(selectedResourceProvider.notifier)._select(resourceDefinition);

  void clearSelection() => read(selectedResourceProvider.notifier)._clearSelection();

  void editResource(ArbResourceDefinition resourceDefinition) {
    read(beingEditedResourceDefinitionsProvider.notifier)._edit(resourceDefinition);
  }

  void discardResourceDefinitionChanges(ArbResourceDefinition resourceDefinition) {
    read(beingEditedResourceDefinitionsProvider.notifier)._discardChanges(resourceDefinition);
  }

  void changeResource(ArbResource resource) {}

  void editTranslation(
      String locale, ArbResourceDefinition resourceDefinition, ArbResource translation) {
    read(beingEditedTranslationsProvider(locale).notifier)._edit(translation);
    read(beingEditedResourcesProvider.notifier)._add(resourceDefinition, translation);
  }

  void discardTranslationChanges(
      String locale, ArbResourceDefinition resourceDefinition, ArbResource translation) {
    read(beingEditedTranslationsProvider(locale).notifier)._discardChanges(translation);
    read(beingEditedResourcesProvider.notifier)._remove(resourceDefinition, translation);
  }
}

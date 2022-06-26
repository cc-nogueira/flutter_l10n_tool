part of '../resource_usecase.dart';

class BeingEditedResourcesNotifier
    extends StateNotifier<Map<ArbResourceDefinition, List<ArbResource>>> {
  BeingEditedResourcesNotifier() : super({});

  void _add(ArbResourceDefinition resourceDefinition, ArbResource translation) {
    final translationsBeingEdited = state[resourceDefinition] ?? <ArbResource>[];
    translationsBeingEdited.add(translation);
    state[resourceDefinition] = translationsBeingEdited;
    _updateState();
  }

  void _remove(ArbResourceDefinition resourceDefinition, ArbResource translation) {
    final translationsBeingEdited = state[resourceDefinition];
    if (translationsBeingEdited != null) {
      translationsBeingEdited.remove(translation);
      if (translationsBeingEdited.isEmpty) {
        state.remove(resourceDefinition);
      }
    }
    _updateState();
  }

  void _updateState() => state = state;

  @override
  bool updateShouldNotify(old, current) => true;
}

abstract class BeingEditedNotifier<T> extends StateNotifier<Map<T, T>> {
  BeingEditedNotifier() : super({});

  T? beingEdited(T key) => state[key];

  void _edit(T element) {
    state[element] = element;
    _updateState();
  }

  void _discardChanges(T element) {
    final value = state.remove(element);
    if (value != null) {
      _updateState();
    }
  }

  void _updateState() => state = state;

  @override
  bool updateShouldNotify(old, current) => true;
}

class BeingEditedResourceDefinitionsNotifier extends BeingEditedNotifier<ArbResourceDefinition> {}

class BeingEditedTranslationsNotifier extends BeingEditedNotifier<ArbResource> {
  BeingEditedTranslationsNotifier(this.locale);

  final String locale;
}

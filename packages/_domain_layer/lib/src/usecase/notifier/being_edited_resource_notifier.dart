part of '../resource_usecase.dart';

/// Resource usecase notifier for resources being edited.
///
/// This is a public notifier acessible through the [beingEditedResourcesProvider] variable.
///
/// Changes are only possible through the [ResourceUsecase] (private methods).
class BeingEditedResourcesNotifier
    extends StateNotifier<Map<ArbResourceDefinition, List<ArbResource>>> {
  /// Constructor that initialized the state to an empty map.
  BeingEditedResourcesNotifier() : super({});

  /// Private method to register that a translation is being edited for specific resourceDefinition.
  /// This way it is possible to find out whether any translation is being edited for a resourceDefinition.
  ///
  /// This method is only acessible through the [ResourceUsecase] API.
  void _add(ArbResourceDefinition resourceDefinition, ArbResource translation) {
    final translationsBeingEdited = state[resourceDefinition] ?? <ArbResource>[];
    translationsBeingEdited.add(translation);
    state[resourceDefinition] = translationsBeingEdited;
    _updateState();
  }

  /// Private method to register that a translation for specific resourceDefinition is not being edited anymore.
  /// This way it is possible to find out whether any translation is being edited for a resourceDefinition.
  ///
  /// This method is only acessible through the [ResourceUsecase] API.
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

  /// Internal - updates the state (with the same variable) to trigger state change notification.
  ///
  /// In this notifier implementation state is mutable, it is a map that ischanged directly to avoid
  /// repeated recreation of this state mapping for every resorce change registration.
  void _updateState() => state = state;

  /// Internal - since the state is a map that is modified directly we define that updateShouldNotify
  /// always.
  @override
  bool updateShouldNotify(old, current) => true;
}

/// Abstract class for resource usecase notifiers for resource definitions and translations being edited.
///
/// It is a provider that maps the original resource to its currently edited value.
/// Exposes private methods to edit a resource and discard changes.
///
/// State changes are performed on the state variable itself, thus be carefull to not rely on immutable
/// states.
///
/// See [BeingEditedResourceDefinitionsNotifier] and [BeingEditedTranslationsNotifier] subclasses bellow.
abstract class BeingEditedNotifier<T> extends StateNotifier<Map<T, T>> {
  /// Constructor that initialized the state to an empty map.
  BeingEditedNotifier() : super({});

  /// Private method to register that an element is being edited.
  ///
  /// This method is only acessible through the [ResourceUsecase] API.
  void _edit(T element) {
    state[element] = element;
    _updateState();
  }

  /// Private method to register that an element is not being edited anymore.
  ///
  /// This method is only acessible through the [ResourceUsecase] API.
  void _discardChanges(T element) {
    final value = state.remove(element);
    if (value != null) {
      _updateState();
    }
  }

  /// Internal - updates the state (with the same variable) to trigger state change notification.
  ///
  /// In this notifier implementation state is mutable, it is a map that ischanged directly to avoid
  /// repeated recreation of this state mapping for every change.
  void _updateState() => state = state;

  /// Internal - since the state is a map that is modified directly we define that updateShouldNotify
  /// always.
  @override
  bool updateShouldNotify(old, current) => true;
}

/// Resource usecase notifier for resource definitions being edited.
///
/// This is a public notifier acessible through the [beingEditedResourceDefinitionsProvider] variable.
///
/// Changes are only possible through the [ResourceUsecase] (private methods).
class BeingEditedResourceDefinitionsNotifier extends BeingEditedNotifier<ArbResourceDefinition> {}

/// Resource usecase notifier for resource translations being edited for a language.
///
/// This is a public notifier acessible through the [beingEditedTranslationsProvider] family
/// provider variable. It is thus a collection of providers managing translations being edited for
/// each language.
///
/// Changes are only possible through the [ResourceUsecase] (private methods).
class BeingEditedTranslationsNotifier extends BeingEditedNotifier<ArbResource> {
  BeingEditedTranslationsNotifier(this.locale);

  /// The locale of each provider in this family.
  final String locale;
}

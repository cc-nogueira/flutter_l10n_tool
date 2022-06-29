part of '../arb_usecase.dart';

/// Arb usecase notifier for definitions and translations being edited.
///
/// This is a public notifier acessible through the [beingEditedTranslationsProvider] variable.
///
/// Changes are only possible through the [ArbUsecase] (private methods).
class BeingEditedTranslationsNotifier
    extends StateNotifier<Map<ArbDefinition, List<ArbTranslation>>> {
  /// Constructor that initialized the state to an empty map.
  BeingEditedTranslationsNotifier() : super({});

  /// Private method to register that a translation is being edited for specific definition.
  /// This way it is possible to find out whether any translation is being edited for a definition.
  ///
  /// This method is only acessible through the [ArbUsecase] API.
  void _add(ArbDefinition definition, ArbTranslation translation) {
    final translationsBeingEdited = state[definition] ?? <ArbTranslation>[];
    translationsBeingEdited.add(translation);
    state[definition] = translationsBeingEdited;
    _updateState();
  }

  /// Private method to register that a translation for specific definition is not being edited anymore.
  /// This way it is possible to find out whether any translation is being edited for a definition.
  ///
  /// This method is only acessible through the [ArbUsecase] API.
  void _remove(ArbDefinition definition, ArbTranslation translation) {
    final translationsBeingEdited = state[definition];
    if (translationsBeingEdited != null) {
      translationsBeingEdited.remove(translation);
      if (translationsBeingEdited.isEmpty) {
        state.remove(definition);
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

/// Abstract class for Arb usecase notifiers for definitions and translations being edited.
///
/// It is a provider that maps the original definition to its currently edited value.
/// Exposes private methods to edit and discard changes.
///
/// State changes are performed on the state variable itself, thus be carefull to not rely on immutable
/// states.
///
/// See [BeingEditedDefinitionsNotifier] and [BeingEditedTranslationsForLanguageNotifier] subclasses bellow.
abstract class BeingEditedNotifier<T> extends StateNotifier<Map<T, T>> {
  /// Constructor that initialized the state to an empty map.
  BeingEditedNotifier() : super({});

  /// Private method to register that an element is being edited.
  ///
  /// This method is only acessible through the [ArbUsecase] API.
  void _edit(T element) {
    state[element] = element;
    _updateState();
  }

  /// Private method to register that an element is not being edited anymore.
  ///
  /// This method is only acessible through the [ArbUsecase] API.
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

/// Arb usecase notifier for definitions being edited.
///
/// This is a public notifier acessible through the [beingEditedDefinitionsProvider] variable.
///
/// Changes are only possible through the [ArbUsecase] (private methods).
class BeingEditedDefinitionsNotifier extends BeingEditedNotifier<ArbDefinition> {}

/// Arb usecase notifier for translations being edited for a language.
///
/// This is a public notifier acessible through the [beingEditedTranslationsForLanguageProvider] family
/// provider variable. It is thus a collection of providers managing translations being edited for
/// each language.
///
/// Changes are only possible through the [ArbUsecase] (private methods).
class BeingEditedTranslationsForLanguageNotifier extends BeingEditedNotifier<ArbTranslation> {
  BeingEditedTranslationsForLanguageNotifier(this.locale);

  /// The locale of each provider in this family.
  final String locale;
}

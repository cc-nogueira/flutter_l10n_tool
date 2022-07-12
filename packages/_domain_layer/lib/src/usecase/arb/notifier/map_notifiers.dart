part of '../arb_usecase.dart';

abstract class MapNotifier<T, U> extends StateNotifier<Map<T, U>> {
  /// Constructor that initialized the state to an empty map.
  MapNotifier() : super({});

  /// State returns an unmodifiable view of this internally mutable state.
  @override
  UnmodifiableMapView<T, U> get state => UnmodifiableMapView(super.state);

  void _edit(T key, U value) {
    super.state[key] = value;
    _updateState();
  }

  void _discardChanges(T key) {
    final value = super.state.remove(key);
    if (value != null) {
      _updateState();
    }
  }

  /// Internal - updates the state (with the same variable) to trigger state change notification.
  ///
  /// In this notifier implementation state is mutable, it is a map that only modified internally
  /// avoiding repeated recreation for every change.
  void _updateState() => state = super.state;

  /// Internal - since the state is a map that is modified directly we define that updateShouldNotify
  /// always.
  @override
  bool updateShouldNotify(old, current) => true;
}

abstract class MapOneToManyNotifier<T, U> extends StateNotifier<Map<T, Set<U>>> {
  /// Constructor that initialized the state to an empty map.
  MapOneToManyNotifier() : super({});

  void _add(T key, U value) {
    final values = state[key] ?? <U>{};
    values.add(value);
    state[key] = values;
    _updateState();
  }

  void _remove(T key, U value) {
    final values = state[key];
    if (values != null) {
      values.remove(value);
      if (values.isEmpty) {
        state.remove(key);
      }
      _updateState();
    }
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

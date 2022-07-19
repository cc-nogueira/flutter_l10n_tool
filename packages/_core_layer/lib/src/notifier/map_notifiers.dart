import 'dart:collection';

import 'package:riverpod/riverpod.dart';

/// A Riverpod StateNotifier for a map of key values.
///
/// This state notifier will maintain the same state object through its lifetime, only updating
/// map entries.
///
/// The state method is overriden to return un UnmodifiableMapView of my current state.
class MapNotifier<T, U> extends StateNotifier<Map<T, U>> {
  /// Constructor that initialized the state to an empty map.
  MapNotifier() : super({});

  /// State returns an unmodifiable view of this internally mutable state.
  @override
  UnmodifiableMapView<T, U> get state => UnmodifiableMapView(super.state);

  /// Update the map registering a value for a key.
  ///
  /// If the key was already in the map it will be updated to have a new value.
  /// If the key is new it will be inserted.
  ///
  /// Then it will trigger state change notification.
  void update(T key, U value) {
    super.state[key] = value;
    _updateState();
  }

  /// Removes a key from this map.
  ///
  /// If the key exists it will be removed and this will trigger a state change notification.
  /// If the key does not exist in the map nothing will happen.
  void remove(T key) {
    final value = super.state.remove(key);
    if (value != null) {
      _updateState();
    }
  }

  /// Internal - updates the state (with the same variable) to trigger state change notification.
  ///
  /// In this notifier implementation state is mutable, it is a map modified only internally.
  /// This map is ever reused, avoiding repeated recreation for every change.
  void _updateState() => state = super.state;

  /// Internal - since the state is a map that is modified directly maintaining the same object
  /// reference, this method returs always true to always trigger state change notifications.
  @override
  bool updateShouldNotify(old, current) => true;
}

/// A Riverpod StateNotifier for a map of key to a set of values.
///
/// This state notifier will maintain the same state object through its lifetime, only updating
/// map entries.
///
/// The state method is overriden to return un UnmodifiableMapView of my current state.
class MapOneToManyNotifier<T, U> extends StateNotifier<Map<T, Set<U>>> {
  /// Constructor that initialized the state to an empty map.
  MapOneToManyNotifier() : super({});

  /// State returns an unmodifiable view of this internally mutable state.
  @override
  UnmodifiableMapView<T, Set<U>> get state => UnmodifiableMapView(super.state);

  /// Adds a value to the set associated to this key.
  ///
  /// If the key already exists it will add the value its correspondign set.
  /// if the key does not exist it will be inserted with a new set containing the given value.
  ///
  /// Either case it will trigger state change notification.
  void add(T key, U value) {
    final values = state[key] ?? <U>{};
    values.add(value);
    state[key] = values;
    _updateState();
  }

  /// Removes a value from the set of values for the given key.
  ///
  /// If the key already existis and the set contains this value then it will be removed and will
  /// trigger a state change notification.
  ///
  /// If the key does not exist or if its set does not contain the given value then nothing happens.
  void remove(T key, U value) {
    final values = state[key];
    if (values != null) {
      final removed = values.remove(value);
      if (values.isEmpty) {
        state.remove(key);
      }
      if (removed) {
        _updateState();
      }
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

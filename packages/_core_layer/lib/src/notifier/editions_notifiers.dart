import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

/// This state object shares its internal map between instances.
///
/// Creating an ofspring element with copyWith or copyWithout will change the original
/// content and create a "soft" copy.
///
/// This is only useful to avoid constant map recreation kwowing the original value is always discarded.
/// It is also important that these changing methods are private to its Notifier owner.
///
/// The key idea is to create a new state object with minimum computation and deliver a new state that
/// compares different to the original and is internally the same.
class EditionsState<K, V> {
  EditionsState([Map<K, V>? map]) : _map = map ?? {};

  /// Internal map of editions
  final Map<K, V> _map;

  /// Getter for the value being edited for a key.
  ///
  /// Return the value being edited or null if none is found for the given key.
  V? operator [](K key) => _map[key];

  /// Test if editions contains the given key.
  bool containsKey(K key) => _map.containsKey(key);

  /// Internal - create a new state object sharing the internal editions map including the given
  /// value associated to the given key.
  ///
  /// This method modifies the receiver and creates a new [EditionState] with the same content.
  /// The key idea is to create a new state object with minimum overhead adn deliver a new state that
  /// compares different to the original while being internally equivalent.
  ///
  /// This is only useful/safe for a caller that discards the original state and will only be available
  /// to the owning Notifier.
  @internal
  EditionsState<K, V> stateWith(K key, V value) {
    _map[key] = value;
    return EditionsState(_map);
  }

  /// Internal - returns a state object that does not contain the given key.
  ///
  /// If the receiver does not contain such key it will returned without modification.
  ///
  /// If the receiver does contain the key this method will return a new [EditionState] sharing the
  /// internal editions map now without the given key. In this case this method modifies the receiver.
  ///
  /// The key idea is to create a new state object with minimum overhead adn deliver a new state that
  /// compares different to the original while being internally equivalent.
  ///
  /// This is only useful/safe for a caller that discards the original state and will only be available
  /// to the owning Notifier.
  @internal
  EditionsState<K, V> stateWithout(K key) {
    final value = _map.remove(key);
    if (value == null) {
      return this;
    }
    return EditionsState(_map);
  }
}

/// A Riverpod StateNotifier for a map edition of key values.
///
/// This state notifier uses a state object that resuses the internal map of key values while
/// comparing differently to trigger change notifications.
///
/// This state also protects unwanted map operations on its internal map.
class EditionsNotifier<K, V> extends StateNotifier<EditionsState<K, V>> {
  /// Constructor that initialized to an empty state.
  EditionsNotifier() : super(EditionsState<K, V>());

  /// Update the state registering a value for a key.
  ///
  /// If the key was already in the state map it will be updated to have a new value.
  /// If the key is new it will be inserted.
  void update(K key, V value) {
    state = state.stateWith(key, value);
  }

  /// Removes a key from the state map.
  ///
  /// If the key exists it will be removed and this will trigger a state change notification.
  /// If the key does not exist in the map nothing will happen.
  void remove(K key) {
    state = state.stateWithout(key);
  }
}

/// This state object shares its internal map between instances.
///
/// Creating an ofspring element with copyWith or copyWithout will change the original
/// content and create a "soft" copy.
///
/// This is only useful to avoid constant map recreation kwowing the original value is always discarded.
/// It is also important that these changing methods are private to its Notifier owner.
///
/// The key idea is to create a new state object with minimum computation and deliver a new state that
/// compares different to the original and is internally the same.
class EditionsOneToManyState<K, V> {
  EditionsOneToManyState([Map<K, Set<V>>? map]) : _map = map ?? {};

  /// Internal map of editions
  final Map<K, Set<V>> _map;

  /// Getter for the set of values being edited for a key.
  ///
  /// Return an UnmodifiableSetView of values being edited or null if none is found for the given key.
  UnmodifiableSetView<V>? operator [](K key) {
    final values = _map[key];
    if (values == null) {
      return null;
    }
    return UnmodifiableSetView(values);
  }

  /// Test if the internal map contains editions for the given key.
  bool containsKey(K key) => _map.containsKey(key);

  /// Internal - create a new state object sharing the internal editions map including the given
  /// value associated to the given key.
  ///
  /// This method modifies the receiver and creates a new [EditionState] with the same content.
  /// The key idea is to create a new state object with minimum overhead adn deliver a new state that
  /// compares different to the original while being internally equivalent.
  ///
  /// This is only useful/safe for a caller that discards the original state and will only be available
  /// to the owning Notifier.
  @internal
  EditionsOneToManyState<K, V> stateWith(K key, V value) {
    final values = _map[key] ?? <V>{};
    values.add(value);
    _map[key] = values;
    return EditionsOneToManyState(_map);
  }

  /// Internal - returns a state object that does not contain the given value for a key.
  ///
  /// If the receiver does not contain such value for a key it will returned without modification.
  ///
  /// If the receiver does contain the value for that key this method will return a new [EditionState]
  /// sharing the internal editions map now without the given value for that key. In this case this
  /// method modifies the receiver.
  /// If the set of values for a key becomes empty after this removal then the whole key will be
  /// removed from the map. Thus the map will never contain values that are empty for a key.
  ///
  /// The key idea is to create a new state object with minimum overhead adn deliver a new state that
  /// compares different to the original while being internally equivalent.
  ///
  /// This is only useful/safe for a caller that discards the original state and will only be available
  /// to the owning Notifier.
  @internal
  EditionsOneToManyState<K, V> stateWithout(K key, V value) {
    final values = _map[key];
    if (values == null) {
      return this;
    }
    final removed = values.remove(value);
    if (!removed) {
      return this;
    }
    if (values.isEmpty) {
      _map.remove(key);
    }
    return EditionsOneToManyState(_map);
  }
}

/// A Riverpod StateNotifier for a map of key to a set of values.
///
/// This state notifier will maintain the same state object through its lifetime, only updating
/// map entries.
///
/// The state method is overriden to return un UnmodifiableMapView of my current state.
class EditionsOneToManyNotifier<K, V> extends StateNotifier<EditionsOneToManyState<K, V>> {
  /// Constructor that initialized to an empty state.
  EditionsOneToManyNotifier() : super(EditionsOneToManyState());

  /// Adds a value to the set associated to this key.
  ///
  /// If the key already exists it will add the value its correspondign set.
  /// if the key does not exist it will be inserted with a new set containing the given value.
  ///
  /// Either case it will trigger state change notification.
  void add(K key, V value) {
    state = state.stateWith(key, value);
  }

  /// Removes a value from the set of values for the given key.
  ///
  /// If the key already existis and the set contains this value then it will be removed and will
  /// trigger a state change notification.
  ///
  /// If the key does not exist or if its set does not contain the given value then nothing happens.
  void remove(K key, V value) {
    state = state.stateWithout(key, value);
  }
}

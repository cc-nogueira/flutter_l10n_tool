import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

/// This state object shares its internal set between instances.
///
/// Creating an offspring element with copyWith or copyWithout will change the original
/// content and create a "soft" copy.
///
/// This is only useful to avoid constant set recreation kwowing the original value is always discarded.
/// It is also important that these changing methods are private to its Notifier owner.
///
/// The key idea is to create a new state object with minimum computation and deliver a new state that
/// compares different to the original and is internally the same.
class SetState<T> with IterableMixin {
  SetState([Set<T>? values]) : _set = values ?? {};

  /// Internal set of values
  final Set<T> _set;

  @override
  Iterator<T> get iterator => _set.iterator;

  @override
  int get length => _set.length;

  /// Test if contains the given value.
  @override
  bool contains(Object? value) => _set.contains(value);

  /// Internal - create a new state object sharing the internal set including the given
  /// value.
  ///
  /// If the receiver alerady contains the value it will returned without modification.
  ///
  /// This method modifies the receiver and creates a new [SetState] with the same content.
  /// The key idea is to create a new state object with minimum overhead adn deliver a new state that
  /// compares different to the original while being internally equivalent.
  ///
  /// This is only useful/safe for a caller that discards the original state and will only be available
  /// to the owning Notifier.
  @internal
  SetState<T> stateWith(T value) {
    if (_set.add(value)) {
      return SetState(_set);
    }
    return this;
  }

  /// Internal - returns a state object sharing the internal set that does not contain the given key.
  ///
  /// If the receiver does not contain such key it will returned without modification.
  ///
  /// If the receiver does contain the key this method will return a new [SetState] sharing the
  /// internal set now without the given key. In this case this method modifies the receiver.
  ///
  /// The key idea is to create a new state object with minimum overhead adn deliver a new state that
  /// compares different to the original while being internally equivalent.
  ///
  /// This is only useful/safe for a caller that discards the original state and will only be available
  /// to the owning Notifier.
  @internal
  SetState<T> stateWithout(T value) {
    if (_set.remove(value)) {
      return SetState(_set);
    }
    return this;
  }
}

/// A Riverpod StateNotifier for a set of values.
///
/// This state notifier uses a state object that resuses the internal set of values while
/// comparing differently to trigger change notifications.
///
/// This state also protects unwanted set operations on its internal set.
class SetNotifier<T> extends StateNotifier<SetState<T>> {
  /// Constructor that initialized to an empty state.
  SetNotifier() : super(SetState<T>());

  /// Update the state adding a value.
  ///
  /// If the value alerady exists in the set then nothing will happen.
  /// If the value is new then it will be added and  his will trigger a state change notification.
  void add(T value) {
    state = state.stateWith(value);
  }

  /// Removes a value from the state set.
  ///
  /// If the value exists it will be removed and this will trigger a state change notification.
  /// If the value does not exist in the map nothing will happen.
  void remove(T value) {
    state = state.stateWithout(value);
  }
}

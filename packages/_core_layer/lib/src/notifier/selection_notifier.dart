import 'package:riverpod/riverpod.dart';

/// Selection notifier.
class SelectionNotifier<T> extends StateNotifier<T?> {
  /// Constructor that initializes the state to null (no selection).
  SelectionNotifier() : super(null);

  /// Change the current selection.
  void select(T? definition) => state = definition;

  /// Toggle the current selection with a value.
  ///
  /// It will change to a value if it is not already selected.
  /// It will deselect it if it is already selected.
  void toggle(T? definition) {
    if (state == definition) {
      state = null;
    } else {
      state = definition;
    }
  }

  /// Clear the current selection.
  void clear() => state = null;
}

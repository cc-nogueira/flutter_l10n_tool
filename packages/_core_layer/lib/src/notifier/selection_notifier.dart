import 'package:riverpod/riverpod.dart';

/// A Riverpod StateNotifier to manage a single selection value or null.
///
/// It provides methods to select, toggleSelect and clearSelection.
class SelectionNotifier<T> extends StateNotifier<T?> {
  /// Constructor that initializes the state to null (no selection).
  SelectionNotifier() : super(null);

  /// Change the current selection.
  void select(T? definition) => state = definition;

  /// Toggle the current selection with a value.
  ///
  /// It will change to a value if it is not already selected.
  /// It will deselect it if it is already selected.
  void toggleSelect(T? definition) {
    if (state == definition) {
      state = null;
    } else {
      state = definition;
    }
  }

  /// Clear the current selection.
  void clearSelection() => state = null;
}

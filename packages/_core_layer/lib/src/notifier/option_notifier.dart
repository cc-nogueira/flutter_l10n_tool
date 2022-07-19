import 'package:riverpod/riverpod.dart';

/// A Riverpod StateNofier to store an option.
///
/// It is the most simple StateNotifier possible.
/// Provides a public setter.
///
/// The getter is the @protected [state] method and should be accessed through a Riverpod Provider.
class OptionNotifier<T> extends StateNotifier<T> {
  /// Creates a OptionNotifier with a initial value.
  OptionNotifier(super.state);

  /// Set the current option.
  set option(T value) => state = value;
}

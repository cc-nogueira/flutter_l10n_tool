import 'package:riverpod/riverpod.dart';

/// Option notifier.
class OptionNotifier<T> extends StateNotifier<T> {
  OptionNotifier(super.state);

  /// Set the current option.
  set option(T value) => state = value;
}

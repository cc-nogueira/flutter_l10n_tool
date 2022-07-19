mixin ArbKeyMixin {
  String get key;

  /// Value of key must conform to /[_a-zA-z]\w*/ and will never contain spaces.
  bool get hasKey => key.isNotEmpty;
}

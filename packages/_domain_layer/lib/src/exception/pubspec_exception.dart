enum PubspecExceptionType {
  missing,
  dependency,
}

class PubspecException implements Exception {
  const PubspecException(this.type);
  final PubspecExceptionType type;
}

class MissingPubspecException extends PubspecException {
  const MissingPubspecException() : super(PubspecExceptionType.missing);
}

enum DependencyErrorType {
  missing,
  incomplete,
}

class DependencyException extends PubspecException {
  const DependencyException({required this.depName, required this.error})
      : super(PubspecExceptionType.dependency);

  factory DependencyException.missing(String depName) =>
      DependencyException(depName: depName, error: DependencyErrorType.missing);

  factory DependencyException.incomplete(String depName) =>
      DependencyException(depName: depName, error: DependencyErrorType.incomplete);

  final DependencyErrorType error;
  final String depName;

  bool get isMissing => error == DependencyErrorType.missing;
  bool get isIncomplete => error == DependencyErrorType.incomplete;

  @override
  String toString() {
    if (isMissing) {
      return 'Pubspec is missing the "$depName" dependency';
    } else {
      return 'Pubspec dependency "$depName" is incomplete';
    }
  }
}

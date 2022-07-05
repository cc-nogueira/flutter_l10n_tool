import 'package:flutter/material.dart';

import 'l10n_exception.dart';

abstract class L10nPubspecException extends L10nException {
  const L10nPubspecException();
}

class L10nMissingPubspecException extends L10nPubspecException {
  const L10nMissingPubspecException();

  @override
  String message(BuildContext context) => loc(context).error_missing_pubspec;
}

class L10nMissingDependencyException extends L10nPubspecException {
  const L10nMissingDependencyException(
    this.name, {
    required this.fixActionLabel,
    required this.fixActionDescription,
    required this.fixActionCallback,
    required this.fixActionInfo,
  });

  final String name;
  final String fixActionLabel;
  final String fixActionDescription;
  final String fixActionInfo;
  final L10nExceptionCallback fixActionCallback;

  @override
  String message(BuildContext context) => loc(context).error_missing_pubspec_dependency(name);
}

class L10nIncompleteDependencyException extends L10nPubspecException {
  const L10nIncompleteDependencyException(this.name);

  final String name;

  @override
  String message(BuildContext context) => loc(context).error_incomplete_pubspec_dependency(name);
}

class L10nAddDependencyError extends L10nPubspecException {
  L10nAddDependencyError(this.name);

  final String name;

  @override
  String message(BuildContext context) => loc(context).error_add_dependency(name);
}

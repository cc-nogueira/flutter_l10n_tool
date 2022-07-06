import 'package:flutter/material.dart';

import 'l10n_exception.dart';
import 'l10n_pubspec_exception.dart';

class L10nAddDependencyError extends L10nPubspecException {
  L10nAddDependencyError(this.name);

  final String name;

  @override
  String message(BuildContext context) => loc(context).error_add_dependency(name);
}

class L10nCreateFolderError extends L10nException {
  L10nCreateFolderError(this.name);

  final String name;

  @override
  String message(BuildContext context) => loc(context).error_create_folder(name);
}

class L10nCreateTemplateFileError extends L10nException {
  L10nCreateTemplateFileError(this.name);

  final String name;

  @override
  String message(BuildContext context) => loc(context).error_create_template_file(name);
}

class L10nCreateTemplateFileWithoutLocaleSufixError extends L10nException {
  L10nCreateTemplateFileWithoutLocaleSufixError(this.name);

  final String name;

  @override
  String message(BuildContext context) =>
      loc(context).error_create_template_file_without_locale_sufix(name);
}

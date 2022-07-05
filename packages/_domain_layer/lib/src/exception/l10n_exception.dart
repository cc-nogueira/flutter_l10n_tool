import 'package:flutter/material.dart';

import '../l10n/domain_localizations.dart';
import '../l10n/domain_localizations_en.dart';

typedef L10nExceptionCallback = Future<void> Function();

class L10nException implements Exception {
  const L10nException();

  DomainLocalizations loc(BuildContext context) =>
      DomainLocalizations.of(context) ?? DomainLocalizationsEn();

  String message(BuildContext context) => loc(context).error_l10n;
}

class L10nInvalidConfigurationFileException extends L10nException {
  const L10nInvalidConfigurationFileException();

  @override
  String message(BuildContext context) => loc(context).error_invalid_configuration_file;
}

class L10nMissingArbFolderException extends L10nException {
  const L10nMissingArbFolderException(
    this.path, {
    required this.fixActionLabel,
    required this.fixActionDescription,
    required this.fixActionCallback,
    required this.fixActionInfo,
  });

  final String path;
  final String fixActionLabel;
  final String fixActionDescription;
  final String fixActionInfo;
  final L10nExceptionCallback fixActionCallback;
  @override
  String message(BuildContext context) => loc(context).error_missing_arb_folder(path);
}

class L10nMissingArbTemplateFileException extends L10nException {
  const L10nMissingArbTemplateFileException(this.path);
  final String path;

  @override
  String message(BuildContext context) => loc(context).error_missing_arb_template_file(path);
}

class L10nArbFileFormatException extends L10nException {
  const L10nArbFileFormatException(this.name);
  final String name;

  @override
  String message(BuildContext context) => loc(context).error_invalid_arb_file_format(name);
}

class L10nFileMissingLocaleException extends L10nException {
  const L10nFileMissingLocaleException(this.name);
  final String name;

  @override
  String message(BuildContext context) => loc(context).error_locale_specification(name);
}

class L10nMultipleFilesWithSameLocationException extends L10nException {
  const L10nMultipleFilesWithSameLocationException(this.locale);
  final String locale;

  @override
  String message(BuildContext context) =>
      loc(context).error_multiple_files_with_same_locale(locale);
}

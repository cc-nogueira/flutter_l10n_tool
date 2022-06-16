class ArbException implements Exception {
  const ArbException();
}

class MissingArbDir extends ArbException {
  const MissingArbDir(this.path);
  final String path;
}

class MissingArbTemplateFile extends ArbException {
  const MissingArbTemplateFile(this.path);
  final String path;
}

class ArbFileFormatException extends ArbException {
  const ArbFileFormatException(this.name);
  final String name;
}

class ArbFileMissingLocaleException extends ArbException {
  const ArbFileMissingLocaleException(this.name);
  final String name;
}

class ArbMultipleFilesWithSameLocationException extends ArbException {
  const ArbMultipleFilesWithSameLocationException(this.locale);
  final String locale;
}

enum ArbResourceErrorType {
  globalFormat,
  format,
  missingOne,
  missing,
  missingPlaceholders,
  missingPlaceholder,
  placeholdersFormat,
}

class ArbResourceDefinitionException extends ArbException {
  const ArbResourceDefinitionException({
    required this.error,
    required this.resourceId,
    this.type = '',
    this.detail = '',
  });

  factory ArbResourceDefinitionException.globalFormat(String resourceId) =>
      ArbResourceDefinitionException(
        error: ArbResourceErrorType.globalFormat,
        resourceId: resourceId,
      );

  factory ArbResourceDefinitionException.format(String resourceId) =>
      ArbResourceDefinitionException(
        error: ArbResourceErrorType.format,
        resourceId: resourceId,
      );

  factory ArbResourceDefinitionException.missingOne(String resourceId) =>
      ArbResourceDefinitionException(
        error: ArbResourceErrorType.missingOne,
        resourceId: resourceId,
      );

  factory ArbResourceDefinitionException.missing(String resourceId, {required String type}) =>
      ArbResourceDefinitionException(
        error: ArbResourceErrorType.missing,
        resourceId: resourceId,
        type: type,
      );

  factory ArbResourceDefinitionException.missingPlaceholders(
    String resourceId, {
    required String type,
  }) =>
      ArbResourceDefinitionException(
        error: ArbResourceErrorType.missingPlaceholders,
        resourceId: resourceId,
        type: type,
      );

  factory ArbResourceDefinitionException.missingPlaceholder(
    String resourceId, {
    required String type,
    required String placeholderName,
  }) =>
      ArbResourceDefinitionException(
        error: ArbResourceErrorType.missingPlaceholder,
        resourceId: resourceId,
        type: type,
        detail: placeholderName,
      );

  factory ArbResourceDefinitionException.placeholdersFormat(
    String resourceId, {
    required String type,
  }) =>
      ArbResourceDefinitionException(
        error: ArbResourceErrorType.placeholdersFormat,
        resourceId: resourceId,
        type: type,
      );

  final ArbResourceErrorType error;
  final String resourceId;
  final String type;
  final String detail;
}

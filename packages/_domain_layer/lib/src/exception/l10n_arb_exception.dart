import 'package:flutter/cupertino.dart';

import 'l10n_exception.dart';

abstract class L10nArbException extends L10nException {
  const L10nArbException(this.id);

  final String id;
}

class L10nArbGlobalDefinitionException extends L10nArbException {
  const L10nArbGlobalDefinitionException(super.id);

  @override
  String message(BuildContext context) => loc(context).error_arb_global_resource_format(id);
}

class L10nArbDefinitionException extends L10nArbException {
  const L10nArbDefinitionException(super.id);

  @override
  String message(BuildContext context) => loc(context).error_arb_definition_format(id);
}

class L10nMissingAnArbDefinitionException extends L10nArbException {
  const L10nMissingAnArbDefinitionException(super.id);

  @override
  String message(BuildContext context) => loc(context).error_arb_missing_a_definition(id);
}

class L10nMissingArbDefinitionException extends L10nArbException {
  const L10nMissingArbDefinitionException(super.id, {required this.type});

  final String type;

  @override
  String message(BuildContext context) => loc(context).error_arb_missing_definition(id, type);
}

class L10nMissingPlaceholdersException extends L10nArbException {
  const L10nMissingPlaceholdersException(super.id, {required this.type});

  final String type;

  @override
  String message(BuildContext context) => loc(context).error_arb_missing_placeholders(id, type);
}

class L10nMissingPlaceholderException extends L10nArbException {
  const L10nMissingPlaceholderException(
    super.id, {
    required this.type,
    required this.placeholderName,
  });

  final String type;
  final String placeholderName;

  @override
  String message(BuildContext context) =>
      loc(context).error_arb_missing_placeholder(id, type, placeholderName);
}

class L10nArbPlaceholdersFormatException extends L10nArbException {
  const L10nArbPlaceholdersFormatException(super.id);

  @override
  String message(BuildContext context) => loc(context).error_arb_placeholders_format(id);
}

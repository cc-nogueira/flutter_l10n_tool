import 'package:flutter/cupertino.dart';

import 'l10n_exception.dart';

abstract class L10nArbResourceException extends L10nException {
  const L10nArbResourceException(this.id);

  final String id;
}

class L10nArbGlobalResourceDefinitionException extends L10nArbResourceException {
  const L10nArbGlobalResourceDefinitionException(super.resource);

  @override
  String message(BuildContext context) => loc(context).error_arb_resource_global_format(id);
}

class L10nArbResourceDefinitionException extends L10nArbResourceException {
  const L10nArbResourceDefinitionException(super.id);

  @override
  String message(BuildContext context) => loc(context).error_arb_resource_format(id);
}

class L10nMissingAnArbResourceException extends L10nArbResourceException {
  const L10nMissingAnArbResourceException(super.id);

  @override
  String message(BuildContext context) => loc(context).error_arb_missing_a_resource_attribute(id);
}

class L10nMissingArbResourceException extends L10nArbResourceException {
  const L10nMissingArbResourceException(super.id, {required this.type});

  final String type;

  @override
  String message(BuildContext context) =>
      loc(context).error_arb_missing_resource_attribute(id, type);
}

class L10nMissingResourcePlaceholdersException extends L10nArbResourceException {
  const L10nMissingResourcePlaceholdersException(super.id, {required this.type});

  final String type;

  @override
  String message(BuildContext context) => loc(context).error_arb_missing_placeholders(id, type);
}

class L10nMissingResourcePlaceholderException extends L10nArbResourceException {
  const L10nMissingResourcePlaceholderException(
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

class L10nArbResourcePlaceholdersFormatException extends L10nArbResourceException {
  const L10nArbResourcePlaceholdersFormatException(super.id);

  @override
  String message(BuildContext context) => loc(context).error_arb_placeholders_format(id);
}

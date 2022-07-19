import '../../l10n/domain_localizations.dart';

/// Possible Display options for the UI.
///
/// Represents the possibity of displaying a compact or expanded view of our entities.
/// Uses DomainLocalizations to return a localized text description of each option.
enum DisplayOption {
  compact,
  expanded;

  String text(DomainLocalizations loc) => loc.label_display_option(name);

  bool get isCompact => this == compact;
  bool get isExpanded => this == expanded;
}

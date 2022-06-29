import '../../l10n/domain_localizations.dart';

enum DisplayOption {
  compact,
  expanded;

  String text(DomainLocalizations loc) => loc.label_display_option(name);

  bool get isCompact => this == compact;
  bool get isExpanded => this == expanded;
}

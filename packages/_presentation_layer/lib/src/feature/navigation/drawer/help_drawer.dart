import '../../../l10n/app_localizations.dart';
import 'navigation_drawer.dart';
import 'navigation_drawer_option.dart';

class HelpDrawer extends NavigationDrawer {
  const HelpDrawer({super.key}) : super(NavigationDrawerOption.help);

  @override
  String titleText(AppLocalizations loc) => loc.title_help_drawer;
}

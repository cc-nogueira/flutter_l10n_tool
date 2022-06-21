import '../../../l10n/app_localizations.dart';
import '../common/navigation_drawer_option.dart';
import '../widget/navigation_drawer.dart';

class HelpDrawer extends NavigationDrawer {
  const HelpDrawer({super.key}) : super(NavigationDrawerBottomOption.help);

  @override
  String titleText(AppLocalizations loc) => loc.title_help_drawer;
}

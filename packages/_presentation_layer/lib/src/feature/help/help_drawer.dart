import '../../common/navigation/navigation_drawer_option.dart';
import '../../common/widget/navigation_drawer.dart';
import '../../l10n/app_localizations.dart';

class HelpDrawer extends NavigationDrawer {
  const HelpDrawer({super.key}) : super(NavigationDrawerBottomOption.help);

  @override
  String titleText(AppLocalizations loc) => loc.title_help_drawer;
}

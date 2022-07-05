import '../../common/navigation/navigation_drawer_option.dart';
import '../../common/widget/navigation_drawer.dart';
import '../../l10n/app_localizations.dart';

class PreferencesDrawer extends NavigationDrawer {
  const PreferencesDrawer({super.key}) : super(NavigationDrawerTopOption.preferences);

  @override
  String titleText(AppLocalizations loc) => loc.title_preferences_drawer;
}

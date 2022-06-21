import '../../../l10n/app_localizations.dart';
import '../common/navigation_drawer_option.dart';
import '../widget/navigation_drawer.dart';

class PreferencesDrawer extends NavigationDrawer {
  const PreferencesDrawer({super.key}) : super(NavigationDrawerTopOption.preferences);

  @override
  String titleText(AppLocalizations loc) => loc.title_preferences_drawer;
}

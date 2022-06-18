import '../../../l10n/app_localizations.dart';
import 'navigation_drawer.dart';
import 'navigation_drawer_option.dart';

class PreferencesDrawer extends NavigationDrawer {
  const PreferencesDrawer({super.key}) : super(NavigationDrawerOption.preferences);

  @override
  String titleText(AppLocalizations loc) => loc.title_preferences_drawer;
}

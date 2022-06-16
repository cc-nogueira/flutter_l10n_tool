import '../entity/preferences/preference.dart';

/// PreferencesRepository interface.
///
/// Very simple Repository interface useing only an API that reads and saves by a String key.
abstract class PreferencesRepository {
  /// Get a preference by key.
  ///
  /// Look for a [Preference] by a key.
  /// Return null if none is found.
  Preference? getByKey(String key);

  /// Save a preference by key.
  ///
  /// Saves a [Preference] by its internal key.
  /// Returns the saved entity (may have an assigned id if it was new).
  Preference saveByKey(Preference preference);
}

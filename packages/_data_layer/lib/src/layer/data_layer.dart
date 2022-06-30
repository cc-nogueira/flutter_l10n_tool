import 'dart:io';

import 'package:_core_layer/core_layer.dart';
import 'package:_domain_layer/domain_layer.dart';

import 'package:path_provider/path_provider.dart';

import '../../objectbox.g.dart';
import '../model/preference_model.dart';
import '../model/recent_project_model.dart';
import '../repository/objectbox_preferences_repository.dart';
import '../repository/objectbox_recent_projects_repository.dart';

/// DataLayer has the responsibility to provide repository implementaions.
///
/// Provides all repository implementations, also accessible through providers.
class DataLayer extends AppLayer {
  DataLayer();

  /// Private objectbox store.
  late final Store _store;

  /// Getter for PreferencesRepository implementation with ObjectBox.
  PreferencesRepository get preferencesRepository =>
      ObjectboxPreferencesRepository(box: _store.box<PreferenceModel>());

  /// Getter for PreferencesRepository implementation with ObjectBox.
  RecentProjectsRepository get recentProjectsRepository =>
      ObjectboxRecentProjectsRepository(box: _store.box<RecentProjectModel>());

  /// Initilize this layer object.
  ///
  /// Opens the local ObjectBox Store (async routine).
  @override
  Future<void> init() async {
    _store = await _openStore();
  }

  /// Dispose this layer object.
  ///
  /// Will close the ObjectBox Store when App is exiting.
  @override
  void dispose() => _store.close();

  /// Internal async routine to open the ObjectBox Store.
  Future<Store> _openStore() async {
    final appDir = await getApplicationDocumentsDirectory();
    final objectboxPath =
        _isMobile ? '${appDir.path}/objectbox' : '${appDir.path}/objectbox/flutter_l10n_tool';
    if (Store.isOpen(objectboxPath)) {
      return Store.attach(getObjectBoxModel(), objectboxPath);
    } else {
      return Store(getObjectBoxModel(), directory: objectboxPath);
    }
  }

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;
}

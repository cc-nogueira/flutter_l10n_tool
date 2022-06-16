import 'package:_domain_layer/domain_layer.dart';

import '../../objectbox.g.dart';
import '../mapper/preference_mapper.dart';
import '../model/preference_model.dart';
import 'objectbox_repository.dart';

/// ObjectBox Preferences Repository implementation.
///
/// Implements domain PreferencesRepository as an ObjectBoxRepository
class ObjectboxPreferencesRepository extends ObjectboxRepository<Preference, PreferenceModel>
    implements PreferencesRepository {
  /// Const constructor receives a Box<PreferenceModel>.
  const ObjectboxPreferencesRepository({required super.box})
      : super(mapper: const PreferenceMapper());

  /// Id of my model
  @override
  get idProperty => PreferenceModel_.id;

  /// key property for query by Uuid
  get keyProperty => PreferenceModel_.key;

  /// Get a preference by key.
  ///
  /// Look for a [Preference] by a key.
  /// Return null if none is found.
  @override
  Preference? getByKey(String key) {
    final model = _getModelByKey(key);
    if (model == null) {
      return null;
    }
    return mapper.mapEntity(model);
  }

  /// Save a preference by key.
  ///
  /// Saves a [Preference] by its internal key.
  /// Returns the saved entity (may have an assigned id if it was new).
  @override
  Preference saveByKey(Preference preference) {
    final key = preference.key;
    final model = _getModelByKey(key) ?? PreferenceModel(key: key);
    model.value = preference.value;
    box.put(model);
    return mapper.mapEntity(model);
  }

  /// Internal - get a model by key.
  /// Return null if none is found.
  PreferenceModel? _getModelByKey(String key) =>
      box.query(keyProperty.equals(key)).build().findFirst();
}

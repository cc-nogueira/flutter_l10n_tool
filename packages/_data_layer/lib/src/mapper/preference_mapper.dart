import 'package:_domain_layer/domain_layer.dart';

import '../model/preference_model.dart';
import 'entity_mapper.dart';

/// PreferenceMapper to convert domain entities to persistence models and vice-versa.
class PreferenceMapper extends EntityMapper<Preference, PreferenceModel> {
  /// Const constructor.
  const PreferenceMapper();

  /// Map a persistence model to a domain entity.
  @override
  Preference mapEntity(PreferenceModel model) =>
      Preference(id: model.id, key: model.key, value: model.value);

  /// Map a domain entity to a persistence model.
  @override
  PreferenceModel mapModel(Preference entity) =>
      PreferenceModel(id: entity.id, key: entity.key, value: entity.value);
}

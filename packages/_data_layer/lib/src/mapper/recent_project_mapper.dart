import 'package:_domain_layer/domain_layer.dart';

import '../model/recent_project_model.dart';
import 'entity_mapper.dart';

/// PreferenceMapper to convert domain entities to persistence models and vice-versa.
class RecentProjectMapper extends EntityMapper<RecentProject, RecentProjectModel> {
  /// Const constructor.
  const RecentProjectMapper();

  /// Map a persistence model to a domain entity.
  @override
  RecentProject mapEntity(RecentProjectModel model) =>
      RecentProject(id: model.id, name: model.name, path: model.path);

  /// Map a domain entity to a persistence model.
  @override
  RecentProjectModel mapModel(RecentProject entity) =>
      RecentProjectModel(id: entity.id, name: entity.name, path: entity.path);

  /// Map a list of entities to a list of models registering the list order in these model objects.
  @override
  List<RecentProjectModel> mapModels(Iterable<RecentProject> entities) {
    final list = super.mapModels(entities);
    for (var i = 0; i < list.length; ++i) {
      list[i].order = i;
    }
    return list;
  }
}

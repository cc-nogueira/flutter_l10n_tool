import 'package:_domain_layer/domain_layer.dart';

import '../../objectbox.g.dart';
import '../mapper/recent_project_mapper.dart';
import '../model/recent_project_model.dart';

/// ObjectBox Recent Projects Repository implementation.
///
/// Implements domain RecentProjectsRepository as an ObjectBoxRepository
class ObjectboxRecentProjectsRepository implements RecentProjectsRepository {
  /// Const constructor receives a Box<RecentProjectModel>.
  const ObjectboxRecentProjectsRepository({required this.box});

  final RecentProjectMapper mapper = const RecentProjectMapper();
  final Box<RecentProjectModel> box;

  /// Id of my model
  get idProperty => RecentProjectModel_.id;

  @override
  List<RecentProject> getAll() {
    final models = box.getAll();
    models.sort((a, b) => a.order.compareTo(b.order));
    return mapper.mapEntities(models);
  }

  @override
  List<RecentProject> synchronizeAll(List<RecentProject> all) {
    final toPut = <RecentProjectModel>[];
    final toRemove = <RecentProjectModel>[];

    final boxModels = box.getAll();
    final inBoxMap = {for (final model in boxModels) model.id: model};

    final toSaveModels = mapper.mapModels(all);
    final toSaveMap = {
      for (final model in toSaveModels)
        if (model.id != 0) model.id: model
    };

    for (final toSaveModel in toSaveModels) {
      if (toSaveModel.id == 0) {
        toPut.add(toSaveModel);
      } else {
        if (inBoxMap.containsKey(toSaveModel.id)) {
          toPut.add(toSaveModel);
        } else {
          toSaveModel.id = 0;
          toPut.add(toSaveModel);
        }
      }
    }

    for (final boxModel in boxModels) {
      if (!toSaveMap.containsKey(boxModel.id)) {
        toRemove.add(boxModel);
      }
    }

    toPut.sort((a, b) => a.order.compareTo(b.order));
    box.putMany(toPut);
    return mapper.mapEntities(toPut);
  }
}

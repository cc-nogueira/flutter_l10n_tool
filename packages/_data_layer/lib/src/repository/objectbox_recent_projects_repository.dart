import 'package:_domain_layer/domain_layer.dart';

import '../../objectbox.g.dart';
import '../mapper/recent_project_mapper.dart';
import '../model/recent_project_model.dart';
import 'objectbox_repository.dart';

/// ObjectBox Recent Projects Repository implementation.
///
/// Implements domain RecentProjectsRepository as an ObjectBoxRepository
class ObjectboxRecentProjectsRepository
    extends ObjectboxRepository<RecentProject, RecentProjectModel>
    implements RecentProjectsRepository {
  /// Const constructor receives a Box<PreferenceModel>.
  const ObjectboxRecentProjectsRepository({required super.box})
      : super(mapper: const RecentProjectMapper());

  /// Id of my model
  @override
  get idProperty => RecentProjectModel_.id;
}

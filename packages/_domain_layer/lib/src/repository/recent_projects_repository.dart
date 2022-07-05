import '../entity/project/recent_project.dart';

/// Recent Projects Repository interface.
///
/// Entity Repository with Stream API.
abstract class RecentProjectsRepository {
  /// Return all entities from storage.
  ///
  /// The result list has no defined order.
  List<RecentProject> getAll();

  /// Synchronize the repository with this argument.
  ///
  /// Updates, removes and insert entities as necessary.
  /// Return the list of persisted entities that may have received an ID.
  List<RecentProject> synchronizeAll(List<RecentProject> all);
}

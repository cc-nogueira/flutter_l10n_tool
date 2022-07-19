part of '../recent_projects_usecase.dart';

class RecentProjectsNotifier extends StateNotifier<List<RecentProject>> {
  RecentProjectsNotifier(RecentProjectsUsecase usecase) : super(usecase._recentProjects());

  @internal
  void update(List<RecentProject> updatedList) {
    state = updatedList;
  }
}

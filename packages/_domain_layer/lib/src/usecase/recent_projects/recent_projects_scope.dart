part of 'recent_projects_usecase.dart';

class RecentProjectsScope {
  /// Recent projects provider
  final recentProjectsProvider = StateProvider<List<RecentProject>>(
    (ref) {
      final usecase = ref.read(recentProjectsUsecaseProvider);
      return usecase._repositoryStore();
    },
  );
}

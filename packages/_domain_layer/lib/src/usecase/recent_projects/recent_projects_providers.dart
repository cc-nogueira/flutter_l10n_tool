part of 'recent_projects_usecase.dart';

/// RecentProjectsUsecase singleton provider
final recentProjectsUsecaseProvider =
    Provider<RecentProjectsUsecase>((ref) => ref.watch(domainLayerProvider).recentProjectsUsecase);

final _recentProjectsScopeProvider = StateProvider((_) => RecentProjectsScope());

/// Recent projects provider
final recentProjectsProvider = Provider<List<RecentProject>>(
  (ref) {
    final scope = ref.watch(_recentProjectsScopeProvider);
    return ref.watch(scope.recentProjectsProvider);
  },
);

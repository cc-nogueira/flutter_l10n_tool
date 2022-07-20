part of 'recent_projects_usecase.dart';

/// [RecentProjectsUsecase] singleton provider.
final recentProjectsUsecaseProvider =
    Provider<RecentProjectsUsecase>((ref) => ref.watch(domainLayerProvider).recentProjectsUsecase);

/// Internal - provider of the current [RecentProjectsScope].
final _recentProjectsScopeProvider = StateProvider((_) => RecentProjectsScope());

/// This is a exporting provider to forward [RecentProjectsScope] instance internal provider.
/// See [RecentProjectsScope.recentProjectsProvider].
final recentProjectsProvider = Provider<List<RecentProject>>(
  (ref) {
    final scope = ref.watch(_recentProjectsScopeProvider);
    return ref.watch(scope.recentProjectsProvider);
  },
);

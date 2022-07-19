part of 'project_usecase.dart';

/// ProjectUsecase singleton provider
final projectUsecaseProvider =
    Provider<ProjectUsecase>((ref) => ref.watch(domainLayerProvider).projectUsecase);

/// Current project scope provider
final _projectScopeProvider = StateProvider((ref) => ProjectScope());

/// This is a exporting provider to forward [ProjectScope] instance internal provider.
/// See [ProjectScope.projectProvider].
final projectProvider = Provider<Project>((ref) {
  final scope = ref.watch(_projectScopeProvider);
  return ref.watch(scope.projectProvider);
});

/// Project loaded provider (when project path is filled in).
///
/// Select property [Project.path] test for empty.
final isProjectLoadedProvider = Provider(
  (ref) => ref.watch(projectProvider.select((p) => p.path.isNotEmpty)),
);

/// Project configuration provider.
///
/// Select property [Project.configuration] from projectConfigurationProvider.
final projectConfigurationProvider = Provider(
  (ref) => ref.watch(projectProvider.select((p) => p.configuration)),
);

/// Form configuration provider (configuration being edited).
///
/// Initial value is taken from projectConfigurationProvider.
/// This value is auto refreshed when the project configuration is changed.
final formConfigurationProvider = StateProvider<L10nConfiguration>((ref) {
  final projectConfiguration = ref.watch(projectConfigurationProvider);
  return projectConfiguration.copyWith();
});

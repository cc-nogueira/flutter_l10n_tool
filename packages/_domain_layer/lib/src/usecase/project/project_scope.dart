import 'package:riverpod/riverpod.dart';

import '../../entity/project/project.dart';
import 'notifier/project_notifier.dart';

/// Project Scope is a collection of [StateNotificationProvider] that are part of [ProjectUsecase].
///
/// These scoped providers are all recreated when a new project is loaded.
/// All are available as exported providers - simple Providers that export value of these Notifiers.
class ProjectScope {
  ProjectScope();

  /// Current project provider.
  ///
  /// Project is managed by the [ProjectNotifier], which is part of [ProjectUsecase].
  final projectProvider =
      StateNotifierProvider<ProjectNotifier, Project>((ref) => ProjectNotifier());
}

import 'package:riverpod/riverpod.dart';

import '../../entity/project/project.dart';
import 'notifier/project_notifier.dart';

/// Project Scope is a collection of [StateNotificationProvider] that are part of [ProjectUsecase].
///
/// This scope is recreated when a new project is loaded.
///
/// All these notifiers are available as exported providers (simple providers that export the value
/// of each Notifier).
class ProjectScope {
  ProjectScope();

  /// Current project provider.
  ///
  /// This is changed as the project is being loaded.
  /// After loading all user edition is stored in [ArbScope], preserving this scope
  /// for user opted rollbacks.
  final projectProvider =
      StateNotifierProvider<ProjectNotifier, Project>((ref) => ProjectNotifier());
}

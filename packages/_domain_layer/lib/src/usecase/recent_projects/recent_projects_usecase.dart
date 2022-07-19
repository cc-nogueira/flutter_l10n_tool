import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tuple/tuple.dart';

import '../../entity/project/recent_project.dart';
import '../../provider/providers.dart';
import '../../repository/recent_projects_repository.dart';

part 'recent_projects_providers.dart';
part 'recent_projects_scope.dart';

class RecentProjectsUsecase {
  const RecentProjectsUsecase({required this.read, required this.recentProjectsRepository});

  final Reader read;

  /// Internal [RecentProjectsRepository] implementation.
  @internal
  final RecentProjectsRepository recentProjectsRepository;

  List<RecentProject> _repositoryStore() => recentProjectsRepository.getAll();

  void setFirst(RecentProject recentProject) {
    final recentList = _setFirst(recentProject);
    final updatedList = recentProjectsRepository.synchronizeAll(recentList);
    _recentProjectController().state = updatedList;
  }

  void remove(RecentProject value) {
    final list = read(recentProjectsProvider);
    final without = [
      for (final each in list)
        if (each.id != value.id) each
    ];
    if (without.length < list.length) {
      final updatedList = recentProjectsRepository.synchronizeAll(without);
      _recentProjectController().state = updatedList;
    }
  }

  List<RecentProject> _setFirst(RecentProject value) {
    final extraction = _extract(value);
    late final RecentProject first;
    if (extraction.item1 == null) {
      first = value;
    } else {
      first = extraction.item1!.copyWith(name: value.name);
    }
    return [first, ...extraction.item2];
  }

  Tuple2<RecentProject?, List<RecentProject>> _extract(RecentProject value) {
    final list = read(recentProjectsProvider);
    RecentProject? found;
    final left = <RecentProject>[];
    for (final each in list) {
      if (found == null && each.path == value.path) {
        found = each;
      } else {
        left.add(each);
      }
    }
    return Tuple2(found, left);
  }

  StateController<List<RecentProject>> _recentProjectController() {
    final scope = read(_recentProjectsScopeProvider);
    return read(scope.recentProjectsProvider.notifier);
  }
}

import 'package:riverpod/riverpod.dart';

import '../../../entity/project/recent_project.dart';

class RecentProjectsNotifier extends StateNotifier<List<RecentProject>> {
  RecentProjectsNotifier(super.state);

  void update(List<RecentProject> updatedList) {
    state = updatedList;
  }
}

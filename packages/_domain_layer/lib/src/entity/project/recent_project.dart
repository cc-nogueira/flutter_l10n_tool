import 'package:freezed_annotation/freezed_annotation.dart';

import '../entity.dart';

part 'recent_project.freezed.dart';

@freezed
class RecentProject with _$RecentProject implements Entity {
  const factory RecentProject({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String path,
  }) = _RecentProject;
}

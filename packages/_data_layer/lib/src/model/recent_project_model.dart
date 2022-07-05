import 'package:objectbox/objectbox.dart';

import 'model.dart';

/// Recent project persistence model.
///
/// Implements Model with default values for all fields.
///
/// @see [RecentProjectMapper] for conversion to Entity details.
@Entity()
class RecentProjectModel implements Model {
  /// Constructor with all default value.
  RecentProjectModel({
    this.id = 0,
    this.order = 0,
    this.name = '',
    this.path = '',
  });

  /// ObjectBox key field.
  @override
  int id;

  /// Recent list ordering index
  int order;

  /// Project name set in pubspec.yaml
  String name;

  /// Project folder path (where the pubspec.yaml file is located).
  String path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentProjectModel &&
          other.id == id &&
          other.order == order &&
          other.name == name &&
          other.path == path;

  @override
  int get hashCode => Object.hash(id, order, name, path);

  @override
  String toString() => 'RecenProject(id: $id, order: $order, name: "$name", path: "$path")';
}

import 'package:objectbox/objectbox.dart';

import 'model.dart';

/// Preference persistence model.
///
/// Implements Model with default values for all fields.
///
/// @see [PreferenceMapper] for conversion to Entity details.
@Entity()
class PreferenceModel implements Model {
  /// Constructor with all default value.
  PreferenceModel({
    this.id = 0,
    this.key = '',
    this.value = '',
  });

  /// ObjectBox key field.
  @override
  int id;

  /// Domain key field (as it is referenced in PreferenceUsecase)
  String key;

  /// Preference value stored as a String (conversion to specific types at PreferenceUsecase).
  String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferenceModel && other.id == id && other.key == key && other.value == value;

  @override
  int get hashCode => Object.hash(id, key, value);

  @override
  String toString() => 'PreferenceModel(id: $id, key: "$key", value: "$value")';
}

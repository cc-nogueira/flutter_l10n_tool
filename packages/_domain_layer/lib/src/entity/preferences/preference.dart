import 'package:freezed_annotation/freezed_annotation.dart';

import '../entity.dart';

part 'preference.freezed.dart';

/// Preference entity.
///
/// Used to store app preferences with String key and value pair.
/// These preferences are converted from String to specific types in the PreferencesUsecase.
/// These preferences are accessed through preference providers also in PreferencesUsecase.
///
/// @see [PreferencesUsecase].
@freezed
class Preference with _$Preference implements Entity {
  /// Freezed factory constructor.
  const factory Preference({
    @Default(0) int id,
    @Default('') String key,
    @Default('') String value,
  }) = _Preference;
}

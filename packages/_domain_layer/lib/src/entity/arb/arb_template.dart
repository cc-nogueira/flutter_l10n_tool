import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_definition.dart';
import 'arb_global.dart';

part 'arb_template.freezed.dart';

/// Entity for a parsed ArbTemplate file.
///
/// Contains global resources and ARB resource definitions.
@freezed
class ArbTemplate with _$ArbTemplate {
  const factory ArbTemplate({
    @Default([]) List<ArbGlobal> globalResources,
    @Default([]) List<ArbDefinition> definitions,
  }) = _ArbTemplate;
}

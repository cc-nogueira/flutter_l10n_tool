import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_definition.dart';
import 'arb_translation.dart';

part 'arb_template.freezed.dart';

@freezed
class ArbTemplate with _$ArbTemplate {
  const factory ArbTemplate({
    @Default([]) List<ArbTranslation> globalResources,
    @Default([]) List<ArbDefinition> definitions,
  }) = _ArbTemplate;
}

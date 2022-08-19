import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_definition.dart';
import 'arb_key_mixin.dart';
import 'arb_translation.dart';

part 'arb_trashed_resource.freezed.dart';

@freezed
class ArbTrashedResource with _$ArbTrashedResource {
  @With<ArbKeyMixin>()
  const factory ArbTrashedResource.definition({
    required ArbDefinition definition,
    required List<ArbTranslation> translations,
  }) = ArbTrashedDefinition;

  @With<ArbKeyMixin>()
  const factory ArbTrashedResource.translation({
    required ArbDefinition definition,
    required ArbTranslation translation,
  }) = ArbTrashedTranslation;
}

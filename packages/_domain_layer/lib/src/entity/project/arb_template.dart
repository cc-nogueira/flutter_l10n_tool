import 'package:freezed_annotation/freezed_annotation.dart';

import 'arb_resource.dart';

part 'arb_template.freezed.dart';

@freezed
class ArbTemplate with _$ArbTemplate {
  const factory ArbTemplate({
    @Default([]) List<ArbResource> globalResources,
    @Default([]) List<ArbResourceDefinition> resourceDefinitions,
  }) = _ArbTemplate;
}

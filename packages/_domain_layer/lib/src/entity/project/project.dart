import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain_layer.dart';
import 'arb_locale_translations.dart';
import 'arb_template.dart';

part 'project.freezed.dart';

@freezed
class Project with _$Project {
  const factory Project({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String path,
    @Default(false) bool loaded,
    @Default(L10nConfiguration()) L10nConfiguration configuration,
    @Default(ArbTemplate()) ArbTemplate template,
    @Default({}) Map<String, ArbLocaleTranslations> translations,
  }) = _Project;
}

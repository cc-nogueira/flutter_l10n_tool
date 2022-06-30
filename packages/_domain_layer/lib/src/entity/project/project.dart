import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exception/l10n_exception.dart';
import '../arb/arb_locale_translations.dart';
import '../arb/arb_template.dart';
import 'l10n_configuration.dart';

part 'project.freezed.dart';

@freezed
class Project with _$Project {
  const factory Project({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String path,
    @Default(L10nConfiguration()) L10nConfiguration configuration,
    @Default(ArbTemplate()) ArbTemplate template,
    @Default({}) Map<String, ArbLocaleTranslations> translations,
    L10nException? l10nException,
    Object? loadError,
  }) = _Project;

  const Project._();

  bool get hasError => l10nException != null || loadError != null;
  bool get hasNoError => !hasError;
  bool get isReady => path.isNotEmpty && hasNoError;
  bool get isNotReady => !isReady;
}

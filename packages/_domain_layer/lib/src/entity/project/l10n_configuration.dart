import 'package:freezed_annotation/freezed_annotation.dart';

part 'l10n_configuration.freezed.dart';

@freezed
class L10nConfiguration with _$L10nConfiguration {
  const factory L10nConfiguration({
    bool? isFromYamlFile,
    @Default(L10nConfiguration.defaultSyntheticPackage) bool syntheticPackage,
    @Default(L10nConfiguration.defaultArbDir) String arbDir,
    @Default(L10nConfiguration.defaultOutputDir) String? outputDir,
    @Default(L10nConfiguration.defaultTemplateArbFile) String templateArbFile,
    @Default(L10nConfiguration.defaultOutputLocalizationFile) String outputLocalizationFile,
    @Default(L10nConfiguration.defaultOutputClass) String outputClass,
    @Default(L10nConfiguration.defaultHeader) String header,
    @Default(L10nConfiguration.defaultRequiredResourceAttributes) bool requiredResourceAttributes,
    @Default(L10nConfiguration.defaultNullableGetter) bool nullableGetter,
  }) = _L10nConfiguration;

  factory L10nConfiguration.syntheticRecommended() =>
      const L10nConfiguration(isFromYamlFile: true).copyWith(
        nullableGetter: false,
        header: '"//ignore_for_file: non_constant_identifier_names"',
      );

  factory L10nConfiguration.noSyntheticRecommended() =>
      const L10nConfiguration(isFromYamlFile: true).copyWith(
        syntheticPackage: false,
        nullableGetter: false,
        header: '"//ignore_for_file: non_constant_identifier_names, '
            'unnecessary_brace_in_string_interps, unnecessary_string_escapes"',
      );

  static const defaultSyntheticPackage = true;
  static const defaultArbDir = 'lib/l10n';
  static const String? defaultOutputDir = null;
  static const defaultTemplateArbFile = 'app_en.arb';
  static const defaultOutputLocalizationFile = 'app_localizations.dart';
  static const defaultOutputClass = 'AppLocalizations';
  static const defaultHeader = '';
  static const defaultRequiredResourceAttributes = false;
  static const defaultNullableGetter = true;
}

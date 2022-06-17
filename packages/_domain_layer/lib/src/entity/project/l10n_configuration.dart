import 'package:_core_layer/string_utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'l10n_configuration.freezed.dart';

@freezed
class L10nConfiguration with _$L10nConfiguration {
  const factory L10nConfiguration({
    @Default(false) bool usingYamlFile,
    @Default(L10nConfiguration.defaultSyntheticPackage) bool syntheticPackage,
    @Default('') String arbDir,
    @Default('') String outputDir,
    @Default('') String templateArbFile,
    @Default('') String outputLocalizationFile,
    @Default('') String outputClass,
    @Default('') String header,
    @Default(L10nConfiguration.defaultRequiredResourceAttributes) bool requiredResourceAttributes,
    @Default(L10nConfiguration.defaultNullableGetter) bool nullableGetter,
    @Default(false) bool markedCustom,
  }) = _L10nConfiguration;

  const L10nConfiguration._();

  factory L10nConfiguration.recommended() => const L10nConfiguration(
        usingYamlFile: true,
        syntheticPackage: recommendedSyntheticPackage,
        arbDir: recommendedArbDir,
        nullableGetter: recommendedNullableGetter,
        header: recommendedHeader,
      );

  static const defaultSyntheticPackage = true;
  static const defaultRequiredResourceAttributes = false;
  static const defaultNullableGetter = true;
  static const defaultArbDir = 'lib/l10n';
  static const defaultOutputDir = '';
  static const defaultTemplateArbFile = 'app_en.arb';
  static const defaultOutputLocalizationFile = 'app_localizations.dart';
  static const defaultOutputClass = 'AppLocalizations';
  static const defaultHeader = '';

  static const recommendedSyntheticPackage = false;
  static const recommendedNullableGetter = false;
  static const recommendedArbDir = 'lib/src/l10n';
  static const recommendedHeader = '"//ignore_for_file: non_constant_identifier_names, '
      'unnecessary_brace_in_string_interps, unnecessary_string_escapes"';

  bool get effectiveSyntheticPackage => syntheticPackage;
  String get effectiveArbDir => arbDir.ifEmpty(defaultArbDir);
  String get effectiveOutputDir => outputDir.ifEmpty(effectiveArbDir);
  String get effectiveTemplateArbFile => templateArbFile.ifEmpty(defaultTemplateArbFile);
  String get effectiveOutputLocalizationFile =>
      outputLocalizationFile.ifEmpty(defaultOutputLocalizationFile);
  String get effectiveOutputClass => outputClass.ifEmpty(defaultOutputClass);
  String get effectiveHeader => header.ifEmpty(defaultHeader);
  bool get effectiveRequiredResourceAttributes => requiredResourceAttributes;
  bool get effectiveNullableGetter => nullableGetter;

  bool get isDefault =>
      !markedCustom &&
      (syntheticPackage == defaultSyntheticPackage) &&
      (arbDir.isEmpty || arbDir == defaultArbDir) &&
      outputDir.isEmpty &&
      (templateArbFile.isEmpty || templateArbFile == defaultTemplateArbFile) &&
      (outputLocalizationFile.isEmpty || outputLocalizationFile == defaultOutputLocalizationFile) &&
      (outputClass.isEmpty || outputClass == defaultOutputClass) &&
      (header.isEmpty || header == defaultHeader) &&
      (requiredResourceAttributes == defaultRequiredResourceAttributes) &&
      (nullableGetter == defaultNullableGetter);

  bool get isRecommended =>
      !markedCustom &&
      syntheticPackage == recommendedSyntheticPackage &&
      arbDir == recommendedArbDir &&
      nullableGetter == recommendedNullableGetter &&
      header == recommendedHeader &&
      outputDir.isEmpty &&
      (templateArbFile.isEmpty || templateArbFile == defaultTemplateArbFile) &&
      (outputLocalizationFile.isEmpty || outputLocalizationFile == defaultOutputLocalizationFile) &&
      (outputClass.isEmpty || outputClass == defaultOutputClass) &&
      (requiredResourceAttributes == defaultRequiredResourceAttributes);

  bool get isCustom => !isDefault && !isRecommended;
}

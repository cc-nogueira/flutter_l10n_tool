import 'package:_core_layer/string_utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'l10n_configuration.freezed.dart';

/// Entity for the Flutter Localization Configuration.
///
/// An entity has constructors for default and recommended configurations and is
/// able to detect whether its current status is default, recommended or custom.
///
/// An empty value also represents the default value for an option and the entity presents
/// a set of "effective" getters to return the default value when the current value is empty.
@freezed
class L10nConfiguration with _$L10nConfiguration {
  /// Constructor for default configuration using empty values.
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

  /// Factory constructor for my recommended configuration.
  factory L10nConfiguration.recommended() => const L10nConfiguration(
        usingYamlFile: true,
        syntheticPackage: recommendedSyntheticPackage,
        arbDir: recommendedArbDir,
        nullableGetter: recommendedNullableGetter,
        header: recommendedHeader,
      );

  // All defalut values:
  static const defaultSyntheticPackage = true;
  static const defaultRequiredResourceAttributes = false;
  static const defaultNullableGetter = true;
  static const defaultArbDir = 'lib/l10n';
  static const defaultOutputDir = '';
  static const defaultTemplateArbFile = 'app_en.arb';
  static const defaultOutputLocalizationFile = 'app_localizations.dart';
  static const defaultOutputClass = 'AppLocalizations';
  static const defaultHeader = '';

  // All recommmended values:
  static const recommendedSyntheticPackage = false;
  static const recommendedNullableGetter = false;
  static const recommendedArbDir = 'lib/src/l10n';
  static const recommendedHeader = '//ignore_for_file: non_constant_identifier_names, '
      'unnecessary_brace_in_string_interps, unnecessary_string_escapes';

  // All effective getters:
  String get effectiveArbDir => arbDir.ifEmpty(defaultArbDir);
  String get effectiveOutputDir => outputDir.ifEmpty(effectiveArbDir);
  String get effectiveTemplateArbFile => templateArbFile.ifEmpty(defaultTemplateArbFile);
  String get effectiveOutputLocalizationFile =>
      outputLocalizationFile.ifEmpty(defaultOutputLocalizationFile);
  String get effectiveOutputClass => outputClass.ifEmpty(defaultOutputClass);
  String get effectiveHeader => header.ifEmpty(defaultHeader);

  /// Test if the current configuration is equivalent to the default configuration
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

  /// Test if the current configuration is equivalent to the recommended configuration.
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

  /// Test if the current configuration is a custom configuration (neither default nor recommended).
  bool get isCustom => !isDefault && !isRecommended;
}

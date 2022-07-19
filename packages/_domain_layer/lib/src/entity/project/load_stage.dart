/// Possible [Project] LoadStage values.
///
/// Each stage has a description that can be used to find localized messages,
/// and each stage represents a percentage of the loading process.
///
/// Error and cancelled stages are also set to represent 100% of the loading process.
///
/// All stages have a flag to tell if it is the complete loaded stage.
/// Only loaded stage has this flag set true.
enum LoadStage {
  initial('initial', 0),
  readingPubspec('readingPubspec', 0.1),
  definingConfiguration('definingConfiguration', 0.3),
  readingDefinitions('readingDefinitions', 0.5),
  readingTranslations('readingTranslations', 0.7),
  savingToRecentProjects('savingToRecentProjects', 0.9),
  loaded('loaded', 1.0, true),
  error('error', 1.0),
  canceled('canceled', 1.0);

  /// Enum constructor.
  const LoadStage(this.description, this.percent, [this.complete = false]);

  /// Stage description.
  final String description;

  /// Percentage of the loading process.
  final double percent;

  /// Flag whether this is the complete loaded stage.
  final bool complete;

  /// Getter to know if this is a final stage (loaded, error or canceled).
  bool get isFinal => percent == 1.0;
}

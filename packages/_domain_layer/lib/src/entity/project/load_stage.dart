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

  const LoadStage(this.description, this.percent, [this.complete = false]);

  final String description;
  final double percent;
  final bool complete;

  bool get isFinished => percent == 1.0;
}

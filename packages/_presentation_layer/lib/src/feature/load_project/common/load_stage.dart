enum LoadStage {
  initial('initial', 0, false),
  readingPubspec('readingPubspec', 0.1, true),
  doneReadingPubspec('readingPubspec', 0.2, false),
  definingConfiguration('definingConfiguration', 0.3, true),
  doneDefiningConfiguration('definingConfiguration', 0.4, false),
  readingResourceDefinitions('readingResourceDefinitions', 0.5, true),
  doneReadingResourceDefinitions('readingResourceDefinitions', 0.7, false),
  readingTranslations('readingTranslations', 0.8, true),
  doneReadingTranslations('readingTranslations', 1.0, false, true, true),
  error('error', 1.0, false, true),
  canceled('canceled', 1.0, false, true);

  const LoadStage(
    this.description,
    this.percent,
    this.waiting, [
    this.finished = false,
    this.complete = false,
  ]);

  final String description;
  final double percent;
  final bool waiting;
  final bool finished;
  final bool complete;

  bool get isComplete => percent == 1.0;
}

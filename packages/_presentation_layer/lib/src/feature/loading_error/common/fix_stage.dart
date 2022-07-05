enum FixStage {
  initial('initial', waiting: false, complete: false),
  fixing('fixing', waiting: true, complete: false),
  done('done', waiting: false, complete: true),
  error('error', waiting: false, complete: true);

  const FixStage(this.description, {required this.waiting, required this.complete});

  final String description;
  final bool waiting;
  final bool complete;
}

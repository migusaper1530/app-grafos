class JohnsonJob {
  const JohnsonJob({
    required this.id,
    required this.name,
    required this.machine1Time,
    required this.machine2Time,
  });

  final String id;
  final String name;
  final double machine1Time;
  final double machine2Time;
}

class JohnsonProblem {
  JohnsonProblem({required List<JohnsonJob> jobs})
    : jobs = List.unmodifiable(jobs);

  final List<JohnsonJob> jobs;
}

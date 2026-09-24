import 'johnson_problem.dart';

enum JohnsonMachine { machine1, machine2 }

class JohnsonSelectionStep {
  JohnsonSelectionStep({
    required this.selectedJob,
    required this.selectedMachine,
    required this.minimumTime,
    required List<JohnsonJob> remainingJobs,
    required List<JohnsonJob> leftSequence,
    required List<JohnsonJob> rightSequence,
  }) : remainingJobs = List.unmodifiable(remainingJobs),
       leftSequence = List.unmodifiable(leftSequence),
       rightSequence = List.unmodifiable(rightSequence);

  final JohnsonJob selectedJob;
  final JohnsonMachine selectedMachine;
  final double minimumTime;
  final List<JohnsonJob> remainingJobs;
  final List<JohnsonJob> leftSequence;
  final List<JohnsonJob> rightSequence;
}

class JohnsonScheduleEntry {
  const JohnsonScheduleEntry({
    required this.job,
    required this.machine1Start,
    required this.machine1End,
    required this.machine2Start,
    required this.machine2End,
    required this.machine2IdleBefore,
  });

  final JohnsonJob job;
  final double machine1Start;
  final double machine1End;
  final double machine2Start;
  final double machine2End;
  final double machine2IdleBefore;
}

class JohnsonResult {
  JohnsonResult({
    required List<JohnsonJob> originalJobs,
    required List<JohnsonJob> sequence,
    required List<JohnsonSelectionStep> selectionSteps,
    required List<JohnsonScheduleEntry> schedule,
    required this.makespan,
    required this.machine1Idle,
    required this.machine2Idle,
  }) : originalJobs = List.unmodifiable(originalJobs),
       sequence = List.unmodifiable(sequence),
       selectionSteps = List.unmodifiable(selectionSteps),
       schedule = List.unmodifiable(schedule);

  final List<JohnsonJob> originalJobs;
  final List<JohnsonJob> sequence;
  final List<JohnsonSelectionStep> selectionSteps;
  final List<JohnsonScheduleEntry> schedule;
  final double makespan;
  final double machine1Idle;
  final double machine2Idle;
}

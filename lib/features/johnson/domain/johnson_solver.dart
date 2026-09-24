import 'dart:math';

import 'johnson_problem.dart';
import 'johnson_result.dart';

/// Aplica la regla de Johnson para trabajos procesados en dos máquinas.
class JohnsonSolver {
  const JohnsonSolver();

  JohnsonResult solve(JohnsonProblem problem) {
    _validate(problem);

    final remaining = List<JohnsonJob>.from(problem.jobs);
    final left = <JohnsonJob>[];
    final right = <JohnsonJob>[];
    final steps = <JohnsonSelectionStep>[];

    while (remaining.isNotEmpty) {
      var selected = remaining.first;
      var selectedMachine = JohnsonMachine.machine1;
      var minimum = selected.machine1Time;

      for (final job in remaining) {
        if (job.machine1Time < minimum) {
          selected = job;
          selectedMachine = JohnsonMachine.machine1;
          minimum = job.machine1Time;
        }
        if (job.machine2Time < minimum) {
          selected = job;
          selectedMachine = JohnsonMachine.machine2;
          minimum = job.machine2Time;
        }
      }

      remaining.remove(selected);
      if (selectedMachine == JohnsonMachine.machine1) {
        left.add(selected);
      } else {
        right.insert(0, selected);
      }
      steps.add(
        JohnsonSelectionStep(
          selectedJob: selected,
          selectedMachine: selectedMachine,
          minimumTime: minimum,
          remainingJobs: remaining,
          leftSequence: left,
          rightSequence: right,
        ),
      );
    }

    final sequence = [...left, ...right];
    final schedule = <JohnsonScheduleEntry>[];
    var machine1Cursor = 0.0;
    var machine2Cursor = 0.0;
    var machine2Idle = 0.0;
    for (final job in sequence) {
      final machine1Start = machine1Cursor;
      final machine1End = machine1Start + job.machine1Time;
      final machine2Start = max(machine1End, machine2Cursor);
      final idleBefore = machine2Start - machine2Cursor;
      final machine2End = machine2Start + job.machine2Time;
      machine2Idle += idleBefore;
      schedule.add(
        JohnsonScheduleEntry(
          job: job,
          machine1Start: machine1Start,
          machine1End: machine1End,
          machine2Start: machine2Start,
          machine2End: machine2End,
          machine2IdleBefore: idleBefore,
        ),
      );
      machine1Cursor = machine1End;
      machine2Cursor = machine2End;
    }

    final makespan = machine2Cursor;
    final totalMachine1Time = problem.jobs.fold<double>(
      0,
      (sum, job) => sum + job.machine1Time,
    );
    return JohnsonResult(
      originalJobs: problem.jobs,
      sequence: sequence,
      selectionSteps: steps,
      schedule: schedule,
      makespan: makespan,
      machine1Idle: makespan - totalMachine1Time,
      machine2Idle: machine2Idle,
    );
  }

  void _validate(JohnsonProblem problem) {
    if (problem.jobs.isEmpty) {
      throw const FormatException('Debe existir al menos un trabajo.');
    }
    if (problem.jobs.map((job) => job.id).toSet().length !=
        problem.jobs.length) {
      throw const FormatException('Los identificadores deben ser únicos.');
    }
    for (final job in problem.jobs) {
      if (!job.machine1Time.isFinite ||
          !job.machine2Time.isFinite ||
          job.machine1Time < 0 ||
          job.machine2Time < 0) {
        throw const FormatException(
          'Los tiempos deben ser números no negativos.',
        );
      }
    }
  }
}

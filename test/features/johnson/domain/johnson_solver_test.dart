import 'package:app_grafos/features/johnson/domain/johnson_problem.dart';
import 'package:app_grafos/features/johnson/domain/johnson_result.dart';
import 'package:app_grafos/features/johnson/domain/johnson_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const solver = JohnsonSolver();

  test('obtiene la secuencia y el makespan para dos máquinas', () {
    final result = solver.solve(
      JohnsonProblem(
        jobs: const [
          JohnsonJob(id: '1', name: 'J1', machine1Time: 3, machine2Time: 8),
          JohnsonJob(id: '2', name: 'J2', machine1Time: 12, machine2Time: 4),
          JohnsonJob(id: '3', name: 'J3', machine1Time: 5, machine2Time: 6),
          JohnsonJob(id: '4', name: 'J4', machine1Time: 2, machine2Time: 10),
        ],
      ),
    );

    expect(result.sequence.map((job) => job.name), ['J4', 'J1', 'J3', 'J2']);
    expect(result.makespan, 30);
    expect(result.selectionSteps.first.selectedJob.name, 'J4');
    expect(
      result.selectionSteps.first.selectedMachine,
      JohnsonMachine.machine1,
    );
    expect(result.schedule.first.machine1Start, 0);
    expect(result.schedule.first.machine1End, 2);
    expect(result.schedule.first.machine2Start, 2);
    expect(result.schedule.last.machine2End, 30);
  });

  test('coloca al final los trabajos seleccionados por máquina 2', () {
    final result = solver.solve(
      JohnsonProblem(
        jobs: const [
          JohnsonJob(id: 'a', name: 'A', machine1Time: 7, machine2Time: 1),
          JohnsonJob(id: 'b', name: 'B', machine1Time: 2, machine2Time: 8),
          JohnsonJob(id: 'c', name: 'C', machine1Time: 6, machine2Time: 3),
        ],
      ),
    );

    expect(result.sequence.map((job) => job.name), ['B', 'C', 'A']);
  });

  test('rechaza tiempos negativos', () {
    expect(
      () => solver.solve(
        JohnsonProblem(
          jobs: const [
            JohnsonJob(id: 'a', name: 'A', machine1Time: -1, machine2Time: 2),
          ],
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}

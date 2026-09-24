import 'package:app_grafos/features/assignment/domain/assignment_problem.dart';
import 'package:app_grafos/features/assignment/domain/assignment_solver.dart';
import 'package:app_grafos/features/assignment/domain/optimization_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const solver = AssignmentSolver();
  const origins = [
    AssignmentItem(id: 'a', label: 'A'),
    AssignmentItem(id: 'b', label: 'B'),
  ];
  const destinations = [
    AssignmentItem(id: 'x', label: 'X'),
    AssignmentItem(id: 'y', label: 'Y'),
  ];
  const costs = [
    AssignmentCost(originId: 'a', destinationId: 'x', value: 4),
    AssignmentCost(originId: 'a', destinationId: 'y', value: 1),
    AssignmentCost(originId: 'b', destinationId: 'x', value: 2),
    AssignmentCost(originId: 'b', destinationId: 'y', value: 5),
  ];

  test('encuentra la asignación de costo mínimo', () {
    final result = solver.solve(
      AssignmentProblem(
        origins: origins,
        destinations: destinations,
        costs: costs,
        mode: OptimizationMode.minimize,
      ),
    );

    expect(result, isNotNull);
    expect(result!.total, 3);
    expect(
      result.matches.map(
        (match) => '${match.origin.id}-${match.destination.id}',
      ),
      containsAll(['a-y', 'b-x']),
    );
    expect(result.steps.first.title, startsWith('Matriz inicial'));
    expect(result.steps.any((step) => step.title.contains('Vector α')), isTrue);
    expect(result.steps.any((step) => step.title.contains('Vector β')), isTrue);
    expect(result.steps.last.title, 'Asignación final');
  });

  test('encuentra la asignación de beneficio máximo', () {
    final result = solver.solve(
      AssignmentProblem(
        origins: origins,
        destinations: destinations,
        costs: costs,
        mode: OptimizationMode.maximize,
      ),
    );

    expect(result, isNotNull);
    expect(result!.total, 9);
    expect(
      result.matches.map(
        (match) => '${match.origin.id}-${match.destination.id}',
      ),
      containsAll(['a-x', 'b-y']),
    );
    expect(
      result.steps.any(
        (step) => step.title == 'Transformación para maximizar: B = −A',
      ),
      isTrue,
    );
    final transformed = result.steps.firstWhere(
      (step) => step.title == 'Transformación para maximizar: B = −A',
    );
    expect(transformed.matrix, [
      [-4, -1],
      [-2, -5],
    ]);
  });

  test('informa cuando no existe una asignación completa', () {
    final result = solver.solve(
      AssignmentProblem(
        origins: origins,
        destinations: destinations,
        costs: const [
          AssignmentCost(originId: 'a', destinationId: 'x', value: 4),
        ],
        mode: OptimizationMode.minimize,
      ),
    );

    expect(result, isNull);
  });

  test('resuelve una matriz 3x3 que requiere ajustar ceros', () {
    const rows = [
      AssignmentItem(id: 'r1', label: 'A'),
      AssignmentItem(id: 'r2', label: 'B'),
      AssignmentItem(id: 'r3', label: 'C'),
    ];
    const columns = [
      AssignmentItem(id: 'c1', label: 'X'),
      AssignmentItem(id: 'c2', label: 'Y'),
      AssignmentItem(id: 'c3', label: 'Z'),
    ];
    const matrixCosts = [
      AssignmentCost(originId: 'r1', destinationId: 'c1', value: 4),
      AssignmentCost(originId: 'r1', destinationId: 'c2', value: 1),
      AssignmentCost(originId: 'r1', destinationId: 'c3', value: 3),
      AssignmentCost(originId: 'r2', destinationId: 'c1', value: 2),
      AssignmentCost(originId: 'r2', destinationId: 'c2', value: 0),
      AssignmentCost(originId: 'r2', destinationId: 'c3', value: 5),
      AssignmentCost(originId: 'r3', destinationId: 'c1', value: 3),
      AssignmentCost(originId: 'r3', destinationId: 'c2', value: 2),
      AssignmentCost(originId: 'r3', destinationId: 'c3', value: 2),
    ];

    final result = solver.solve(
      AssignmentProblem(
        origins: rows,
        destinations: columns,
        costs: matrixCosts,
        mode: OptimizationMode.minimize,
      ),
    );

    expect(result, isNotNull);
    expect(result!.total, 5);
    expect(
      result.matches.map(
        (match) => '${match.origin.id}-${match.destination.id}',
      ),
      containsAll(['r1-c2', 'r2-c1', 'r3-c3']),
    );
    expect(
      result.steps.any((step) => step.title == 'Ajuste de la matriz'),
      isTrue,
    );
  });
}

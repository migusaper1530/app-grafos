import 'package:app_grafos/features/northwest_corner/domain/northwest_corner_solver.dart';
import 'package:app_grafos/features/northwest_corner/domain/transportation_problem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const solver = NorthwestCornerSolver();

  test('calcula el ejemplo balanceado por esquina noroeste', () {
    final result = solver.solve(
      TransportationProblem(
        costs: const [
          [8, 6, 10],
          [9, 12, 13],
          [14, 9, 16],
        ],
        supply: const [20, 30, 25],
        demand: const [10, 35, 30],
        originLabels: const ['O1', 'O2', 'O3'],
        destinationLabels: const ['D1', 'D2', 'D3'],
      ),
    );

    expect(result.wasBalanced, isFalse);
    expect(result.initialAllocations, [
      [10, 10, 0],
      [0, 25, 5],
      [0, 0, 25],
    ]);
    expect(result.allocations, [
      [0, 10, 10],
      [10, 0, 20],
      [0, 25, 0],
    ]);
    expect(result.totalUnits, 75);
    expect(result.initialCost, 905);
    expect(result.totalCost, 735);
    expect(result.isOptimal, isTrue);
    expect(result.optimizationSteps, isNotEmpty);
    expect(result.optimizationSteps.first.cycle.length.isEven, isTrue);
    expect(result.optimizationSteps.first.alpha, greaterThanOrEqualTo(0));
    expect(
      result.finalOpportunityCosts
          .expand((row) => row)
          .whereType<double>()
          .every((value) => value <= 1e-9),
      isTrue,
    );
    expect(result.steps.length, 5);
    expect(result.steps.first.availableSupply, 20);
    expect(result.steps.first.pendingDemand, 10);
    expect(result.steps.first.allocated, 10);
    expect(result.steps.first.unitCost, 8);
    expect(result.steps.first.accumulatedCost, 80);
    expect(result.steps.first.remainingSupplySnapshot, [10, 30, 25]);
    expect(result.steps.first.remainingDemandSnapshot, [0, 35, 30]);
    expect(result.steps.first.allocationsSnapshot, [
      [10, 0, 0],
      [0, 0, 0],
      [0, 0, 0],
    ]);
    expect(result.steps.last.accumulatedCost, 905);
  });

  test('agrega destino ficticio cuando sobra oferta', () {
    final result = solver.solve(
      TransportationProblem(
        costs: const [
          [2],
          [3],
        ],
        supply: const [5, 5],
        demand: const [7],
      ),
    );

    expect(result.addedDummyDestination, isTrue);
    expect(result.destinationLabels.last, 'Destino ficticio');
    expect(result.balancedDemand, [7, 3]);
    expect(result.initialAllocations, [
      [5, 0],
      [2, 3],
    ]);
    expect(result.totalCost, 16);
  });

  test('agrega origen ficticio cuando falta oferta', () {
    final result = solver.solve(
      TransportationProblem(
        costs: const [
          [4, 1],
        ],
        supply: const [3],
        demand: const [1, 4],
      ),
    );

    expect(result.addedDummyOrigin, isTrue);
    expect(result.originLabels.last, 'Origen ficticio');
    expect(result.balancedSupply, [3, 2]);
    expect(result.initialAllocations, [
      [1, 2],
      [0, 2],
    ]);
    expect(result.initialCost, 6);
    expect(result.allocations, [
      [0, 3],
      [1, 1],
    ]);
    expect(result.totalCost, 3);
  });

  test('maximiza el valor después de la solución noroeste', () {
    final result = solver.solve(
      TransportationProblem(
        costs: const [
          [1, 9],
          [8, 2],
        ],
        supply: const [5, 5],
        demand: const [5, 5],
        mode: TransportationOptimizationMode.maximize,
      ),
    );

    expect(result.initialCost, 15);
    expect(result.totalCost, 85);
    expect(result.allocations, [
      [0, 5],
      [5, 0],
    ]);
    expect(result.isOptimal, isTrue);
  });

  test('rechaza una matriz incompatible con oferta y demanda', () {
    expect(
      () => solver.solve(
        TransportationProblem(
          costs: const [
            [1, 2],
          ],
          supply: const [5, 5],
          demand: const [4, 6],
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}

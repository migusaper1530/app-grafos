import 'dart:math';

import 'package:app_grafos/features/sorting/domain/sorting_algorithm.dart';
import 'package:app_grafos/features/sorting/domain/sorting_order.dart';
import 'package:app_grafos/features/sorting/domain/sorting_problem.dart';
import 'package:app_grafos/features/sorting/domain/sorting_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const solver = SortingSolver();

  for (final order in SortingOrder.values) {
    test('Merge Sort: listas de longitudes 0 a 20 en ${order.label}', () {
      final random = Random(42);
      for (int size = 0; size <= 20; size++) {
        for (int sample = 0; sample < 10; sample++) {
          final input = List<int>.generate(
            size,
            (_) => random.nextInt(100) + 1,
          );
          final original = List<int>.from(input);
          final expected = List<int>.from(input)..sort();
          if (order == SortingOrder.descending) {
            expected.setAll(0, expected.reversed.toList());
          }
          final result = solver.solve(
            SortingProblem(
              originalArray: input,
              algorithm: SortingAlgorithm.mergeSort,
              order: order,
            ),
          );
          expect(result.finalArray, expected);
          expect(input, original);
          expect(result.steps.first.array, original);
          expect(result.steps.last.sortedIndices.length, size);
          for (final step in result.steps) {
            expect(step.array.length, size);
            for (final index in step.sortedIndices) {
              expect(step.array[index], expected[index]);
            }
          }
          if (size > 1) {
            final levels = (log(size) / ln2).ceil();
            expect(result.totalComparisons, lessThanOrEqualTo(size * levels));
            expect(result.totalSwaps, lessThanOrEqualTo(size * levels));
          } else {
            expect(result.totalComparisons, 0);
            expect(result.totalSwaps, 0);
          }
        }
      }
    });
  }

  test(
    'Merge Sort cuenta comparaciones y escrituras sin alterar pasos previos',
    () {
      final result = solver.solve(
        const SortingProblem(
          originalArray: [4, 1, 3, 2],
          algorithm: SortingAlgorithm.mergeSort,
        ),
      );
      expect(result.totalComparisons, 5);
      expect(result.totalSwaps, 8);
      expect(result.steps.first.array, [4, 1, 3, 2]);
      expect(result.finalArray, [1, 2, 3, 4]);
      final initial = List<int>.from(result.steps.first.array);
      result.finalArray[0] = 99;
      expect(result.steps.first.array, initial);
    },
  );

  test('Merge Sort informa complejidad temporal y espacio auxiliar', () {
    const algorithm = SortingAlgorithm.mergeSort;
    expect(algorithm.bestCase, 'O(n log n)');
    expect(algorithm.averageCase, 'O(n log n)');
    expect(algorithm.worstCase, 'O(n log n)');
    expect(algorithm.auxiliarySpace, 'O(n)');
    expect(algorithm.movementLabel, 'Escrituras');
  });
}

import 'dart:math';

import 'package:app_grafos/features/sorting/domain/sorting_algorithm.dart';
import 'package:app_grafos/features/sorting/domain/sorting_order.dart';
import 'package:app_grafos/features/sorting/domain/sorting_problem.dart';
import 'package:app_grafos/features/sorting/domain/sorting_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const solver = SortingSolver();

  for (final order in SortingOrder.values) {
    test('Shell Sort: distintos tamaños y duplicados en ${order.label}', () {
      final random = Random(2026);
      for (final size in [0, 1, 2, 5, 6, 12, 13, 14, 20, 39, 40, 41, 64]) {
        for (int sample = 0; sample < 20; sample++) {
          final input = List<int>.generate(
            size,
            (_) => random.nextInt(100) + 1,
          );
          final original = List<int>.of(input);
          final ordered = List<int>.of(input)..sort();
          final expected = order == SortingOrder.ascending
              ? ordered
              : ordered.reversed.toList();
          final result = solver.solve(
            SortingProblem(
              originalArray: input,
              algorithm: SortingAlgorithm.shellSort,
              order: order,
            ),
          );
          expect(result.finalArray, expected);
          expect(input, original);
          expect(result.steps.first.array, original);
          expect(
            result.steps.last.sortedIndices,
            Set.of(List.generate(size, (i) => i)),
          );
          for (final step in result.steps) {
            expect(step.array.length, size);
            for (final index in [
              step.comparingIndex1,
              step.comparingIndex2,
              step.movingIndex,
            ]) {
              if (index != null) expect(index, inInclusiveRange(0, size - 1));
            }
            for (final index in step.sortedIndices) {
              expect(step.array[index], expected[index]);
            }
          }
          if (size < 2) {
            expect(result.totalComparisons, 0);
            expect(result.totalSwaps, 0);
          }
        }
      }
    });

    test('Shell Sort recorre saltos 13, 4 y 1 en ${order.label}', () {
      final ascending = List<int>.generate(20, (i) => i + 1);
      final input = order == SortingOrder.ascending
          ? ascending
          : ascending.reversed.toList();
      final result = solver.solve(
        SortingProblem(
          originalArray: input,
          algorithm: SortingAlgorithm.shellSort,
          order: order,
        ),
      );
      final passes = result.steps
          .where((step) => step.description.contains('Ordenando por inserción'))
          .toList();
      expect(passes.length, 3);
      expect(passes[0].description, startsWith('Salto h = 13.'));
      expect(passes[1].description, startsWith('Salto h = 4.'));
      expect(passes[2].description, startsWith('Salto h = 1.'));
      expect(result.totalComparisons, 42);
      expect(result.totalSwaps, 0);
      expect(result.finalArray, input);
    });
  }

  test('Shell Sort cuenta desplazamientos y conserva las instantáneas', () {
    final result = solver.solve(
      const SortingProblem(
        originalArray: [3, 2, 1],
        algorithm: SortingAlgorithm.shellSort,
      ),
    );
    expect(result.totalComparisons, 3);
    expect(result.totalSwaps, 3);
    expect(result.finalArray, [1, 2, 3]);
    expect(result.steps.first.array, [3, 2, 1]);
    result.finalArray[0] = 99;
    expect(result.steps.first.array, [3, 2, 1]);
  });
}

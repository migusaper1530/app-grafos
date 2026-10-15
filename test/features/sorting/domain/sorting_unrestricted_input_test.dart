import 'package:flutter_test/flutter_test.dart';

import 'package:app_grafos/features/sorting/domain/sorting_algorithm.dart';
import 'package:app_grafos/features/sorting/domain/sorting_document.dart';
import 'package:app_grafos/features/sorting/domain/sorting_order.dart';
import 'package:app_grafos/features/sorting/domain/sorting_problem.dart';
import 'package:app_grafos/features/sorting/domain/sorting_solver.dart';
import 'package:app_grafos/features/sorting/domain/sorting_validator.dart';

void main() {
  final numbers = List<int>.generate(125, (i) => (i % 17 - 8) * 12345);

  test(
    'acepta listas largas con negativos, cero, repetidos y valores grandes',
    () {
      final (parsed, error) = SortingValidator.parseInputString(
        numbers.join(',\n'),
      );
      expect(error, isNull);
      expect(parsed, numbers);
      expect(SortingValidator.validateArray(parsed), (true, null));
      for (final invalid in ['', '1,,2', '1.5,2', '1,texto']) {
        expect(SortingValidator.parseInputString(invalid).$2, isNotNull);
      }
    },
  );

  test('la cantidad se escribe sin límite fijo y exige un entero positivo', () {
    for (final count in [1, 21, 101, 10000, 1000000]) {
      expect(SortingValidator.parseCount(' $count '), (count, null));
    }
    for (final input in ['', '0', '-1', '1.5', 'texto']) {
      expect(SortingValidator.parseCount(input).$2, isNotNull);
    }
  });

  for (final algorithm in SortingAlgorithm.values) {
    for (final order in SortingOrder.values) {
      test('${algorithm.name} ordena más de 100 enteros en ${order.name}', () {
        final expected = [...numbers]..sort();
        final result = const SortingSolver().solve(
          SortingProblem(
            algorithm: algorithm,
            order: order,
            originalArray: numbers,
          ),
        );
        expect(
          result.finalArray,
          order == SortingOrder.ascending
              ? expected
              : expected.reversed.toList(),
        );
        expect(result.steps.first.array, numbers);
      });
    }

    test('${algorithm.name} guarda y carga JSON sin el antiguo límite', () {
      final original = SortingDocument(
        name: 'lista larga',
        algorithm: algorithm,
        order: SortingOrder.descending,
        originalArray: numbers,
      );
      final loaded = SortingDocument.decode(original.encode());
      expect(loaded.originalArray, numbers);
      expect(loaded.algorithm, algorithm);
      expect(loaded.order, SortingOrder.descending);
    });
  }
}

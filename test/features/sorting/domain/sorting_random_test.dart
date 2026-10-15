import 'package:flutter_test/flutter_test.dart';

import 'package:app_grafos/features/sorting/domain/sorting_validator.dart';

void main() {
  test(
    'aleatorios con la cantidad solicitada, únicos y válidos en navegador',
    () {
      for (final size in [1, 20, 21, 100, 101, 1000, 10000]) {
        final numbers = SortingValidator.generateRandomArray(size);
        expect(numbers, hasLength(size));
        expect(numbers.toSet(), hasLength(size));
        expect(
          numbers.every(
            (number) => number >= 1 && number <= (size < 100 ? 100 : size),
          ),
          isTrue,
        );
        expect(SortingValidator.validateArray(numbers).$1, isTrue);
      }
      expect(
        () => SortingValidator.generateRandomArray(0),
        throwsArgumentError,
      );
      expect(
        () => SortingValidator.generateRandomArray(-1),
        throwsArgumentError,
      );
    },
  );
}

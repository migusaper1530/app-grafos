import 'dart:math';

/// Validates input for sorting algorithms
class SortingValidator {
  /// Quantity and integer values have no application-imposed upper bound.
  static (bool, String?) validateArray(List<int> numbers) {
    if (numbers.isEmpty) return (false, 'El array no puede estar vacío');
    return (true, null);
  }

  static (int?, String?) parseCount(String input) {
    final count = int.tryParse(input.trim());
    if (count == null || count <= 0) {
      return (null, 'Ingresa una cantidad entera mayor que cero.');
    }
    return (count, null);
  }

  /// Parses comma-separated string into list of integers
  /// Returns (numbers, errorMessage)
  static (List<int>, String?) parseInputString(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return ([], 'El input no puede estar vacío');
    }

    try {
      final parts = trimmed.split(',');
      final numbers = <int>[];

      for (final part in parts) {
        final cleaned = part.trim();
        if (cleaned.isEmpty) {
          return (
            [],
            'No se permiten comas consecutivas o espacios en blanco sin número',
          );
        }

        final num = int.parse(cleaned);
        numbers.add(num);
      }

      final (isValid, error) = validateArray(numbers);
      if (!isValid) {
        return ([], error!);
      }

      return (numbers, null);
    } catch (e) {
      return (
        [],
        'Input inválido. Use números separados por comas (ej: 5,3,8,1)',
      );
    }
  }

  /// Generates random array of specified size
  static List<int> generateRandomArray(int size) {
    if (size <= 0) {
      throw ArgumentError('La cantidad debe ser mayor que cero.');
    }

    // Expand the sampling range with the requested size, keeping values unique.
    final candidates = List<int>.generate(max(100, size), (index) => index + 1)
      ..shuffle(Random());
    return candidates.take(size).toList();
  }
}

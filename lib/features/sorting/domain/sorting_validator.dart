/// Validates input for sorting algorithms
class SortingValidator {
  static const int minValue = 1;
  static const int maxValue = 100;
  static const int maxElements = 20;

  /// Validates a list of numbers for sorting
  /// Returns (isValid, errorMessage)
  static (bool, String?) validateArray(List<int> numbers) {
    if (numbers.isEmpty) {
      return (false, 'El array no puede estar vacío');
    }

    if (numbers.length > maxElements) {
      return (
        false,
        'Máximo $maxElements elementos permitidos (se proporcionaron ${numbers.length})',
      );
    }

    for (final num in numbers) {
      if (num < minValue || num > maxValue) {
        return (
          false,
          'Todos los números deben estar entre $minValue y $maxValue (encontrado: $num)',
        );
      }
    }

    return (true, null);
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
    if (size <= 0 || size > maxElements) {
      throw ArgumentError('Size debe estar entre 1 y $maxElements');
    }

    final random = <int>[];
    final usedNumbers = <int>{};

    while (random.length < size) {
      final num =
          (DateTime.now().microsecond % (maxValue - minValue + 1)) + minValue;
      if (!usedNumbers.contains(num)) {
        random.add(num);
        usedNumbers.add(num);
      }
    }

    return random;
  }
}

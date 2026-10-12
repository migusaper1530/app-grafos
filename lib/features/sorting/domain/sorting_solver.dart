import 'sorting_algorithm.dart';
import 'sorting_problem.dart';
import 'sorting_result.dart';
import 'sorting_step.dart';

/// Solves sorting problems using different algorithms.
/// Generates step-by-step visualization data without UI dependencies.
class SortingSolver {
  const SortingSolver();

  SortingResult solve(SortingProblem problem) {
    switch (problem.algorithm) {
      case SortingAlgorithm.selectionSort:
        return _solveSelectionSort(problem);
      case SortingAlgorithm.insertionSort:
        return _solveInsertionSort(problem);
      case SortingAlgorithm.mergeSort:
        return _solveMergeSort(problem);
      case SortingAlgorithm.shellSort:
        return _solveShellSort(problem);
    }
  }

  SortingResult _solveSelectionSort(SortingProblem problem) {
    final steps = <SortingStep>[];
    final array = List<int>.from(problem.originalArray);
    final sortedIndices = <int>{};
    int totalComparisons = 0;
    int totalSwaps = 0;

    // Initial state
    steps.add(
      SortingStep(
        array: List.from(array),
        sortedIndices: {},
        description:
            'Selection Sort · ${problem.order.description}. ${array.length} elementos por ordenar.',
      ),
    );

    for (int i = 0; i < array.length - 1; i++) {
      int selectedIndex = i;

      // Select the next element according to the requested order
      for (int j = i + 1; j < array.length; j++) {
        totalComparisons++;

        // Step: comparing i and j
        steps.add(
          SortingStep(
            array: List.from(array),
            comparingIndex1: selectedIndex,
            comparingIndex2: j,
            sortedIndices: Set.from(sortedIndices),
            description:
                'Comparando ${array[selectedIndex]} (posición $selectedIndex) con ${array[j]} (posición $j)',
          ),
        );

        if (problem.order.comesBefore(array[j], array[selectedIndex])) {
          selectedIndex = j;
        }
      }

      // Swap if necessary
      if (selectedIndex != i) {
        totalSwaps++;
        final temp = array[i];
        array[i] = array[selectedIndex];
        array[selectedIndex] = temp;

        steps.add(
          SortingStep(
            array: List.from(array),
            movingIndex: i,
            sortedIndices: Set.from(sortedIndices),
            description:
                'Intercambiando elementos: ${array[i]} va a posición $i',
          ),
        );
      }

      // Mark as sorted
      sortedIndices.add(i);
      steps.add(
        SortingStep(
          array: List.from(array),
          sortedIndices: Set.from(sortedIndices),
          description: 'Posición $i está en su lugar correcto: ${array[i]}',
        ),
      );
    }

    // Mark last element as sorted
    if (array.isNotEmpty) sortedIndices.add(array.length - 1);
    steps.add(
      SortingStep(
        array: List.from(array),
        sortedIndices: Set.from(sortedIndices),
        description: '¡Ordenamiento completado! ${problem.order.description}.',
      ),
    );

    return SortingResult(
      steps: steps,
      totalComparisons: totalComparisons,
      totalSwaps: totalSwaps,
    );
  }

  SortingResult _solveInsertionSort(SortingProblem problem) {
    final steps = <SortingStep>[];
    final array = List<int>.from(problem.originalArray);
    final sortedIndices = <int>{};
    int totalComparisons = 0;
    int totalSwaps = 0;

    // Mark first element as sorted
    if (array.isNotEmpty) sortedIndices.add(0);
    steps.add(
      SortingStep(
        array: List.from(array),
        sortedIndices: Set.from(sortedIndices),
        description:
            'Insertion Sort · ${problem.order.description}. ${array.isEmpty ? 'No hay elementos.' : 'El primer elemento inicia la porción ordenada.'}',
      ),
    );

    for (int i = 1; i < array.length; i++) {
      final key = array[i];

      steps.add(
        SortingStep(
          array: List.from(array),
          movingIndex: i,
          sortedIndices: Set.from(sortedIndices),
          description:
              'Tomando elemento $i: ${array[i]}. Buscando posición correcta.',
        ),
      );

      int j = i - 1;

      // Count every element comparison, including the one that stops shifting.
      while (j >= 0) {
        final shouldShift = problem.order.comesBefore(key, array[j]);
        totalComparisons++;

        steps.add(
          SortingStep(
            array: List.from(array),
            comparingIndex1: j,
            movingIndex: j + 1,
            sortedIndices: Set.from(sortedIndices),
            description:
                'Comparando ${array[j]} (posición $j) con $key. ${shouldShift ? 'Se desplaza para dejar espacio.' : 'La posición de inserción está lista.'}',
          ),
        );

        if (!shouldShift) break;

        array[j + 1] = array[j];
        totalSwaps++;

        steps.add(
          SortingStep(
            array: List.from(array),
            movingIndex: j + 1,
            sortedIndices: Set.from(sortedIndices),
            description: 'Desplazando ${array[j]} a posición ${j + 1}',
          ),
        );

        j--;
      }

      // Insert key at correct position
      array[j + 1] = key;

      steps.add(
        SortingStep(
          array: List.from(array),
          sortedIndices: Set.from(sortedIndices),
          description: 'Insertando $key en posición ${j + 1}',
        ),
      );

      sortedIndices.add(i);
      steps.add(
        SortingStep(
          array: List.from(array),
          sortedIndices: Set.from(sortedIndices),
          description: 'Elementos 0-$i están en orden relativo correcto.',
        ),
      );
    }

    steps.add(
      SortingStep(
        array: List.from(array),
        sortedIndices: Set.from(sortedIndices),
        description: '¡Ordenamiento completado! ${problem.order.description}.',
      ),
    );

    return SortingResult(
      steps: steps,
      totalComparisons: totalComparisons,
      totalSwaps: totalSwaps,
    );
  }

  SortingResult _solveMergeSort(SortingProblem problem) {
    final steps = <SortingStep>[];
    final array = List<int>.from(problem.originalArray);
    final auxiliary = List<int>.from(array);
    final sortedIndices = <int>{};
    int totalComparisons = 0;
    int totalWrites = 0;

    void record(String description, {int? first, int? second, int? moving}) {
      steps.add(
        SortingStep(
          array: List<int>.from(array),
          comparingIndex1: first,
          comparingIndex2: second,
          movingIndex: moving,
          sortedIndices: Set<int>.from(sortedIndices),
          description: description,
        ),
      );
    }

    // Ranges use an exclusive end, so empty and singleton inputs need no merge.
    void sortRange(int start, int end) {
      if (end - start < 2) return;
      final middle = start + (end - start) ~/ 2;
      record(
        'Dividiendo posiciones $start-${end - 1} en '
        '$start-${middle - 1} y $middle-${end - 1}.',
      );
      sortRange(start, middle);
      sortRange(middle, end);
      record(
        'Fusionando las porciones ordenadas '
        '$start-${middle - 1} y $middle-${end - 1}.',
      );

      int left = start;
      int right = middle;
      for (int target = start; target < end; target++) {
        late int source;
        if (left < middle && right < end) {
          totalComparisons++;
          record(
            'Comparando ${array[left]} (posición $left) con '
            '${array[right]} (posición $right) para fusionar.',
            first: left,
            second: right,
          );
          // On equal values, prefer the left half to keep the merge stable.
          source = problem.order.comesBefore(array[right], array[left])
              ? right++
              : left++;
        } else {
          source = left < middle ? left++ : right++;
        }
        auxiliary[target] = array[source];
        record(
          'Tomando ${array[source]} de la posición $source '
          'para la posición $target del arreglo auxiliar.',
          moving: source,
        );
      }

      // Copy back only after comparisons, keeping their highlighted values valid.
      for (int target = start; target < end; target++) {
        array[target] = auxiliary[target];
        totalWrites++;
        // Only the final merge establishes definitive positions in the full array.
        if (start == 0 && end == array.length) sortedIndices.add(target);
        record(
          'Escribiendo ${array[target]} en la posición $target del arreglo.',
          moving: target,
        );
      }
      record(
        'Porción $start-${end - 1} fusionada: '
        '${array.sublist(start, end).join(', ')}.',
      );
    }

    record(
      'Merge Sort · ${problem.order.description}. '
      '${array.length} elementos por ordenar.',
    );
    sortRange(0, array.length);
    sortedIndices.addAll(List<int>.generate(array.length, (index) => index));
    record('¡Ordenamiento completado! ${problem.order.description}.');

    return SortingResult(
      steps: steps,
      totalComparisons: totalComparisons,
      // Shared movement counter: for Merge Sort it counts writes back to the array.
      totalSwaps: totalWrites,
    );
  }

  SortingResult _solveShellSort(SortingProblem problem) {
    final array = List<int>.from(problem.originalArray);
    final steps = <SortingStep>[];
    final sortedIndices = <int>{};
    int totalComparisons = 0;
    int totalShifts = 0;

    void record(String description, {int? comparing, int? moving}) {
      steps.add(
        SortingStep(
          array: List<int>.from(array),
          comparingIndex1: comparing,
          movingIndex: moving,
          sortedIndices: Set<int>.from(sortedIndices),
          description: description,
        ),
      );
    }

    record(
      'Shell Sort · ${problem.order.description}. '
      '${array.length} elementos por ordenar.',
    );

    // Knuth increments (3h + 1), as described in:
    // https://algs4.cs.princeton.edu/code/edu/princeton/cs/algs4/Shell.java.html
    int gap = array.length < 2 ? 0 : 1;
    while (gap > 0 && gap < array.length ~/ 3) {
      gap = 3 * gap + 1;
    }

    while (gap > 0) {
      record(
        'Salto h = $gap. Ordenando por inserción elementos '
        'separados por $gap posiciones.',
      );
      for (int i = gap; i < array.length; i++) {
        final key = array[i];
        int target = i;
        record('Salto h = $gap. Tomando $key de la posición $i.', moving: i);

        while (target >= gap) {
          final previous = target - gap;
          totalComparisons++;
          final shouldShift = problem.order.comesBefore(key, array[previous]);
          record(
            'Salto h = $gap. Comparando ${array[previous]} '
            '(posición $previous) con $key. '
            '${shouldShift ? 'Se desplaza para dejar espacio.' : 'La posición de inserción está lista.'}',
            comparing: previous,
            moving: target,
          );
          if (!shouldShift) break;

          array[target] = array[previous];
          totalShifts++;
          record(
            'Salto h = $gap. Desplazando ${array[target]} '
            'de la posición $previous a la posición $target.',
            moving: target,
          );
          target = previous;
        }

        array[target] = key;
        record(
          'Salto h = $gap. Insertando $key en la posición $target.',
          moving: target,
        );
      }
      record(
        'Pasada con salto h = $gap completada. '
        '${gap == 1 ? 'El arreglo está ordenado.' : 'Se reducirá el salto para continuar.'}',
      );
      gap ~/= 3;
    }

    // A gap-sorted subsequence does not establish final positions globally.
    sortedIndices.addAll(List<int>.generate(array.length, (index) => index));
    record('¡Ordenamiento completado! ${problem.order.description}.');
    return SortingResult(
      steps: steps,
      totalComparisons: totalComparisons,
      totalSwaps: totalShifts,
    );
  }
}

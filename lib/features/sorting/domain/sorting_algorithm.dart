/// Sorting algorithms and their complexity, excluding visualization snapshots.
enum SortingAlgorithm {
  selectionSort('Selection Sort'),
  insertionSort('Insertion Sort'),
  mergeSort('Merge Sort'),
  shellSort('Shell Sort');

  final String displayName;

  const SortingAlgorithm(this.displayName);

  String get bestCase => switch (this) {
    selectionSort => 'O(n²)',
    insertionSort => 'O(n)',
    mergeSort || shellSort => 'O(n log n)',
  };
  String get averageCase => switch (this) {
    selectionSort || insertionSort => 'O(n²)',
    mergeSort => 'O(n log n)',
    shellSort => 'No determinada para esta secuencia',
  };
  String get worstCase => switch (this) {
    selectionSort || insertionSort => 'O(n²)',
    mergeSort => 'O(n log n)',
    shellSort => 'O(n^(3/2))',
  };
  String get auxiliarySpace => this == mergeSort ? 'O(n)' : 'O(1)';
  String get movementLabel => switch (this) {
    selectionSort => 'Intercambios',
    insertionSort || shellSort => 'Desplazamientos',
    mergeSort => 'Escrituras',
  };
  String get complexityDescription => switch (this) {
    selectionSort =>
      'Busca el siguiente elemento en toda la porción pendiente, incluso '
          'cuando los datos ya están ordenados.',
    insertionSort =>
      'Si los datos ya siguen el orden elegido, solo necesita una pasada. '
          'Con muchos elementos fuera de lugar, el trabajo crece de forma cuadrática.',
    mergeSort =>
      'Divide el arreglo en mitades y fusiona las porciones ordenadas. '
          'Cada nivel recorre los elementos y hay una cantidad logarítmica de niveles. '
          'Usa un arreglo auxiliar de tamaño n.',
    shellSort =>
      'Ordena por inserción elementos separados por saltos de Knuth '
          '(1, 4, 13, …), que se recorren de mayor a menor hasta llegar a 1. '
          'Con esta secuencia, la cota del peor caso es O(n^(3/2)); '
          'el caso promedio no tiene una cota ajustada determinada.',
  };
}

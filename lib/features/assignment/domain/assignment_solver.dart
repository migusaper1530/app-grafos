import 'dart:math';

import 'assignment_problem.dart';
import 'assignment_result.dart';
import 'optimization_mode.dart';

/// Resuelve el problema de asignación con el método Húngaro.
///
/// Además del resultado, conserva cada transformación matricial para que la
/// interfaz pueda explicar el procedimiento completo.
class AssignmentSolver {
  const AssignmentSolver();

  static const _epsilon = 1e-9;

  AssignmentResult? solve(AssignmentProblem problem) {
    if (problem.origins.isEmpty || problem.destinations.isEmpty) return null;

    final originalRows = problem.origins.length;
    final originalColumns = problem.destinations.length;
    final size = max(originalRows, originalColumns);
    final rowLabels = [
      ...problem.origins.map((item) => item.label),
      for (var index = originalRows; index < size; index++)
        'Origen ficticio ${index - originalRows + 1}',
    ];
    final columnLabels = [
      ...problem.destinations.map((item) => item.label),
      for (var index = originalColumns; index < size; index++)
        'Destino ficticio ${index - originalColumns + 1}',
    ];

    final balancedCosts = List.generate(
      size,
      (row) => List.generate(size, (column) {
        if (row >= originalRows || column >= originalColumns) return 0.0;
        final value = problem.costFor(
          problem.origins[row].id,
          problem.destinations[column].id,
        );
        return value?.toDouble() ?? double.nan;
      }),
    );
    if (balancedCosts.expand((row) => row).any((value) => value.isNaN)) {
      return null;
    }

    final steps = <AssignmentMatrixStep>[
      AssignmentMatrixStep(
        title:
            'Matriz inicial${size == originalRows && size == originalColumns ? '' : ' balanceada'}',
        description: size == originalRows && size == originalColumns
            ? 'La matriz ya es cuadrada y puede procesarse directamente.'
            : 'Se agregan filas o columnas ficticias con valor cero para obtener una matriz cuadrada.',
        matrix: balancedCosts,
        matrixSymbol: 'A',
        equations: [
          'n = max($originalRows, $originalColumns) = $size',
          if (size != originalRows || size != originalColumns)
            'costo de cada celda ficticia = 0',
        ],
      ),
    ];

    var working = _copyMatrix(balancedCosts);
    var baseSymbol = 'A';
    if (problem.mode == OptimizationMode.maximize) {
      working = [
        for (final row in working) [for (final value in row) -value],
      ];
      baseSymbol = 'B';
      steps.add(
        AssignmentMatrixStep(
          title: 'Transformación para maximizar: B = −A',
          description: 'Como en el procedimiento de clase, se cambia el signo de todos los beneficios antes de reducir la matriz.',
          matrix: working,
          matrixSymbol: 'B',
          equations: [
            'B = −A',
            'bij = −aij',
            'b11 = −(${_format(balancedCosts.first.first)}) = ${_format(working.first.first)}',
          ],
        ),
      );
    }

    final alpha = <double>[];
    final rowEquations = <String>[];
    for (var row = 0; row < size; row++) {
      final minimum = working[row].reduce(min);
      alpha.add(minimum);
      rowEquations.add(
        'α${row + 1} = min(${working[row].map(_format).join(', ')}) = ${_format(minimum)}',
      );
      for (var column = 0; column < size; column++) {
        working[row][column] -= minimum;
      }
    }
    steps.add(
      AssignmentMatrixStep(
        title: 'Vector α y matriz $baseSymbol − α',
        description: 'Se toma el menor valor de cada fila para formar α y se resta de toda su fila.',
        matrix: working,
        matrixSymbol: '$baseSymbol − α',
        alphaVector: alpha,
        equations: [
          'α = [${alpha.map(_format).join(', ')}]',
          ...rowEquations,
          "${baseSymbol.toLowerCase()}'ij = ${baseSymbol.toLowerCase()}ij − αi",
        ],
      ),
    );

    final beta = <double>[];
    final columnEquations = <String>[];
    for (var column = 0; column < size; column++) {
      var minimum = working.first[column];
      for (var row = 1; row < size; row++) {
        minimum = min(minimum, working[row][column]);
      }
      beta.add(minimum);
      columnEquations.add(
        'β${column + 1} = mínimo de ${columnLabels[column]} = ${_format(minimum)}',
      );
      for (var row = 0; row < size; row++) {
        working[row][column] -= minimum;
      }
    }
    steps.add(
      AssignmentMatrixStep(
        title: 'Vector β y matriz $baseSymbol − α − β',
        description: 'Se toma el menor valor de cada columna para formar β y se completa la matriz reducida.',
        matrix: working,
        matrixSymbol: '$baseSymbol − α − β',
        alphaVector: alpha,
        betaVector: beta,
        equations: [
          'β = [${beta.map(_format).join(', ')}]',
          ...columnEquations,
          "r''ij = r'ij − βj",
        ],
      ),
    );

    List<int>? assignment;
    for (var iteration = 0; iteration < size * size * 4; iteration++) {
      final matching = _maximumZeroMatching(working);
      if (matching.matchedCount == size) {
        assignment = matching.rowToColumn;
        break;
      }

      final cover = _minimumZeroCover(working, matching);
      steps.add(
        AssignmentMatrixStep(
          title: 'Cobertura mínima de ceros',
          description:
              'Todavía no existen $size ceros independientes. Se cubren todos los ceros con el menor número de líneas.',
          matrix: working,
          matrixSymbol: '$baseSymbol − α − β',
          coveredRows: cover.coveredRows,
          coveredColumns: cover.coveredColumns,
          equations: [
            'ceros independientes = ${matching.matchedCount}',
            'líneas usadas = ${cover.coveredRows.length + cover.coveredColumns.length}',
            'se necesitan $size asignaciones independientes',
          ],
        ),
      );

      double? smallestUncovered;
      for (var row = 0; row < size; row++) {
        if (cover.coveredRows.contains(row)) continue;
        for (var column = 0; column < size; column++) {
          if (cover.coveredColumns.contains(column)) continue;
          final value = working[row][column];
          if (smallestUncovered == null || value < smallestUncovered) {
            smallestUncovered = value;
          }
        }
      }
      if (smallestUncovered == null || smallestUncovered.abs() < _epsilon) {
        return null;
      }

      for (var row = 0; row < size; row++) {
        for (var column = 0; column < size; column++) {
          final rowCovered = cover.coveredRows.contains(row);
          final columnCovered = cover.coveredColumns.contains(column);
          if (!rowCovered && !columnCovered) {
            working[row][column] -= smallestUncovered;
          } else if (rowCovered && columnCovered) {
            working[row][column] += smallestUncovered;
          }
          if (working[row][column].abs() < _epsilon) {
            working[row][column] = 0;
          }
        }
      }
      steps.add(
        AssignmentMatrixStep(
          title: 'Ajuste de la matriz',
          description: 'Se resta el menor valor no cubierto y se suma en las intersecciones de dos líneas.',
          matrix: working,
          matrixSymbol: 'Matriz ajustada',
          equations: [
            'k = menor valor no cubierto = ${_format(smallestUncovered)}',
            'celda no cubierta: cij ← cij - k',
            'intersección de líneas: cij ← cij + k',
          ],
        ),
      );
    }
    if (assignment == null) return null;

    final allZeroAssignments = _enumerateZeroAssignments(working);
    final alternatives = [
      for (final candidate in allZeroAssignments)
        if (!_sameAssignment(candidate, assignment)) candidate,
    ];

    final matches = <AssignmentMatch>[];
    final highlighted = <AssignmentCell>[];
    for (var row = 0; row < size; row++) {
      final column = assignment[row];
      highlighted.add(AssignmentCell(row, column));
      if (row >= originalRows || column >= originalColumns) continue;
      final value = problem.costFor(
        problem.origins[row].id,
        problem.destinations[column].id,
      );
      if (value == null) return null;
      matches.add(
        AssignmentMatch(
          origin: problem.origins[row],
          destination: problem.destinations[column],
          value: value,
        ),
      );
    }
    steps.add(
      AssignmentMatrixStep(
        title: 'Asignación final',
        description: 'Se elige un cero independiente por fila y por columna. Las posiciones resaltadas forman la solución.',
        matrix: working,
        matrixSymbol: '$baseSymbol − α − β',
        highlightedCells: highlighted,
        equations: [
          for (final match in matches)
            '${match.origin.label} → ${match.destination.label}: ${_format(match.value.toDouble())}',
          'Z = ${matches.map((match) => _format(match.value.toDouble())).join(' + ')} = ${_format(matches.fold<num>(0, (sum, match) => sum + match.value).toDouble())}',
        ],
      ),
    );

    return AssignmentResult(
      matches: matches,
      balancedCosts: balancedCosts,
      assignmentColumns: assignment,
      alternativeAssignmentColumns: alternatives,
      rowLabels: rowLabels,
      columnLabels: columnLabels,
      steps: steps,
      addedDummyRows: size - originalRows,
      addedDummyColumns: size - originalColumns,
    );
  }

  List<List<double>> _copyMatrix(List<List<double>> matrix) => [
    for (final row in matrix) List<double>.from(row),
  ];

  _Matching _maximumZeroMatching(List<List<double>> matrix) {
    final size = matrix.length;
    final columnToRow = List<int>.filled(size, -1);

    bool augment(int row, List<bool> visitedColumns) {
      for (var column = 0; column < size; column++) {
        if (matrix[row][column].abs() >= _epsilon || visitedColumns[column]) {
          continue;
        }
        visitedColumns[column] = true;
        if (columnToRow[column] == -1 ||
            augment(columnToRow[column], visitedColumns)) {
          columnToRow[column] = row;
          return true;
        }
      }
      return false;
    }

    var matchedCount = 0;
    for (var row = 0; row < size; row++) {
      if (augment(row, List<bool>.filled(size, false))) matchedCount++;
    }
    final rowToColumn = List<int>.filled(size, -1);
    for (var column = 0; column < size; column++) {
      if (columnToRow[column] >= 0) {
        rowToColumn[columnToRow[column]] = column;
      }
    }
    return _Matching(
      rowToColumn: rowToColumn,
      columnToRow: columnToRow,
      matchedCount: matchedCount,
    );
  }

  _ZeroCover _minimumZeroCover(List<List<double>> matrix, _Matching matching) {
    final size = matrix.length;
    final visitedRows = <int>{};
    final visitedColumns = <int>{};
    final queue = <int>[];
    for (var row = 0; row < size; row++) {
      if (matching.rowToColumn[row] == -1) {
        visitedRows.add(row);
        queue.add(row);
      }
    }

    var cursor = 0;
    while (cursor < queue.length) {
      final row = queue[cursor++];
      for (var column = 0; column < size; column++) {
        final isUnmatchedZero =
            matrix[row][column].abs() < _epsilon &&
            matching.rowToColumn[row] != column;
        if (!isUnmatchedZero || !visitedColumns.add(column)) continue;
        final matchedRow = matching.columnToRow[column];
        if (matchedRow >= 0 && visitedRows.add(matchedRow)) {
          queue.add(matchedRow);
        }
      }
    }

    return _ZeroCover(
      coveredRows: {
        for (var row = 0; row < size; row++)
          if (!visitedRows.contains(row)) row,
      },
      coveredColumns: visitedColumns,
    );
  }

  List<List<int>> _enumerateZeroAssignments(
    List<List<double>> matrix, {
    int limit = 50,
  }) {
    final size = matrix.length;
    final assignments = <List<int>>[];
    final current = List<int>.filled(size, -1);
    final usedColumns = List<bool>.filled(size, false);

    void search(int row) {
      if (assignments.length >= limit) return;
      if (row == size) {
        assignments.add(List<int>.from(current));
        return;
      }
      for (var column = 0; column < size; column++) {
        if (usedColumns[column] || matrix[row][column].abs() >= _epsilon) {
          continue;
        }
        usedColumns[column] = true;
        current[row] = column;
        search(row + 1);
        current[row] = -1;
        usedColumns[column] = false;
      }
    }

    search(0);
    return assignments;
  }

  bool _sameAssignment(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  }
}

class _Matching {
  const _Matching({
    required this.rowToColumn,
    required this.columnToRow,
    required this.matchedCount,
  });

  final List<int> rowToColumn;
  final List<int> columnToRow;
  final int matchedCount;
}

class _ZeroCover {
  const _ZeroCover({required this.coveredRows, required this.coveredColumns});

  final Set<int> coveredRows;
  final Set<int> coveredColumns;
}

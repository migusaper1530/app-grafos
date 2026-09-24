import 'dart:collection';
import 'dart:math';

import 'northwest_corner_result.dart';
import 'transportation_problem.dart';

/// Genera la solución inicial por Esquina Noroeste y la mejora mediante
/// potenciales y ciclos cerrados con signos +α y −α.
class NorthwestCornerSolver {
  const NorthwestCornerSolver();

  static const _epsilon = 1e-9;

  NorthwestCornerResult solve(TransportationProblem problem) {
    _validate(problem);

    final costs = problem.costs
        .map((row) => row.map((value) => value.toDouble()).toList())
        .toList();
    final supply = problem.supply.map((value) => value.toDouble()).toList();
    final demand = problem.demand.map((value) => value.toDouble()).toList();
    final origins = List<String>.from(problem.originLabels);
    final destinations = List<String>.from(problem.destinationLabels);

    final totalSupply = supply.fold<double>(0, (sum, value) => sum + value);
    final totalDemand = demand.fold<double>(0, (sum, value) => sum + value);
    var addedDummyOrigin = false;
    var addedDummyDestination = false;

    if (totalSupply > totalDemand + _epsilon) {
      final difference = totalSupply - totalDemand;
      demand.add(difference);
      destinations.add('Destino ficticio');
      for (final row in costs) {
        row.add(0);
      }
      addedDummyDestination = true;
    } else if (totalDemand > totalSupply + _epsilon) {
      final difference = totalDemand - totalSupply;
      supply.add(difference);
      origins.add('Origen ficticio');
      costs.add(List<double>.filled(demand.length, 0));
      addedDummyOrigin = true;
    }

    final balancedSupply = List<double>.from(supply);
    final balancedDemand = List<double>.from(demand);
    final remainingSupply = List<double>.from(supply);
    final remainingDemand = List<double>.from(demand);
    final allocations = List.generate(
      supply.length,
      (_) => List<double>.filled(demand.length, 0),
    );
    final basis = <TransportationCell>{};
    final steps = <NorthwestCornerStep>[];

    var row = 0;
    var column = 0;
    var accumulatedCost = 0.0;
    while (row < supply.length && column < demand.length) {
      final availableSupply = remainingSupply[row];
      final pendingDemand = remainingDemand[column];
      final allocated = min(availableSupply, pendingDemand);
      allocations[row][column] = allocated;
      basis.add(TransportationCell(row, column));
      remainingSupply[row] -= allocated;
      remainingDemand[column] -= allocated;

      if (remainingSupply[row].abs() < _epsilon) remainingSupply[row] = 0;
      if (remainingDemand[column].abs() < _epsilon) {
        remainingDemand[column] = 0;
      }

      final previousCost = accumulatedCost;
      accumulatedCost += allocated * costs[row][column];
      steps.add(
        NorthwestCornerStep(
          row: row,
          column: column,
          originLabel: origins[row],
          destinationLabel: destinations[column],
          availableSupply: availableSupply,
          pendingDemand: pendingDemand,
          allocated: allocated,
          unitCost: costs[row][column],
          remainingSupply: remainingSupply[row],
          remainingDemand: remainingDemand[column],
          previousCost: previousCost,
          accumulatedCost: accumulatedCost,
          allocationsSnapshot: allocations,
          remainingSupplySnapshot: remainingSupply,
          remainingDemandSnapshot: remainingDemand,
        ),
      );

      final exhaustedSupply = remainingSupply[row] == 0;
      final exhaustedDemand = remainingDemand[column] == 0;
      if (exhaustedSupply) row++;
      if (exhaustedDemand) column++;
    }

    _completeBasis(basis, supply.length, demand.length);
    final initialAllocations = _copyMatrix(allocations);
    final initialCost = _totalCost(costs, allocations);
    final optimizationSteps = <TransportationOptimizationStep>[];
    final visitedBases = <String>{_basisSignature(basis)};
    var isOptimal = false;

    final maximumIterations = supply.length * demand.length * 12;
    for (var iteration = 1; iteration <= maximumIterations; iteration++) {
      final evaluation = _evaluate(costs, basis, problem.mode);
      final candidates = <_Candidate>[];
      for (var candidateRow = 0; candidateRow < supply.length; candidateRow++) {
        for (
          var candidateColumn = 0;
          candidateColumn < demand.length;
          candidateColumn++
        ) {
          final indicator =
              evaluation.opportunityCosts[candidateRow][candidateColumn];
          if (indicator != null && indicator > _epsilon) {
            candidates.add(
              _Candidate(
                cell: TransportationCell(candidateRow, candidateColumn),
                indicator: indicator,
              ),
            );
          }
        }
      }
      candidates.sort((a, b) {
        final byIndicator = b.indicator.compareTo(a.indicator);
        if (byIndicator != 0) return byIndicator;
        final byRow = a.cell.row.compareTo(b.cell.row);
        return byRow != 0 ? byRow : a.cell.column.compareTo(b.cell.column);
      });

      if (candidates.isEmpty) {
        isOptimal = true;
        break;
      }

      _Pivot? pivot;
      for (final candidate in candidates) {
        final cycle = _buildCycle(
          basis,
          candidate.cell,
          supply.length,
          demand.length,
        );
        final subtractCells = [
          for (var index = 1; index < cycle.length; index += 2) cycle[index],
        ];
        final alpha = subtractCells
            .map((cell) => allocations[cell.row][cell.column])
            .reduce(min);
        final leavingCandidates =
            subtractCells
                .where(
                  (cell) =>
                      (allocations[cell.row][cell.column] - alpha).abs() <
                      _epsilon,
                )
                .toList()
              ..sort((a, b) {
                final byRow = a.row.compareTo(b.row);
                return byRow != 0 ? byRow : a.column.compareTo(b.column);
              });

        for (final leaving in leavingCandidates) {
          final nextBasis = Set<TransportationCell>.from(basis)
            ..add(candidate.cell)
            ..remove(leaving);
          final signature = _basisSignature(nextBasis);
          if (!visitedBases.contains(signature)) {
            pivot = _Pivot(
              candidate: candidate,
              cycle: cycle,
              alpha: alpha,
              leavingCell: leaving,
              nextBasis: nextBasis,
              signature: signature,
            );
            break;
          }
        }
        if (pivot != null) break;
      }

      if (pivot == null) break;
      final before = _copyMatrix(allocations);
      final previousCost = _totalCost(costs, before);
      for (var index = 0; index < pivot.cycle.length; index++) {
        final cell = pivot.cycle[index];
        allocations[cell.row][cell.column] += index.isEven
            ? pivot.alpha
            : -pivot.alpha;
        if (allocations[cell.row][cell.column].abs() < _epsilon) {
          allocations[cell.row][cell.column] = 0;
        }
      }
      basis
        ..clear()
        ..addAll(pivot.nextBasis);
      visitedBases.add(pivot.signature);
      final resultingCost = _totalCost(costs, allocations);
      optimizationSteps.add(
        TransportationOptimizationStep(
          iteration: iteration,
          allocationsBefore: before,
          allocationsAfter: allocations,
          rowPotentials: evaluation.rowPotentials,
          columnPotentials: evaluation.columnPotentials,
          opportunityCosts: evaluation.opportunityCosts,
          enteringCell: pivot.candidate.cell,
          leavingCell: pivot.leavingCell,
          cycle: [
            for (var index = 0; index < pivot.cycle.length; index++)
              TransportationCycleCell(
                pivot.cycle[index].row,
                pivot.cycle[index].column,
                add: index.isEven,
              ),
          ],
          alpha: pivot.alpha,
          indicator: pivot.candidate.indicator,
          previousCost: previousCost,
          resultingCost: resultingCost,
        ),
      );
    }

    final finalEvaluation = _evaluate(costs, basis, problem.mode);
    if (!isOptimal) {
      isOptimal = finalEvaluation.opportunityCosts
          .expand((row) => row)
          .whereType<double>()
          .every((value) => value <= _epsilon);
    }

    return NorthwestCornerResult(
      costs: costs,
      initialAllocations: initialAllocations,
      allocations: allocations,
      balancedSupply: balancedSupply,
      balancedDemand: balancedDemand,
      originLabels: origins,
      destinationLabels: destinations,
      steps: steps,
      optimizationSteps: optimizationSteps,
      finalRowPotentials: finalEvaluation.rowPotentials,
      finalColumnPotentials: finalEvaluation.columnPotentials,
      finalOpportunityCosts: finalEvaluation.opportunityCosts,
      initialCost: initialCost,
      totalCost: _totalCost(costs, allocations),
      mode: problem.mode,
      isOptimal: isOptimal,
      addedDummyOrigin: addedDummyOrigin,
      addedDummyDestination: addedDummyDestination,
    );
  }

  void _completeBasis(Set<TransportationCell> basis, int rows, int columns) {
    final unionFind = _UnionFind(rows + columns);
    final validBasis = <TransportationCell>{};
    final ordered = basis.toList()
      ..sort((a, b) {
        final byRow = a.row.compareTo(b.row);
        return byRow != 0 ? byRow : a.column.compareTo(b.column);
      });
    for (final cell in ordered) {
      if (unionFind.union(cell.row, rows + cell.column)) {
        validBasis.add(cell);
      }
    }
    for (
      var row = 0;
      row < rows && validBasis.length < rows + columns - 1;
      row++
    ) {
      for (
        var column = 0;
        column < columns && validBasis.length < rows + columns - 1;
        column++
      ) {
        final cell = TransportationCell(row, column);
        if (validBasis.contains(cell)) continue;
        if (unionFind.union(row, rows + column)) validBasis.add(cell);
      }
    }
    basis
      ..clear()
      ..addAll(validBasis);
  }

  _Evaluation _evaluate(
    List<List<double>> costs,
    Set<TransportationCell> basis,
    TransportationOptimizationMode mode,
  ) {
    final rows = costs.length;
    final columns = costs.first.length;
    final rowPotentials = List<double?>.filled(rows, null);
    final columnPotentials = List<double?>.filled(columns, null);
    rowPotentials[0] = 0;

    var changed = true;
    while (changed) {
      changed = false;
      for (final cell in basis) {
        final rowValue = rowPotentials[cell.row];
        final columnValue = columnPotentials[cell.column];
        if (rowValue != null && columnValue == null) {
          columnPotentials[cell.column] =
              costs[cell.row][cell.column] - rowValue;
          changed = true;
        } else if (rowValue == null && columnValue != null) {
          rowPotentials[cell.row] = costs[cell.row][cell.column] - columnValue;
          changed = true;
        }
      }
    }
    final resolvedRows = rowPotentials.map((value) => value ?? 0).toList();
    final resolvedColumns = columnPotentials
        .map((value) => value ?? 0)
        .toList();
    final opportunityCosts = List.generate(rows, (row) {
      return List<double?>.generate(columns, (column) {
        if (basis.contains(TransportationCell(row, column))) return null;
        final zij = resolvedRows[row] + resolvedColumns[column];
        return mode == TransportationOptimizationMode.minimize
            ? zij - costs[row][column]
            : costs[row][column] - zij;
      });
    });
    return _Evaluation(
      rowPotentials: resolvedRows,
      columnPotentials: resolvedColumns,
      opportunityCosts: opportunityCosts,
    );
  }

  List<TransportationCell> _buildCycle(
    Set<TransportationCell> basis,
    TransportationCell entering,
    int rows,
    int columns,
  ) {
    final nodeCount = rows + columns;
    final adjacency = List.generate(nodeCount, (_) => <_BasisLink>[]);
    for (final cell in basis) {
      final rowNode = cell.row;
      final columnNode = rows + cell.column;
      adjacency[rowNode].add(_BasisLink(columnNode, cell));
      adjacency[columnNode].add(_BasisLink(rowNode, cell));
    }

    final start = entering.row;
    final target = rows + entering.column;
    final parent = List<int>.filled(nodeCount, -1);
    final parentCell = List<TransportationCell?>.filled(nodeCount, null);
    final queue = Queue<int>()..add(start);
    parent[start] = start;
    while (queue.isNotEmpty && parent[target] == -1) {
      final node = queue.removeFirst();
      for (final link in adjacency[node]) {
        if (parent[link.node] != -1) continue;
        parent[link.node] = node;
        parentCell[link.node] = link.cell;
        queue.add(link.node);
      }
    }
    if (parent[target] == -1) {
      throw const FormatException(
        'No se pudo construir el circuito cerrado de transporte.',
      );
    }

    final cycle = <TransportationCell>[entering];
    var current = target;
    while (current != start) {
      cycle.add(parentCell[current]!);
      current = parent[current];
    }
    if (cycle.length.isOdd) {
      throw const FormatException('El circuito de transporte no es válido.');
    }
    return cycle;
  }

  double _totalCost(List<List<double>> costs, List<List<double>> allocations) {
    var total = 0.0;
    for (var row = 0; row < costs.length; row++) {
      for (var column = 0; column < costs[row].length; column++) {
        total += costs[row][column] * allocations[row][column];
      }
    }
    return total;
  }

  List<List<double>> _copyMatrix(List<List<double>> matrix) => [
    for (final row in matrix) List<double>.from(row),
  ];

  String _basisSignature(Set<TransportationCell> basis) {
    final cells = basis.toList()
      ..sort((a, b) {
        final byRow = a.row.compareTo(b.row);
        return byRow != 0 ? byRow : a.column.compareTo(b.column);
      });
    return cells.map((cell) => '${cell.row}:${cell.column}').join('|');
  }

  void _validate(TransportationProblem problem) {
    if (problem.supply.isEmpty || problem.demand.isEmpty) {
      throw const FormatException(
        'Debe existir al menos un origen y un destino.',
      );
    }
    if (problem.costs.length != problem.supply.length ||
        problem.costs.any((row) => row.length != problem.demand.length)) {
      throw const FormatException(
        'La matriz de costos no coincide con la oferta y la demanda.',
      );
    }
    if (problem.originLabels.length != problem.supply.length ||
        problem.destinationLabels.length != problem.demand.length) {
      throw const FormatException('Las etiquetas no coinciden con la matriz.');
    }
    final values = [
      ...problem.supply,
      ...problem.demand,
      ...problem.costs.expand((row) => row),
    ];
    if (values.any((value) => !value.isFinite || value < 0)) {
      throw const FormatException(
        'Los costos, la oferta y la demanda deben ser números no negativos.',
      );
    }
  }
}

class _Evaluation {
  const _Evaluation({
    required this.rowPotentials,
    required this.columnPotentials,
    required this.opportunityCosts,
  });

  final List<double> rowPotentials;
  final List<double> columnPotentials;
  final List<List<double?>> opportunityCosts;
}

class _Candidate {
  const _Candidate({required this.cell, required this.indicator});

  final TransportationCell cell;
  final double indicator;
}

class _Pivot {
  const _Pivot({
    required this.candidate,
    required this.cycle,
    required this.alpha,
    required this.leavingCell,
    required this.nextBasis,
    required this.signature,
  });

  final _Candidate candidate;
  final List<TransportationCell> cycle;
  final double alpha;
  final TransportationCell leavingCell;
  final Set<TransportationCell> nextBasis;
  final String signature;
}

class _BasisLink {
  const _BasisLink(this.node, this.cell);

  final int node;
  final TransportationCell cell;
}

class _UnionFind {
  _UnionFind(int size) : _parent = List.generate(size, (index) => index);

  final List<int> _parent;

  int _find(int value) {
    if (_parent[value] != value) _parent[value] = _find(_parent[value]);
    return _parent[value];
  }

  bool union(int first, int second) {
    final firstRoot = _find(first);
    final secondRoot = _find(second);
    if (firstRoot == secondRoot) return false;
    _parent[secondRoot] = firstRoot;
    return true;
  }
}

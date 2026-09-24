import 'transportation_problem.dart';

class TransportationCell {
  const TransportationCell(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) =>
      other is TransportationCell && row == other.row && column == other.column;

  @override
  int get hashCode => Object.hash(row, column);
}

class TransportationCycleCell extends TransportationCell {
  const TransportationCycleCell(super.row, super.column, {required this.add});

  final bool add;
}

class NorthwestCornerStep {
  NorthwestCornerStep({
    required this.row,
    required this.column,
    required this.originLabel,
    required this.destinationLabel,
    required this.availableSupply,
    required this.pendingDemand,
    required this.allocated,
    required this.unitCost,
    required this.remainingSupply,
    required this.remainingDemand,
    required this.previousCost,
    required this.accumulatedCost,
    required List<List<double>> allocationsSnapshot,
    required List<double> remainingSupplySnapshot,
    required List<double> remainingDemandSnapshot,
  }) : allocationsSnapshot = _freezeMatrix(allocationsSnapshot),
       remainingSupplySnapshot = List.unmodifiable(remainingSupplySnapshot),
       remainingDemandSnapshot = List.unmodifiable(remainingDemandSnapshot);

  final int row;
  final int column;
  final String originLabel;
  final String destinationLabel;
  final double availableSupply;
  final double pendingDemand;
  final double allocated;
  final double unitCost;
  final double remainingSupply;
  final double remainingDemand;
  final double previousCost;
  final double accumulatedCost;
  final List<List<double>> allocationsSnapshot;
  final List<double> remainingSupplySnapshot;
  final List<double> remainingDemandSnapshot;
}

class TransportationOptimizationStep {
  TransportationOptimizationStep({
    required this.iteration,
    required List<List<double>> allocationsBefore,
    required List<List<double>> allocationsAfter,
    required List<double> rowPotentials,
    required List<double> columnPotentials,
    required List<List<double?>> opportunityCosts,
    required this.enteringCell,
    required this.leavingCell,
    required List<TransportationCycleCell> cycle,
    required this.alpha,
    required this.indicator,
    required this.previousCost,
    required this.resultingCost,
  }) : allocationsBefore = _freezeMatrix(allocationsBefore),
       allocationsAfter = _freezeMatrix(allocationsAfter),
       rowPotentials = List.unmodifiable(rowPotentials),
       columnPotentials = List.unmodifiable(columnPotentials),
       opportunityCosts = List.unmodifiable(
         opportunityCosts.map((row) => List<double?>.unmodifiable(row)),
       ),
       cycle = List.unmodifiable(cycle);

  final int iteration;
  final List<List<double>> allocationsBefore;
  final List<List<double>> allocationsAfter;
  final List<double> rowPotentials;
  final List<double> columnPotentials;
  final List<List<double?>> opportunityCosts;
  final TransportationCell enteringCell;
  final TransportationCell leavingCell;
  final List<TransportationCycleCell> cycle;
  final double alpha;
  final double indicator;
  final double previousCost;
  final double resultingCost;
}

class NorthwestCornerResult {
  NorthwestCornerResult({
    required List<List<double>> costs,
    required List<List<double>> initialAllocations,
    required List<List<double>> allocations,
    required List<double> balancedSupply,
    required List<double> balancedDemand,
    required List<String> originLabels,
    required List<String> destinationLabels,
    required List<NorthwestCornerStep> steps,
    required List<TransportationOptimizationStep> optimizationSteps,
    required List<double> finalRowPotentials,
    required List<double> finalColumnPotentials,
    required List<List<double?>> finalOpportunityCosts,
    required this.initialCost,
    required this.totalCost,
    required this.mode,
    required this.isOptimal,
    required this.addedDummyOrigin,
    required this.addedDummyDestination,
  }) : costs = _freezeMatrix(costs),
       initialAllocations = _freezeMatrix(initialAllocations),
       allocations = _freezeMatrix(allocations),
       balancedSupply = List.unmodifiable(balancedSupply),
       balancedDemand = List.unmodifiable(balancedDemand),
       originLabels = List.unmodifiable(originLabels),
       destinationLabels = List.unmodifiable(destinationLabels),
       steps = List.unmodifiable(steps),
       optimizationSteps = List.unmodifiable(optimizationSteps),
       finalRowPotentials = List.unmodifiable(finalRowPotentials),
       finalColumnPotentials = List.unmodifiable(finalColumnPotentials),
       finalOpportunityCosts = List.unmodifiable(
         finalOpportunityCosts.map((row) => List<double?>.unmodifiable(row)),
       );

  final List<List<double>> costs;
  final List<List<double>> initialAllocations;
  final List<List<double>> allocations;
  final List<double> balancedSupply;
  final List<double> balancedDemand;
  final List<String> originLabels;
  final List<String> destinationLabels;
  final List<NorthwestCornerStep> steps;
  final List<TransportationOptimizationStep> optimizationSteps;
  final List<double> finalRowPotentials;
  final List<double> finalColumnPotentials;
  final List<List<double?>> finalOpportunityCosts;
  final double initialCost;
  final double totalCost;
  final TransportationOptimizationMode mode;
  final bool isOptimal;
  final bool addedDummyOrigin;
  final bool addedDummyDestination;

  bool get wasBalanced => addedDummyOrigin || addedDummyDestination;

  bool get wasImproved => optimizationSteps.isNotEmpty;

  double get totalUnits =>
      allocations.expand((row) => row).fold(0, (sum, value) => sum + value);
}

List<List<double>> _freezeMatrix(List<List<double>> matrix) =>
    List.unmodifiable(matrix.map((row) => List<double>.unmodifiable(row)));

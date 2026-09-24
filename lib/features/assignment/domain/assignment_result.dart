import 'assignment_problem.dart';

class AssignmentMatch {
  const AssignmentMatch({
    required this.origin,
    required this.destination,
    required this.value,
  });

  final AssignmentItem origin;
  final AssignmentItem destination;
  final num value;
}

class AssignmentCell {
  const AssignmentCell(this.row, this.column);

  final int row;
  final int column;
}

class AssignmentMatrixStep {
  AssignmentMatrixStep({
    required this.title,
    required this.description,
    required List<List<double>> matrix,
    List<String> equations = const [],
    Set<int> coveredRows = const {},
    Set<int> coveredColumns = const {},
    List<AssignmentCell> highlightedCells = const [],
    List<double>? alphaVector,
    List<double>? betaVector,
    this.matrixSymbol,
  }) : matrix = List.unmodifiable(
         matrix.map((row) => List<double>.unmodifiable(row)),
       ),
       equations = List.unmodifiable(equations),
       coveredRows = Set.unmodifiable(coveredRows),
       coveredColumns = Set.unmodifiable(coveredColumns),
       highlightedCells = List.unmodifiable(highlightedCells),
       alphaVector = alphaVector == null
           ? null
           : List.unmodifiable(alphaVector),
       betaVector = betaVector == null ? null : List.unmodifiable(betaVector);

  final String title;
  final String description;
  final List<List<double>> matrix;
  final List<String> equations;
  final Set<int> coveredRows;
  final Set<int> coveredColumns;
  final List<AssignmentCell> highlightedCells;
  final List<double>? alphaVector;
  final List<double>? betaVector;
  final String? matrixSymbol;
}

class AssignmentResult {
  AssignmentResult({
    required List<AssignmentMatch> matches,
    required List<List<double>> balancedCosts,
    required List<int> assignmentColumns,
    List<List<int>> alternativeAssignmentColumns = const [],
    required List<String> rowLabels,
    required List<String> columnLabels,
    required List<AssignmentMatrixStep> steps,
    required this.addedDummyRows,
    required this.addedDummyColumns,
  }) : matches = List.unmodifiable(matches),
       total = matches.fold<num>(0, (sum, match) => sum + match.value),
       balancedCosts = List.unmodifiable(
         balancedCosts.map((row) => List<double>.unmodifiable(row)),
       ),
       assignmentColumns = List.unmodifiable(assignmentColumns),
       alternativeAssignmentColumns = List.unmodifiable(
         alternativeAssignmentColumns.map(
           (value) => List<int>.unmodifiable(value),
         ),
       ),
       rowLabels = List.unmodifiable(rowLabels),
       columnLabels = List.unmodifiable(columnLabels),
       steps = List.unmodifiable(steps);

  final List<AssignmentMatch> matches;
  final num total;
  final List<List<double>> balancedCosts;
  final List<int> assignmentColumns;
  final List<List<int>> alternativeAssignmentColumns;
  final List<String> rowLabels;
  final List<String> columnLabels;
  final List<AssignmentMatrixStep> steps;
  final int addedDummyRows;
  final int addedDummyColumns;

  bool get wasBalanced => addedDummyRows > 0 || addedDummyColumns > 0;
}

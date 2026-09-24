import 'package:flutter/material.dart';

import '../../../shared/presentation/algorithm_graph.dart';
import '../../../shared/presentation/algorithm_widgets.dart';
import '../domain/assignment_problem.dart';
import '../domain/assignment_result.dart';
import '../domain/assignment_solver.dart';
import '../domain/optimization_mode.dart';

class AssignmentMatrixScreen extends StatefulWidget {
  const AssignmentMatrixScreen({super.key});

  @override
  State<AssignmentMatrixScreen> createState() => _AssignmentMatrixScreenState();
}

class _AssignmentMatrixScreenState extends State<AssignmentMatrixScreen> {
  static const _solver = AssignmentSolver();
  static const _accent = Color(0xFF6366F1);
  static const _ink = Color(0xFF0F172A);

  late List<List<TextEditingController>> _controllers;
  OptimizationMode _mode = OptimizationMode.minimize;
  AssignmentResult? _result;
  AlgorithmSolutionView _solutionView = AlgorithmSolutionView.table;

  int get _rows => _controllers.length;
  int get _columns => _controllers.first.length;

  @override
  void initState() {
    super.initState();
    _initializeExample();
  }

  void _initializeExample() {
    const values = [
      ['9', '2', '7'],
      ['6', '4', '3'],
      ['5', '8', '1'],
    ];
    _controllers = values
        .map(
          (row) =>
              row.map((value) => TextEditingController(text: value)).toList(),
        )
        .toList();
    _mode = OptimizationMode.minimize;
  }

  void _disposeControllers() {
    for (final row in _controllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _loadExample() {
    _disposeControllers();
    _initializeExample();
    setState(() => _result = null);
  }

  void _clear() {
    for (final row in _controllers) {
      for (final controller in row) {
        controller.clear();
      }
    }
    setState(() => _result = null);
  }

  void _changeRows(int delta) {
    if (delta > 0 && _rows >= 6 || delta < 0 && _rows <= 2) return;
    setState(() {
      if (delta > 0) {
        _controllers.add(
          List.generate(_columns, (_) => TextEditingController()),
        );
      } else {
        for (final controller in _controllers.removeLast()) {
          controller.dispose();
        }
      }
      _result = null;
    });
  }

  void _changeColumns(int delta) {
    if (delta > 0 && _columns >= 6 || delta < 0 && _columns <= 2) return;
    setState(() {
      if (delta > 0) {
        for (final row in _controllers) {
          row.add(TextEditingController());
        }
      } else {
        for (final row in _controllers) {
          row.removeLast().dispose();
        }
      }
      _result = null;
    });
  }

  double _read(TextEditingController controller, int row, int column) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null) {
      throw FormatException('Completa el valor R${row + 1} → T${column + 1}.');
    }
    if (!value.isFinite || value < 0) {
      throw const FormatException(
        'Los valores deben ser números no negativos.',
      );
    }
    return value;
  }

  void _calculate() {
    try {
      final origins = List.generate(
        _rows,
        (index) => AssignmentItem(id: 'r$index', label: 'R${index + 1}'),
      );
      final destinations = List.generate(
        _columns,
        (index) => AssignmentItem(id: 't$index', label: 'T${index + 1}'),
      );
      final costs = <AssignmentCost>[];
      for (var row = 0; row < _rows; row++) {
        for (var column = 0; column < _columns; column++) {
          costs.add(
            AssignmentCost(
              originId: origins[row].id,
              destinationId: destinations[column].id,
              value: _read(_controllers[row][column], row, column),
            ),
          );
        }
      }
      final result = _solver.solve(
        AssignmentProblem(
          origins: origins,
          destinations: destinations,
          costs: costs,
          mode: _mode,
        ),
      );
      if (result == null) {
        throw const FormatException('No se encontró una asignación completa.');
      }
      setState(() {
        _result = result;
        _solutionView = AlgorithmSolutionView.table;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asignación calculada con el método Húngaro.'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _format(num value) {
    final number = value.toDouble();
    if (number == number.roundToDouble()) return number.toInt().toString();
    return number.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: const Text(
          'Método de Asignación',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Cargar ejemplo',
            onPressed: _loadExample,
            icon: const Icon(Icons.science_outlined),
          ),
          IconButton(
            tooltip: 'Limpiar',
            onPressed: _clear,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHero(),
                  const SizedBox(height: 18),
                  _buildInput(),
                  if (_result != null) ...[
                    const SizedBox(height: 18),
                    _buildResult(_result!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF818CF8)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.assignment_turned_in_rounded,
            color: Colors.white,
            size: 36,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asigna recursos a tareas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Ingresa la matriz y observa cada transformación del método Húngaro.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return AlgorithmSectionCard(
      title: 'Matriz inicial',
      subtitle: 'Cada celda representa el costo o beneficio de una asignación.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AlgorithmDimensionControl(
                label: 'Recursos',
                value: _rows,
                onRemove: () => _changeRows(-1),
                onAdd: () => _changeRows(1),
                canRemove: _rows > 2,
                canAdd: _rows < 6,
              ),
              AlgorithmDimensionControl(
                label: 'Tareas',
                value: _columns,
                onRemove: () => _changeColumns(-1),
                onAdd: () => _changeColumns(1),
                canRemove: _columns > 2,
                canAdd: _columns < 6,
              ),
              SegmentedButton<OptimizationMode>(
                segments: const [
                  ButtonSegment(
                    value: OptimizationMode.minimize,
                    label: Text('Minimizar'),
                    icon: Icon(Icons.south_east_rounded),
                  ),
                  ButtonSegment(
                    value: OptimizationMode.maximize,
                    label: Text('Maximizar'),
                    icon: Icon(Icons.north_east_rounded),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (value) {
                  setState(() {
                    _mode = value.first;
                    _result = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildInputMatrix(),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _calculate,
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
              ),
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('Resolver asignación'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputMatrix() {
    return Column(
      children: [
        Row(
          children: [
            _header('Recurso', width: 105),
            for (var column = 0; column < _columns; column++)
              _header('T${column + 1}'),
          ],
        ),
        for (var row = 0; row < _rows; row++)
          Row(
            children: [
              _label('R${row + 1}', width: 105),
              for (var column = 0; column < _columns; column++)
                _input(_controllers[row][column]),
            ],
          ),
      ],
    );
  }

  Widget _buildResult(AssignmentResult result) {
    return AlgorithmSectionCard(
      title: 'Resolución',
      subtitle: 'Las celdas verdes forman la asignación seleccionada.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AlgorithmMetric(
                icon: Icons.functions_rounded,
                label: _mode == OptimizationMode.minimize
                    ? 'Costo mínimo'
                    : 'Beneficio máximo',
                value: _format(result.total),
                color: const Color(0xFF7C3AED),
              ),
              AlgorithmMetric(
                icon: Icons.link_rounded,
                label: 'Asignaciones reales',
                value: result.matches.length.toString(),
                color: const Color(0xFF059669),
              ),
              AlgorithmMetric(
                icon: Icons.auto_stories_outlined,
                label: 'Etapas explicadas',
                value: result.steps.length.toString(),
                color: _accent,
              ),
            ],
          ),
          if (result.alternativeAssignmentColumns.isNotEmpty) ...[
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text(
                'Ver soluciones óptimas alternativas',
                style: TextStyle(color: _ink, fontWeight: FontWeight.bold),
              ),
              children: [
                for (
                  var index = 0;
                  index < result.alternativeAssignmentColumns.length;
                  index++
                )
                  _buildAlternativeAssignment(
                    index,
                    result.alternativeAssignmentColumns[index],
                    result,
                  ),
              ],
            ),
          ],
          if (result.wasBalanced) ...[
            const SizedBox(height: 12),
            const Text(
              'La matriz rectangular fue balanceada con elementos ficticios de valor cero.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: AlgorithmViewSelector(
              value: _solutionView,
              keyPrefix: 'assignment-view',
              onChanged: (value) => setState(() => _solutionView = value),
            ),
          ),
          const SizedBox(height: 16),
          if (_solutionView == AlgorithmSolutionView.table)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildSolutionMatrix(result),
            )
          else
            _buildNodeSolution(result),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final match in result.matches)
                Chip(
                  avatar: const Icon(Icons.check_circle, size: 18),
                  label: Text(
                    '${match.origin.label} → ${match.destination.label} = ${_format(match.value)}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: const Text(
              'Ver matrices y ecuaciones paso a paso',
              style: TextStyle(color: _ink, fontWeight: FontWeight.bold),
            ),
            children: [
              for (var index = 0; index < result.steps.length; index++)
                _buildStep(index, result.steps[index], result),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionMatrix(AssignmentResult result) {
    return Column(
      children: [
        Row(
          children: [
            _header('Recurso', width: 150),
            for (final label in result.columnLabels) _header(label),
          ],
        ),
        for (var row = 0; row < result.rowLabels.length; row++)
          Row(
            children: [
              _label(result.rowLabels[row], width: 150),
              for (
                var column = 0;
                column < result.columnLabels.length;
                column++
              )
                _valueCell(
                  _format(result.balancedCosts[row][column]),
                  selected: result.assignmentColumns[row] == column,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildNodeSolution(AssignmentResult result) {
    final rowCount = result.rowLabels.length;
    final columnCount = result.columnLabels.length;
    final originalRows = rowCount - result.addedDummyRows;
    final originalColumns = columnCount - result.addedDummyColumns;
    final nodes = <AlgorithmGraphNode>[
      for (var row = 0; row < rowCount; row++)
        AlgorithmGraphNode(
          id: 'assignment-row-$row',
          label: result.rowLabels[row],
          subtitle: row < originalRows ? 'Recurso' : 'Recurso ficticio',
          position: Offset(0.13, (row + 1) / (rowCount + 1)),
          color: row < originalRows
              ? const Color(0xFF4F46E5)
              : const Color(0xFFD97706),
        ),
      for (var column = 0; column < columnCount; column++)
        AlgorithmGraphNode(
          id: 'assignment-column-$column',
          label: result.columnLabels[column],
          subtitle: column < originalColumns ? 'Tarea' : 'Tarea ficticia',
          position: Offset(0.87, (column + 1) / (columnCount + 1)),
          color: column < originalColumns
              ? const Color(0xFF059669)
              : const Color(0xFFD97706),
        ),
    ];
    final edges = <AlgorithmGraphEdge>[];
    for (var row = 0; row < rowCount; row++) {
      final column = result.assignmentColumns[row];
      if (column < 0) continue;
      final isDummy = row >= originalRows || column >= originalColumns;
      edges.add(
        AlgorithmGraphEdge(
          from: 'assignment-row-$row',
          to: 'assignment-column-$column',
          label: 'valor ${_format(result.balancedCosts[row][column])}',
          color: isDummy ? const Color(0xFFD97706) : const Color(0xFF16A34A),
          dashed: isDummy,
        ),
      );
    }

    return AlgorithmNodeGraph(
      key: const ValueKey('assignment-node-solution'),
      nodes: nodes,
      edges: edges,
      height: (rowCount > columnCount ? rowCount : columnCount) * 92 + 70,
      description:
          'Cada flecha representa una asignación elegida por el método Húngaro. '
          'Las líneas punteadas identifican asignaciones ficticias de balanceo.',
    );
  }

  Widget _buildStep(
    int index,
    AssignmentMatrixStep step,
    AssignmentResult result,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso ${index + 1}: ${step.title}',
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            step.description,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          if (step.alphaVector != null || step.betaVector != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (step.alphaVector != null)
                  _vectorBadge('α', step.alphaVector!),
                if (step.betaVector != null)
                  _vectorBadge('β', step.betaVector!),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (step.matrixSymbol != null) ...[
            Text(
              step.matrixSymbol!,
              style: const TextStyle(
                color: Color(0xFF4F46E5),
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildStepMatrix(step, result),
          ),
          if (step.equations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                step.equations.join('\n'),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _vectorBadge(String name, List<double> values) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$name = [${values.map(_format).join(', ')}]',
        style: const TextStyle(
          color: Color(0xFF3730A3),
          fontFamily: 'monospace',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildAlternativeAssignment(
    int index,
    List<int> assignment,
    AssignmentResult result,
  ) {
    final realRows = result.rowLabels.length - result.addedDummyRows;
    final realColumns = result.columnLabels.length - result.addedDummyColumns;
    final labels = <String>[];
    for (var row = 0; row < realRows; row++) {
      final column = assignment[row];
      if (column >= realColumns) continue;
      labels.add(
        '${result.rowLabels[row]} → ${result.columnLabels[column]} '
        '= ${_format(result.balancedCosts[row][column])}',
      );
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        'Alternativa ${index + 1}: ${labels.join(' · ')}',
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildStepMatrix(AssignmentMatrixStep step, AssignmentResult result) {
    bool highlighted(int row, int column) => step.highlightedCells.any(
      (cell) => cell.row == row && cell.column == column,
    );

    return Column(
      children: [
        Row(
          children: [
            _header('Fila', width: 150),
            for (var column = 0; column < result.columnLabels.length; column++)
              _header(
                result.columnLabels[column],
                covered: step.coveredColumns.contains(column),
              ),
          ],
        ),
        for (var row = 0; row < result.rowLabels.length; row++)
          Row(
            children: [
              _label(
                result.rowLabels[row],
                width: 150,
                covered: step.coveredRows.contains(row),
              ),
              for (
                var column = 0;
                column < result.columnLabels.length;
                column++
              )
                _valueCell(
                  _format(step.matrix[row][column]),
                  selected: highlighted(row, column),
                  covered:
                      step.coveredRows.contains(row) ||
                      step.coveredColumns.contains(column),
                ),
            ],
          ),
      ],
    );
  }

  Widget _header(String text, {double width = 106, bool covered = false}) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: covered ? const Color(0xFFFEE2E2) : const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: covered ? const Color(0xFFB91C1C) : const Color(0xFF3730A3),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _label(String text, {double width = 106, bool covered = false}) {
    return Container(
      width: width,
      height: 62,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: covered ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _input(TextEditingController controller) {
    return Container(
      width: 106,
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          hintText: 'Valor',
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _valueCell(
    String value, {
    bool selected = false,
    bool covered = false,
  }) {
    return Container(
      width: 106,
      height: 62,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFDCFCE7)
            : covered
            ? const Color(0xFFFFF1F2)
            : Colors.white,
        border: Border.all(
          color: selected
              ? const Color(0xFF16A34A)
              : covered
              ? const Color(0xFFFDA4AF)
              : const Color(0xFFE2E8F0),
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: selected ? const Color(0xFF166534) : _ink,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

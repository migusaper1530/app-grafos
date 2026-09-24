import 'package:flutter/material.dart';

import '../../../shared/presentation/algorithm_graph.dart';
import '../domain/northwest_corner_result.dart';
import '../domain/northwest_corner_solver.dart';
import '../domain/transportation_problem.dart';

class NorthwestCornerScreen extends StatefulWidget {
  const NorthwestCornerScreen({super.key});

  @override
  State<NorthwestCornerScreen> createState() => _NorthwestCornerScreenState();
}

class _NorthwestCornerScreenState extends State<NorthwestCornerScreen> {
  static const _solver = NorthwestCornerSolver();
  static const _accent = Color(0xFF0EA5E9);
  static const _ink = Color(0xFF0F172A);

  late List<List<TextEditingController>> _costControllers;
  late List<TextEditingController> _supplyControllers;
  late List<TextEditingController> _demandControllers;
  NorthwestCornerResult? _result;
  AlgorithmSolutionView _solutionView = AlgorithmSolutionView.table;
  TransportationOptimizationMode _mode =
      TransportationOptimizationMode.minimize;

  int get _originCount => _supplyControllers.length;
  int get _destinationCount => _demandControllers.length;

  @override
  void initState() {
    super.initState();
    _initializeExample();
  }

  void _initializeExample() {
    const costs = [
      ['8', '6', '10'],
      ['9', '12', '13'],
      ['14', '9', '16'],
    ];
    _costControllers = costs
        .map(
          (row) =>
              row.map((value) => TextEditingController(text: value)).toList(),
        )
        .toList();
    _supplyControllers = [
      '20',
      '30',
      '25',
    ].map((value) => TextEditingController(text: value)).toList();
    _demandControllers = [
      '10',
      '35',
      '30',
    ].map((value) => TextEditingController(text: value)).toList();
    _mode = TransportationOptimizationMode.minimize;
  }

  void _disposeControllers() {
    for (final row in _costControllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
    for (final controller in _supplyControllers) {
      controller.dispose();
    }
    for (final controller in _demandControllers) {
      controller.dispose();
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

  void _clearValues() {
    for (final row in _costControllers) {
      for (final controller in row) {
        controller.clear();
      }
    }
    for (final controller in _supplyControllers) {
      controller.clear();
    }
    for (final controller in _demandControllers) {
      controller.clear();
    }
    setState(() => _result = null);
  }

  void _changeOrigins(int delta) {
    if (delta > 0 && _originCount >= 6) return;
    if (delta < 0 && _originCount <= 1) return;

    setState(() {
      if (delta > 0) {
        _costControllers.add(
          List.generate(_destinationCount, (_) => TextEditingController()),
        );
        _supplyControllers.add(TextEditingController());
      } else {
        final removedRow = _costControllers.removeLast();
        for (final controller in removedRow) {
          controller.dispose();
        }
        _supplyControllers.removeLast().dispose();
      }
      _result = null;
    });
  }

  void _changeDestinations(int delta) {
    if (delta > 0 && _destinationCount >= 6) return;
    if (delta < 0 && _destinationCount <= 1) return;

    setState(() {
      if (delta > 0) {
        for (final row in _costControllers) {
          row.add(TextEditingController());
        }
        _demandControllers.add(TextEditingController());
      } else {
        for (final row in _costControllers) {
          row.removeLast().dispose();
        }
        _demandControllers.removeLast().dispose();
      }
      _result = null;
    });
  }

  double _parseValue(TextEditingController controller, String field) {
    final normalized = controller.text.trim().replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) {
      throw FormatException('Completa $field con un número válido.');
    }
    if (value < 0) {
      throw FormatException('$field no puede ser negativo.');
    }
    return value;
  }

  void _calculate() {
    try {
      final costs = List.generate(
        _originCount,
        (row) => List.generate(
          _destinationCount,
          (column) => _parseValue(
            _costControllers[row][column],
            'el costo O${row + 1} → D${column + 1}',
          ),
        ),
      );
      final supply = List.generate(
        _originCount,
        (index) => _parseValue(
          _supplyControllers[index],
          'la oferta de O${index + 1}',
        ),
      );
      final demand = List.generate(
        _destinationCount,
        (index) => _parseValue(
          _demandControllers[index],
          'la demanda de D${index + 1}',
        ),
      );

      final result = _solver.solve(
        TransportationProblem(
          costs: costs,
          supply: supply,
          demand: demand,
          originLabels: List.generate(_originCount, (index) => 'O${index + 1}'),
          destinationLabels: List.generate(
            _destinationCount,
            (index) => 'D${index + 1}',
          ),
          mode: _mode,
        ),
      );
      setState(() {
        _result = result;
        _solutionView = AlgorithmSolutionView.table;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Solución de esquina noroeste calculada.'),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          '¿Cómo funciona?',
          style: TextStyle(color: _ink, fontWeight: FontWeight.bold),
        ),
        content: const SizedBox(
          width: 520,
          child: Text(
            'El método comienza en la celda superior izquierda. Asigna el '
            'menor valor entre la oferta disponible y la demanda pendiente. '
            'Cuando se agota una oferta baja una fila; cuando se satisface una '
            'demanda avanza una columna. Si los totales no coinciden, la '
            'aplicación agrega automáticamente un origen o destino ficticio '
            'con costo cero. El resultado es una solución factible inicial, '
            'pero no necesariamente la de menor costo.',
            style: TextStyle(color: Color(0xFF475569), height: 1.5),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: _accent),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
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
          'Método de Esquina Noroeste',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Cargar ejemplo',
            onPressed: _loadExample,
            icon: const Icon(Icons.science_outlined),
          ),
          IconButton(
            tooltip: 'Limpiar valores',
            onPressed: _clearValues,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          IconButton(
            tooltip: 'Ayuda',
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline_rounded),
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
                  _buildIntroduction(),
                  const SizedBox(height: 18),
                  _buildInputCard(),
                  if (_result != null) ...[
                    const SizedBox(height: 18),
                    _buildResultCard(_result!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.grid_view_rounded, color: Colors.white, size: 34),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Construye G1 y optimiza el transporte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Primero se aplica Esquina Noroeste; después se evalúan circuitos +α/−α hasta obtener la mejor solución.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return _SectionCard(
      title: 'Datos del problema',
      subtitle: 'Puedes trabajar con matrices de 1×1 hasta 6×6.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DimensionControl(
                label: 'Orígenes',
                value: _originCount,
                onRemove: () => _changeOrigins(-1),
                onAdd: () => _changeOrigins(1),
                canRemove: _originCount > 1,
                canAdd: _originCount < 6,
              ),
              _DimensionControl(
                label: 'Destinos',
                value: _destinationCount,
                onRemove: () => _changeDestinations(-1),
                onAdd: () => _changeDestinations(1),
                canRemove: _destinationCount > 1,
                canAdd: _destinationCount < 6,
              ),
              SegmentedButton<TransportationOptimizationMode>(
                segments: const [
                  ButtonSegment(
                    value: TransportationOptimizationMode.minimize,
                    label: Text('Minimizar'),
                    icon: Icon(Icons.south_east_rounded),
                  ),
                  ButtonSegment(
                    value: TransportationOptimizationMode.maximize,
                    label: Text('Maximizar'),
                    icon: Icon(Icons.north_east_rounded),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() {
                    _mode = selection.first;
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.calculate_rounded),
              label: const Text(
                'Calcular solución',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputMatrix() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _headerCell('Origen', width: 92),
            for (var column = 0; column < _destinationCount; column++)
              _headerCell('D${column + 1}'),
            _headerCell('Oferta'),
          ],
        ),
        for (var row = 0; row < _originCount; row++)
          Row(
            children: [
              _labelCell('O${row + 1}', width: 92),
              for (var column = 0; column < _destinationCount; column++)
                _inputCell(_costControllers[row][column], hint: 'Costo'),
              _inputCell(
                _supplyControllers[row],
                hint: 'Oferta',
                emphasized: true,
              ),
            ],
          ),
        Row(
          children: [
            _labelCell('Demanda', width: 92, emphasized: true),
            for (var column = 0; column < _destinationCount; column++)
              _inputCell(
                _demandControllers[column],
                hint: 'Demanda',
                emphasized: true,
              ),
            _labelCell('—'),
          ],
        ),
      ],
    );
  }

  Widget _headerCell(String text, {double width = 108}) {
    return Container(
      width: width,
      height: 46,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF075985),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _labelCell(
    String text, {
    double width = 108,
    bool emphasized = false,
  }) {
    return Container(
      width: width,
      height: 64,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: emphasized ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _inputCell(
    TextEditingController controller, {
    required String hint,
    bool emphasized = false,
  }) {
    return Container(
      width: 108,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: emphasized ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
        border: Border.all(
          color: emphasized ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildResultCard(NorthwestCornerResult result) {
    return _SectionCard(
      title: 'Solución óptima de transporte',
      subtitle: 'G1 se obtiene por Esquina Noroeste y las siguientes matrices se mejoran con circuitos +α/−α.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Metric(
                icon: Icons.payments_outlined,
                label: _mode == TransportationOptimizationMode.minimize
                    ? 'Valor mínimo de Z'
                    : 'Valor máximo de Z',
                value: _format(result.totalCost),
                color: const Color(0xFF7C3AED),
              ),
              _Metric(
                icon: Icons.flag_outlined,
                label: 'Z de la matriz G1',
                value: _format(result.initialCost),
                color: const Color(0xFFD97706),
              ),
              _Metric(
                icon: Icons.loop_rounded,
                label: 'Mejoras con α',
                value: result.optimizationSteps.length.toString(),
                color: _accent,
              ),
            ],
          ),
          if (result.wasBalanced) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                result.addedDummyOrigin
                    ? 'La demanda superaba la oferta: se agregó un origen ficticio con costo cero.'
                    : 'La oferta superaba la demanda: se agregó un destino ficticio con costo cero.',
                style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: AlgorithmViewSelector(
              value: _solutionView,
              keyPrefix: 'northwest-view',
              onChanged: (value) => setState(() => _solutionView = value),
            ),
          ),
          const SizedBox(height: 16),
          if (_solutionView == AlgorithmSolutionView.table)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildResultMatrix(result),
            )
          else
            _buildNodeSolution(result),
          const SizedBox(height: 16),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            iconColor: _accent,
            collapsedIconColor: const Color(0xFF64748B),
            title: const Text(
              'Ver G1, circuitos y ecuaciones paso a paso',
              style: TextStyle(color: _ink, fontWeight: FontWeight.bold),
            ),
            children: [
              _buildPhaseTitle(
                'Fase 1 · Esquina Noroeste',
                'Se construye la solución factible inicial G1.',
              ),
              _buildInitialState(result),
              for (var index = 0; index < result.steps.length; index++)
                _buildStep(index, result.steps[index], result),
              _buildNorthwestG1(result),
              _buildPhaseTitle(
                'Fase 2 · Optimización',
                'Se calculan indicadores y circuitos alternados +α/−α.',
              ),
              for (final step in result.optimizationSteps)
                _buildOptimizationStep(step, result),
              _buildOptimalityCheck(result),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseTitle(String title, String subtitle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7DD3FC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF075985),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: Color(0xFF0369A1))),
        ],
      ),
    );
  }

  Widget _buildNorthwestG1(NorthwestCornerResult result) {
    return _optimizationCard(
      title: 'Matriz G1 · Solución inicial',
      description: 'Esta es la solución completa obtenida al terminar el recorrido de la esquina noroeste.',
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildOptimizationMatrix(result, result.initialAllocations),
        ),
        const SizedBox(height: 12),
        _equationBox([
          'Z(G1) = ${_objectiveEquation(result, result.initialAllocations)}',
          'Z(G1) = ${_format(result.initialCost)}',
        ]),
      ],
    );
  }

  Widget _buildOptimizationStep(
    TransportationOptimizationStep step,
    NorthwestCornerResult result,
  ) {
    final entering = step.enteringCell;
    final enteringLabel =
        '${result.originLabels[entering.row]} → ${result.destinationLabels[entering.column]}';
    final formula = result.mode == TransportationOptimizationMode.minimize
        ? 'Δij = Zij − Cij'
        : 'Δij = Cij − Zij';
    final cycleText = step.cycle
        .map(
          (cell) =>
              '${cell.add ? '+' : '−'}${result.originLabels[cell.row]}${result.destinationLabels[cell.column]}',
        )
        .join(' → ');

    return _optimizationCard(
      title: 'G${step.iteration} → G${step.iteration + 1}',
      description:
          'Entra la celda $enteringLabel con indicador ${_format(step.indicator)}.',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _potentialBadge('u', step.rowPotentials),
            _potentialBadge('v', step.columnPotentials),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Matriz de indicadores',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildIndicatorMatrix(
            result,
            step.opportunityCosts,
            entering: entering,
          ),
        ),
        const SizedBox(height: 12),
        _equationBox([
          'Para celdas básicas: ui + vj = cij',
          formula,
          'Celda entrante = $enteringLabel',
          'Circuito = $cycleText',
          'α = min{asignaciones en posiciones −} = ${_format(step.alpha)}',
        ]),
        const SizedBox(height: 14),
        const Text(
          'Circuito +α/−α sobre la matriz actual',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildOptimizationMatrix(
            result,
            step.allocationsBefore,
            cycle: step.cycle,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Matriz G${step.iteration + 1}',
          style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildOptimizationMatrix(result, step.allocationsAfter),
        ),
        const SizedBox(height: 12),
        _equationBox([
          'Z(G${step.iteration}) = ${_format(step.previousCost)}',
          'Z(G${step.iteration + 1}) = ${_objectiveEquation(result, step.allocationsAfter)}',
          'Z(G${step.iteration + 1}) = ${_format(step.resultingCost)}',
        ]),
      ],
    );
  }

  Widget _buildOptimalityCheck(NorthwestCornerResult result) {
    final rule = result.mode == TransportationOptimizationMode.minimize
        ? 'Zij − Cij ≤ 0'
        : 'Cij − Zij ≤ 0';
    return _optimizationCard(
      title: result.isOptimal
          ? 'Comprobación final · Solución óptima'
          : 'Comprobación final',
      description: result.isOptimal
          ? 'No queda ninguna celda vacía que permita mejorar el valor de Z.'
          : 'El procedimiento se detuvo antes de demostrar la optimalidad.',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _potentialBadge('u', result.finalRowPotentials),
            _potentialBadge('v', result.finalColumnPotentials),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildIndicatorMatrix(result, result.finalOpportunityCosts),
        ),
        const SizedBox(height: 12),
        _equationBox([
          'Condición de optimalidad: $rule',
          'Z óptimo = ${_objectiveEquation(result, result.allocations)}',
          'Z óptimo = ${_format(result.totalCost)}',
        ]),
      ],
    );
  }

  Widget _optimizationCard({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
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
            title,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _potentialBadge(String name, List<double> values) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        '$name = [${values.map(_format).join(', ')}]',
        style: const TextStyle(
          color: Color(0xFF075985),
          fontFamily: 'monospace',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _equationBox(List<String> equations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SelectableText(
        equations.join('\n'),
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildIndicatorMatrix(
    NorthwestCornerResult result,
    List<List<double?>> indicators, {
    TransportationCell? entering,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _headerCell('Indicador', width: 130),
            for (final label in result.destinationLabels) _headerCell(label),
          ],
        ),
        for (var row = 0; row < result.originLabels.length; row++)
          Row(
            children: [
              _labelCell(result.originLabels[row], width: 130),
              for (
                var column = 0;
                column < result.destinationLabels.length;
                column++
              )
                Container(
                  width: 108,
                  height: 58,
                  margin: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: entering?.row == row && entering?.column == column
                        ? const Color(0xFFFDE68A)
                        : indicators[row][column] == null
                        ? const Color(0xFFE2E8F0)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: entering?.row == row && entering?.column == column
                          ? const Color(0xFFD97706)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    indicators[row][column] == null
                        ? 'Básica'
                        : _format(indicators[row][column]!),
                    style: TextStyle(
                      color: entering?.row == row && entering?.column == column
                          ? const Color(0xFF92400E)
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildOptimizationMatrix(
    NorthwestCornerResult result,
    List<List<double>> allocations, {
    List<TransportationCycleCell> cycle = const [],
  }) {
    TransportationCycleCell? cycleCell(int row, int column) {
      for (final cell in cycle) {
        if (cell.row == row && cell.column == column) return cell;
      }
      return null;
    }

    return Column(
      children: [
        Row(
          children: [
            _headerCell('Origen', width: 130),
            for (final destination in result.destinationLabels)
              _headerCell(destination),
            _headerCell('Oferta'),
          ],
        ),
        for (var row = 0; row < result.originLabels.length; row++)
          Row(
            children: [
              _labelCell(result.originLabels[row], width: 130),
              for (
                var column = 0;
                column < result.destinationLabels.length;
                column++
              )
                _optimizationCell(
                  allocation: allocations[row][column],
                  cost: result.costs[row][column],
                  cycleCell: cycleCell(row, column),
                ),
              _labelCell(_format(result.balancedSupply[row])),
            ],
          ),
        Row(
          children: [
            _labelCell('Demanda', width: 130, emphasized: true),
            for (final value in result.balancedDemand)
              _labelCell(_format(value), emphasized: true),
            _labelCell('—'),
          ],
        ),
      ],
    );
  }

  Widget _optimizationCell({
    required double allocation,
    required double cost,
    TransportationCycleCell? cycleCell,
  }) {
    final inCycle = cycleCell != null;
    return Container(
      width: 108,
      height: 68,
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: inCycle
            ? cycleCell.add
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2)
            : allocation > 0
            ? const Color(0xFFF0F9FF)
            : Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: inCycle
              ? cycleCell.add
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626)
              : const Color(0xFFCBD5E1),
          width: inCycle ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            inCycle ? (cycleCell.add ? '+α' : '−α') : 'c=${_format(cost)}',
            style: TextStyle(
              color: inCycle
                  ? cycleCell.add
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C)
                  : const Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'x=${_format(allocation)}',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          if (inCycle)
            Text(
              'c=${_format(cost)}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
            ),
        ],
      ),
    );
  }

  String _objectiveEquation(
    NorthwestCornerResult result,
    List<List<double>> allocations,
  ) {
    final terms = <String>[];
    for (var row = 0; row < allocations.length; row++) {
      for (var column = 0; column < allocations[row].length; column++) {
        if (allocations[row][column] <= 0) continue;
        terms.add(
          '${_format(allocations[row][column])}×${_format(result.costs[row][column])}',
        );
      }
    }
    return terms.isEmpty ? '0' : terms.join(' + ');
  }

  Widget _buildResultMatrix(NorthwestCornerResult result) {
    return Column(
      children: [
        Row(
          children: [
            _headerCell('Origen', width: 130),
            for (final destination in result.destinationLabels)
              _headerCell(destination),
            _headerCell('Oferta'),
          ],
        ),
        for (var row = 0; row < result.originLabels.length; row++)
          Row(
            children: [
              _labelCell(result.originLabels[row], width: 130),
              for (
                var column = 0;
                column < result.destinationLabels.length;
                column++
              )
                _resultCell(
                  allocation: result.allocations[row][column],
                  cost: result.costs[row][column],
                ),
              _labelCell(_format(result.balancedSupply[row])),
            ],
          ),
        Row(
          children: [
            _labelCell('Demanda', width: 130, emphasized: true),
            for (final value in result.balancedDemand)
              _labelCell(_format(value), emphasized: true),
            _labelCell('—'),
          ],
        ),
      ],
    );
  }

  Widget _buildNodeSolution(NorthwestCornerResult result) {
    final originCount = result.originLabels.length;
    final destinationCount = result.destinationLabels.length;
    final realOriginCount = result.addedDummyOrigin
        ? originCount - 1
        : originCount;
    final realDestinationCount = result.addedDummyDestination
        ? destinationCount - 1
        : destinationCount;
    final nodes = <AlgorithmGraphNode>[
      for (var row = 0; row < originCount; row++)
        AlgorithmGraphNode(
          id: 'northwest-origin-$row',
          label: result.originLabels[row],
          subtitle: row < realOriginCount
              ? 'Oferta ${_format(result.balancedSupply[row])}'
              : 'Origen ficticio',
          position: Offset(0.13, (row + 1) / (originCount + 1)),
          color: row < realOriginCount
              ? const Color(0xFF0284C7)
              : const Color(0xFFD97706),
        ),
      for (var column = 0; column < destinationCount; column++)
        AlgorithmGraphNode(
          id: 'northwest-destination-$column',
          label: result.destinationLabels[column],
          subtitle: column < realDestinationCount
              ? 'Demanda ${_format(result.balancedDemand[column])}'
              : 'Destino ficticio',
          position: Offset(0.87, (column + 1) / (destinationCount + 1)),
          color: column < realDestinationCount
              ? const Color(0xFF7C3AED)
              : const Color(0xFFD97706),
        ),
    ];
    final edges = <AlgorithmGraphEdge>[];
    for (var row = 0; row < originCount; row++) {
      for (var column = 0; column < destinationCount; column++) {
        final allocation = result.allocations[row][column];
        if (allocation <= 0) continue;
        final isDummy =
            row >= realOriginCount || column >= realDestinationCount;
        edges.add(
          AlgorithmGraphEdge(
            from: 'northwest-origin-$row',
            to: 'northwest-destination-$column',
            label:
                'x=${_format(allocation)} · c=${_format(result.costs[row][column])}',
            color: isDummy ? const Color(0xFFD97706) : const Color(0xFF0EA5E9),
            dashed: isDummy,
          ),
        );
      }
    }

    return AlgorithmNodeGraph(
      key: const ValueKey('northwest-node-solution'),
      nodes: nodes,
      edges: edges,
      height:
          (originCount > destinationCount ? originCount : destinationCount) *
              92 +
          70,
      description:
          'Cada flecha muestra una ruta utilizada: x es la cantidad asignada '
          'y c es su costo unitario. No se dibujan las rutas con asignación cero.',
    );
  }

  Widget _resultCell({required double allocation, required double cost}) {
    final hasAllocation = allocation > 0;
    return Container(
      width: 108,
      height: 64,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: hasAllocation
            ? const Color(0xFFE0F2FE)
            : const Color(0xFFF8FAFC),
        border: Border.all(
          color: hasAllocation
              ? const Color(0xFF38BDF8)
              : const Color(0xFFE2E8F0),
          width: hasAllocation ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasAllocation ? _format(allocation) : '—',
            style: TextStyle(
              color: hasAllocation ? const Color(0xFF0369A1) : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'costo ${_format(cost)}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(NorthwestCornerResult result) {
    final emptyAllocations = List.generate(
      result.originLabels.length,
      (_) => List<double>.filled(result.destinationLabels.length, 0),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Matriz inicial',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Todavía no existen asignaciones. Se inicia en la celda superior izquierda.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildProcessMatrix(
              result: result,
              allocations: emptyAllocations,
              remainingSupply: result.balancedSupply,
              remainingDemand: result.balancedDemand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    int index,
    NorthwestCornerStep step,
    NorthwestCornerResult result,
  ) {
    return Container(
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
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFE0F2FE),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF0369A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Celda ${step.originLabel} → ${step.destinationLabel}',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ecuaciones utilizadas',
                  style: TextStyle(
                    color: Color(0xFF7DD3FC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  'x(${step.originLabel}, ${step.destinationLabel}) = '
                  'min(oferta ${step.originLabel}, demanda ${step.destinationLabel})\n'
                  '= min(${_format(step.availableSupply)}, ${_format(step.pendingDemand)}) '
                  '= ${_format(step.allocated)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  "oferta ${step.originLabel}' = ${_format(step.availableSupply)} "
                  '- ${_format(step.allocated)} = ${_format(step.remainingSupply)}\n'
                  "demanda ${step.destinationLabel}' = ${_format(step.pendingDemand)} "
                  '- ${_format(step.allocated)} = ${_format(step.remainingDemand)}',
                  style: const TextStyle(
                    color: Color(0xFFBBF7D0),
                    fontFamily: 'monospace',
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  'Z${index + 1} = Z$index + x(${step.originLabel}, ${step.destinationLabel}) '
                  '× c(${step.originLabel}, ${step.destinationLabel})\n'
                  '= ${_format(step.previousCost)} + ${_format(step.allocated)} '
                  '× ${_format(step.unitCost)} = ${_format(step.accumulatedCost)}',
                  style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontFamily: 'monospace',
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Matriz después del paso ${index + 1}',
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildProcessMatrix(
              result: result,
              allocations: step.allocationsSnapshot,
              remainingSupply: step.remainingSupplySnapshot,
              remainingDemand: step.remainingDemandSnapshot,
              selectedRow: step.row,
              selectedColumn: step.column,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessMatrix({
    required NorthwestCornerResult result,
    required List<List<double>> allocations,
    required List<double> remainingSupply,
    required List<double> remainingDemand,
    int? selectedRow,
    int? selectedColumn,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _processHeaderCell('Origen', width: 130),
            for (final destination in result.destinationLabels)
              _processHeaderCell(destination),
            _processHeaderCell('Oferta restante', width: 126),
          ],
        ),
        for (var row = 0; row < result.originLabels.length; row++)
          Row(
            children: [
              _processBalanceCell(
                result.originLabels[row],
                width: 130,
                exhausted: remainingSupply[row] == 0,
              ),
              for (
                var column = 0;
                column < result.destinationLabels.length;
                column++
              )
                _processAllocationCell(
                  cost: result.costs[row][column],
                  allocation: allocations[row][column],
                  selected: row == selectedRow && column == selectedColumn,
                ),
              _processBalanceCell(
                _format(remainingSupply[row]),
                width: 126,
                exhausted: remainingSupply[row] == 0,
              ),
            ],
          ),
        Row(
          children: [
            _processBalanceCell('Demanda restante', width: 130),
            for (final value in remainingDemand)
              _processBalanceCell(_format(value), exhausted: value == 0),
            _processBalanceCell('—', width: 126),
          ],
        ),
      ],
    );
  }

  Widget _processHeaderCell(String text, {double width = 100}) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(1.5),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF075985),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _processBalanceCell(
    String text, {
    double width = 100,
    bool exhausted = false,
  }) {
    return Container(
      width: width,
      height: 64,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(1.5),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: exhausted ? const Color(0xFFE2E8F0) : const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: exhausted ? const Color(0xFF64748B) : const Color(0xFF334155),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _processAllocationCell({
    required double cost,
    required double allocation,
    required bool selected,
  }) {
    return Container(
      width: 100,
      height: 64,
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFBAE6FD)
            : allocation > 0
            ? const Color(0xFFF0F9FF)
            : Colors.white,
        border: Border.all(
          color: selected ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'c = ${_format(cost)}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            allocation > 0 ? 'x = ${_format(allocation)}' : 'x = —',
            style: TextStyle(
              color: allocation > 0
                  ? const Color(0xFF0369A1)
                  : const Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x1A0F172A),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _DimensionControl extends StatelessWidget {
  const _DimensionControl({
    required this.label,
    required this.value,
    required this.onRemove,
    required this.onAdd,
    required this.canRemove,
    required this.canAdd,
  });

  final String label;
  final int value;
  final VoidCallback onRemove;
  final VoidCallback onAdd;
  final bool canRemove;
  final bool canAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: canRemove ? onRemove : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: canAdd ? onAdd : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../shared/presentation/algorithm_graph.dart';
import '../../../shared/presentation/algorithm_widgets.dart';
import '../domain/johnson_problem.dart';
import '../domain/johnson_result.dart';
import '../domain/johnson_solver.dart';

class JohnsonMatrixScreen extends StatefulWidget {
  const JohnsonMatrixScreen({super.key});

  @override
  State<JohnsonMatrixScreen> createState() => _JohnsonMatrixScreenState();
}

class _JohnsonMatrixScreenState extends State<JohnsonMatrixScreen> {
  static const _solver = JohnsonSolver();
  static const _accent = Color(0xFFF59E0B);
  static const _ink = Color(0xFF0F172A);

  late List<TextEditingController> _nameControllers;
  late List<TextEditingController> _machine1Controllers;
  late List<TextEditingController> _machine2Controllers;
  JohnsonResult? _result;
  AlgorithmSolutionView _solutionView = AlgorithmSolutionView.table;

  int get _jobCount => _nameControllers.length;

  @override
  void initState() {
    super.initState();
    _initializeExample();
  }

  void _initializeExample() {
    _nameControllers = [
      'J1',
      'J2',
      'J3',
      'J4',
    ].map((value) => TextEditingController(text: value)).toList();
    _machine1Controllers = [
      '3',
      '12',
      '5',
      '2',
    ].map((value) => TextEditingController(text: value)).toList();
    _machine2Controllers = [
      '8',
      '4',
      '6',
      '10',
    ].map((value) => TextEditingController(text: value)).toList();
  }

  void _disposeControllers() {
    for (final controller in [
      ..._nameControllers,
      ..._machine1Controllers,
      ..._machine2Controllers,
    ]) {
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

  void _clear() {
    for (final controller in [
      ..._nameControllers,
      ..._machine1Controllers,
      ..._machine2Controllers,
    ]) {
      controller.clear();
    }
    setState(() => _result = null);
  }

  void _changeJobs(int delta) {
    if (delta > 0 && _jobCount >= 10 || delta < 0 && _jobCount <= 2) return;
    setState(() {
      if (delta > 0) {
        _nameControllers.add(TextEditingController(text: 'J${_jobCount + 1}'));
        _machine1Controllers.add(TextEditingController());
        _machine2Controllers.add(TextEditingController());
      } else {
        _nameControllers.removeLast().dispose();
        _machine1Controllers.removeLast().dispose();
        _machine2Controllers.removeLast().dispose();
      }
      _result = null;
    });
  }

  double _readTime(TextEditingController controller, String field) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value < 0) {
      throw FormatException('$field debe ser un número no negativo.');
    }
    return value;
  }

  void _calculate() {
    try {
      final names = <String>{};
      final jobs = <JohnsonJob>[];
      for (var index = 0; index < _jobCount; index++) {
        final name = _nameControllers[index].text.trim();
        if (name.isEmpty) {
          throw FormatException('Escribe el nombre del trabajo ${index + 1}.');
        }
        if (!names.add(name.toLowerCase())) {
          throw FormatException('El nombre "$name" está repetido.');
        }
        jobs.add(
          JohnsonJob(
            id: 'job-$index',
            name: name,
            machine1Time: _readTime(
              _machine1Controllers[index],
              'El tiempo M1 de $name',
            ),
            machine2Time: _readTime(
              _machine2Controllers[index],
              'El tiempo M2 de $name',
            ),
          ),
        );
      }
      final result = _solver.solve(JohnsonProblem(jobs: jobs));
      setState(() {
        _result = result;
        _solutionView = AlgorithmSolutionView.table;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Secuencia de Johnson calculada.'),
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
          'Algoritmo de Johnson',
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
          colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.precision_manufacturing_rounded,
            color: Colors.white,
            size: 36,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Programa trabajos en dos máquinas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Johnson minimiza el tiempo total ordenando cada trabajo según su menor tiempo de proceso.',
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
      title: 'Matriz inicial de trabajos',
      subtitle: 'Cada trabajo debe pasar primero por M1 y después por M2.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AlgorithmDimensionControl(
              label: 'Trabajos',
              value: _jobCount,
              onRemove: () => _changeJobs(-1),
              onAdd: () => _changeJobs(1),
              canRemove: _jobCount > 2,
              canAdd: _jobCount < 10,
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildInputTable(),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _calculate,
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Calcular secuencia',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputTable() {
    return Column(
      children: [
        Row(
          children: [
            _header('Trabajo', width: 150),
            _header('Máquina 1'),
            _header('Máquina 2'),
          ],
        ),
        for (var index = 0; index < _jobCount; index++)
          Row(
            children: [
              _input(_nameControllers[index], width: 150, numeric: false),
              _input(_machine1Controllers[index]),
              _input(_machine2Controllers[index]),
            ],
          ),
      ],
    );
  }

  Widget _buildResult(JohnsonResult result) {
    return AlgorithmSectionCard(
      title: 'Resolución de Johnson',
      subtitle: 'La secuencia minimiza el tiempo total de las dos máquinas.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AlgorithmMetric(
                icon: Icons.timer_outlined,
                label: 'Makespan',
                value: _format(result.makespan),
                color: const Color(0xFFD97706),
              ),
              AlgorithmMetric(
                icon: Icons.hourglass_empty_rounded,
                label: 'Ocio en M1',
                value: _format(result.machine1Idle),
                color: const Color(0xFF7C3AED),
              ),
              AlgorithmMetric(
                icon: Icons.hourglass_bottom_rounded,
                label: 'Ocio en M2',
                value: _format(result.machine2Idle),
                color: const Color(0xFF0284C7),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: AlgorithmViewSelector(
              value: _solutionView,
              keyPrefix: 'johnson-view',
              tableLabel: 'Tabla',
              onChanged: (value) => setState(() => _solutionView = value),
            ),
          ),
          const SizedBox(height: 16),
          if (_solutionView == AlgorithmSolutionView.table) ...[
            const Text(
              'Secuencia óptima',
              style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 8,
              children: [
                for (
                  var index = 0;
                  index < result.sequence.length;
                  index++
                ) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Text(
                      '${index + 1}. ${result.sequence[index].name}',
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (index < result.sequence.length - 1)
                    const Icon(Icons.arrow_forward, color: Color(0xFF94A3B8)),
                ],
              ],
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildScheduleTable(result),
            ),
          ] else
            _buildNodeSolution(result),
          const SizedBox(height: 14),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text(
              'Ver matrices y ecuaciones paso a paso',
              style: TextStyle(color: _ink, fontWeight: FontWeight.bold),
            ),
            children: [
              _buildInitialState(result),
              for (var index = 0; index < result.selectionSteps.length; index++)
                _buildSelectionStep(
                  index,
                  result.selectionSteps[index],
                  result.originalJobs.length,
                ),
              _buildScheduleEquations(result),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(JohnsonResult result) {
    return Column(
      children: [
        Row(
          children: [
            _header('Orden', width: 70),
            _header('Trabajo', width: 120),
            _header('M1 inicio'),
            _header('M1 fin'),
            _header('M2 inicio'),
            _header('M2 fin'),
          ],
        ),
        for (var index = 0; index < result.schedule.length; index++)
          Row(
            children: [
              _cell('${index + 1}', width: 70),
              _cell(
                result.schedule[index].job.name,
                width: 120,
                selected: true,
              ),
              _cell(_format(result.schedule[index].machine1Start)),
              _cell(_format(result.schedule[index].machine1End)),
              _cell(_format(result.schedule[index].machine2Start)),
              _cell(_format(result.schedule[index].machine2End)),
            ],
          ),
      ],
    );
  }

  Widget _buildNodeSolution(JohnsonResult result) {
    final count = result.schedule.length;
    final nodes = <AlgorithmGraphNode>[];
    final edges = <AlgorithmGraphEdge>[];

    for (var index = 0; index < count; index++) {
      final entry = result.schedule[index];
      final x = (index + 1) / (count + 1);
      nodes.addAll([
        AlgorithmGraphNode(
          id: 'johnson-m1-$index',
          label: '${index + 1}. ${entry.job.name}',
          subtitle:
              'M1: ${_format(entry.machine1Start)}–${_format(entry.machine1End)}',
          position: Offset(x, 0.27),
          color: const Color(0xFFD97706),
        ),
        AlgorithmGraphNode(
          id: 'johnson-m2-$index',
          label: entry.job.name,
          subtitle:
              'M2: ${_format(entry.machine2Start)}–${_format(entry.machine2End)}',
          position: Offset(x, 0.73),
          color: const Color(0xFF0284C7),
        ),
      ]);
      edges.add(
        AlgorithmGraphEdge(
          from: 'johnson-m1-$index',
          to: 'johnson-m2-$index',
          label: 'espera ${_format(entry.machine2Start - entry.machine1End)}',
          color: const Color(0xFF7C3AED),
        ),
      );
      if (index > 0) {
        edges.addAll([
          AlgorithmGraphEdge(
            from: 'johnson-m1-${index - 1}',
            to: 'johnson-m1-$index',
            label: 'orden M1',
            color: const Color(0xFFD97706),
          ),
          AlgorithmGraphEdge(
            from: 'johnson-m2-${index - 1}',
            to: 'johnson-m2-$index',
            label: 'orden M2',
            color: const Color(0xFF0284C7),
          ),
        ]);
      }
    }

    return AlgorithmNodeGraph(
      key: const ValueKey('johnson-node-solution'),
      nodes: nodes,
      edges: edges,
      height: 430,
      minimumWidth: count * 180 + 160,
      description:
          'La fila superior muestra la secuencia en M1 y la inferior en M2. '
          'Cada nodo incluye su intervalo de ejecución y cada flecha vertical '
          'indica la espera entre máquinas.',
    );
  }

  Widget _buildInitialState(JohnsonResult result) {
    return _procedureCard(
      title: 'Matriz inicial',
      description:
          'Se comparan todos los tiempos de M1 y M2 para localizar el menor.',
      body: _jobTable(result.originalJobs),
      equations: const [
        'm = min{todos los tiempos disponibles en M1 y M2}',
        'si m pertenece a M1 → colocar el trabajo a la izquierda',
        'si m pertenece a M2 → colocar el trabajo a la derecha',
      ],
    );
  }

  Widget _buildSelectionStep(
    int index,
    JohnsonSelectionStep step,
    int totalJobs,
  ) {
    final machine = step.selectedMachine == JohnsonMachine.machine1
        ? 'M1'
        : 'M2';
    final side = step.selectedMachine == JohnsonMachine.machine1
        ? 'primera posición libre de la izquierda'
        : 'primera posición libre de la derecha';
    final blanks =
        totalJobs - step.leftSequence.length - step.rightSequence.length;
    final partial = [
      ...step.leftSequence.map((job) => job.name),
      ...List.filled(blanks, '_'),
      ...step.rightSequence.map((job) => job.name),
    ].join('  |  ');

    return _procedureCard(
      title: 'Paso ${index + 1}: seleccionar ${step.selectedJob.name}',
      description:
          'El menor tiempo está en $machine; el trabajo se coloca en la $side.',
      body: step.remainingJobs.isEmpty
          ? const Text(
              'No quedan trabajos por seleccionar.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          : _jobTable(step.remainingJobs),
      equations: [
        'm = min{tiempos restantes} = ${_format(step.minimumTime)}',
        'm = $machine(${step.selectedJob.name}) = ${_format(step.minimumTime)}',
        'secuencia parcial = [$partial]',
      ],
    );
  }

  Widget _buildScheduleEquations(JohnsonResult result) {
    final equations = <String>[];
    for (var index = 0; index < result.schedule.length; index++) {
      final entry = result.schedule[index];
      final previousM1End = index == 0
          ? 0
          : result.schedule[index - 1].machine1End;
      final previousM2End = index == 0
          ? 0
          : result.schedule[index - 1].machine2End;
      equations.addAll([
        '${entry.job.name}: inicio M1 = fin M1 anterior = ${_format(previousM1End)}',
        '${entry.job.name}: fin M1 = ${_format(entry.machine1Start)} + ${_format(entry.job.machine1Time)} = ${_format(entry.machine1End)}',
        '${entry.job.name}: inicio M2 = max(${_format(entry.machine1End)}, ${_format(previousM2End)}) = ${_format(entry.machine2Start)}',
        '${entry.job.name}: fin M2 = ${_format(entry.machine2Start)} + ${_format(entry.job.machine2Time)} = ${_format(entry.machine2End)}',
        '',
      ]);
    }
    equations.add(
      'Cmax = fin del último trabajo en M2 = ${_format(result.makespan)}',
    );
    return _procedureCard(
      title: 'Cronograma final',
      description: 'Con la secuencia definida, se calculan inicios y finales respetando que M2 espere a M1.',
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildScheduleTable(result),
      ),
      equations: equations,
    );
  }

  Widget _procedureCard({
    required String title,
    required String description,
    required Widget body,
    required List<String> equations,
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
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: body),
          const SizedBox(height: 12),
          Container(
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
          ),
        ],
      ),
    );
  }

  Widget _jobTable(List<JohnsonJob> jobs) {
    return Column(
      children: [
        Row(
          children: [
            _header('Trabajo', width: 140),
            _header('M1'),
            _header('M2'),
          ],
        ),
        for (final job in jobs)
          Row(
            children: [
              _cell(job.name, width: 140, selected: true),
              _cell(_format(job.machine1Time)),
              _cell(_format(job.machine2Time)),
            ],
          ),
      ],
    );
  }

  Widget _header(String text, {double width = 112}) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF92400E),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller, {
    double width = 112,
    bool numeric = true,
  }) {
    return Container(
      width: width,
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: TextField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: numeric ? 'Tiempo' : 'Nombre',
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _cell(String text, {double width = 112, bool selected = false}) {
    return Container(
      width: width,
      height: 58,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFFBEB) : Colors.white,
        border: Border.all(
          color: selected ? const Color(0xFFFBBF24) : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
      ),
    );
  }
}

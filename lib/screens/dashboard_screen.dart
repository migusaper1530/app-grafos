import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../shared/widgets/algorithm_card_grid.dart';
import '../shared/widgets/futuristic_surface.dart';
import 'asignacion_screen.dart';
import 'esquina_nor_oeste_screen.dart';
import 'grafo_screen.dart';
import 'johnson_screen.dart';
import 'menu_principal_screen.dart';
import 'sorting_methods_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambient;
  late final AnimationController _entrance;
  final _workflowKey = GlobalKey();
  int _selectedModule = 0;
  bool _demoOrdered = false;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ambient.stop();
      _entrance.value = 1;
    } else if (!_ambient.isAnimating) {
      _ambient.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ambient.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final module = _modules[_selectedModule];
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ambient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: FadeTransition(
                  opacity: _entrance,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final intro = _buildIntro();
                          final preview = _buildPreview();
                          if (constraints.maxWidth >= 850) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 6, child: intro),
                                const SizedBox(width: 40),
                                Expanded(flex: 5, child: preview),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              intro,
                              const SizedBox(height: 28),
                              preview,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      const Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _Metric(
                            icon: Icons.apps_rounded,
                            title: '5 módulos',
                            subtitle: 'Grafos, optimización y ordenamiento',
                          ),
                          _Metric(
                            icon: Icons.sort_rounded,
                            title: '4 métodos de ordenamiento',
                            subtitle: 'Selection, Insertion, Merge y Shell Sort',
                          ),
                          _Metric(
                            icon: Icons.touch_app_rounded,
                            title: 'Aprendizaje interactivo',
                            subtitle: 'Construye, ejecuta y compara',
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      const _SectionHeading(
                        eyebrow: 'CONOCE EL LABORATORIO',
                        title: 'Un problema, distintas formas de resolverlo',
                        description: 'Selecciona un módulo para conocer qué datos necesita y qué puedes aprender con él.',
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (var index = 0; index < _modules.length; index++)
                            ChoiceChip(
                              avatar: Icon(
                                _modules[index].icon,
                                size: 18,
                                color: _modules[index].color,
                              ),
                              label: Text(_modules[index].label),
                              selected: _selectedModule == index,
                              showCheckmark: false,
                              selectedColor: _modules[index].color.withValues(
                                alpha: 0.15,
                              ),
                              side: BorderSide(
                                color: _selectedModule == index
                                    ? _modules[index].color
                                    : AppColors.border,
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedModule = index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        child: _buildModuleDetails(module),
                      ),
                      const SizedBox(height: 48),
                      const _SectionHeading(
                        eyebrow: 'MÁS ALLÁ DEL RESULTADO',
                        title: '¿Qué hace bueno a un algoritmo?',
                        description: 'Entender el proceso te permite elegir una solución adecuada para cada problema.',
                      ),
                      const SizedBox(height: 20),
                      const AlgorithmCardGrid(
                        children: [
                          _KnowledgeCard(
                            icon: Icons.verified_outlined,
                            color: AppColors.success,
                            title: 'Corrección',
                            body: 'Un algoritmo debe producir una respuesta válida para los datos de entrada. Revisa restricciones, casos límite y el significado del resultado.',
                          ),
                          _KnowledgeCard(
                            icon: Icons.speed_rounded,
                            color: AppColors.sorting,
                            title: 'Eficiencia',
                            body: 'El tiempo y la memoria necesarios pueden crecer con el tamaño del problema. La notación O grande describe ese crecimiento, no una duración exacta.',
                          ),
                          _KnowledgeCard(
                            icon: Icons.visibility_outlined,
                            color: AppColors.graph,
                            title: 'Interpretación',
                            body: 'Visualizar nodos, matrices o comparaciones ayuda a entender las decisiones del algoritmo y a explicar por qué una solución es útil.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _SectionHeading(
                        key: _workflowKey,
                        eyebrow: 'TU PRIMER EXPERIMENTO',
                        title: 'Del problema a la solución',
                        description: 'Sigue este recorrido y observa cómo cada dato afecta el resultado.',
                      ),
                      const SizedBox(height: 20),
                      const AlgorithmCardGrid(
                        maxColumns: 2,
                        children: [
                          _WorkflowStep(
                            number: '01',
                            title: 'Define el problema',
                            body: 'Decide si necesitas representar una red, asignar recursos, distribuir una oferta u ordenar números.',
                          ),
                          _WorkflowStep(
                            number: '02',
                            title: 'Construye tus datos',
                            body: 'Agrega nodos y conexiones, completa los costos o escribe los valores que quieres ordenar.',
                          ),
                          _WorkflowStep(
                            number: '03',
                            title: 'Ejecuta y observa',
                            body: 'Consulta la matriz, calcula una solución o avanza por los pasos de un ordenamiento.',
                          ),
                          _WorkflowStep(
                            number: '04',
                            title: 'Compara y aprende',
                            body: 'Cambia una entrada, vuelve a ejecutar y explica cómo y por qué cambió el resultado.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      const _SectionHeading(
                        eyebrow: 'DETRÁS DE LOGIVERSE',
                        title: 'Equipo de desarrollo',
                        description: 'Un proyecto académico para aprender algoritmos a través de la visualización y la experimentación.',
                      ),
                      const SizedBox(height: 20),
                      const AlgorithmCardGrid(
                        children: [
                          _DeveloperCard(
                            name: 'Jesus Canqui',
                            initials: 'JC',
                            color: AppColors.primary,
                          ),
                          _DeveloperCard(
                            name: 'Miguel Sanchez',
                            initials: 'MS',
                            color: AppColors.sorting,
                          ),
                          _DeveloperCard(
                            name: 'Jenny Quispe',
                            initials: 'JQ',
                            color: AppColors.graph,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'LogiVerse Core · Laboratorio de algoritmos e investigación de operaciones',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        builder: (context, child) => FuturisticBackground(
          accent: Color.lerp(
            AppColors.primary,
            AppColors.graph,
            _ambient.value * 0.45,
          )!,
          child: child!,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LogiVerse Core',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Laboratorio de algoritmos',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPLORA · VISUALIZA · APRENDE',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(text: 'Análisis de\n'),
              TextSpan(
                text: 'Algoritmos',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Convierte datos en decisiones.',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Un algoritmo es una secuencia finita de pasos para resolver un problema. Aquí puedes construir sus entradas, observar su ejecución y entender sus resultados con ejemplos visuales.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => _open(const MenuPrincipalScreen()),
              icon: const Icon(Icons.rocket_launch_rounded, size: 20),
              label: const Text('Explorar Algoritmos'),
            ),
            OutlinedButton.icon(
              onPressed: () => Scrollable.ensureVisible(
                _workflowKey.currentContext!,
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 500),
              ),
              icon: const Icon(Icons.auto_stories_outlined, size: 20),
              label: const Text('¿Cómo funciona?'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final values = _demoOrdered ? [2, 3, 5, 7, 9] : [7, 3, 9, 2, 5];
    return FuturisticPanel(
      accent: AppColors.sorting,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.equalizer_rounded, color: AppColors.sorting, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'De datos a orden',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Un ejemplo de ordenamiento ascendente',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < values.length; index++) ...[
                  if (index > 0) const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${values[index]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.sorting,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 450),
                          curve: Curves.easeInOutCubic,
                          height: values[index] * 13.0 + 18,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.sorting.withValues(alpha: 0.9),
                                AppColors.primary.withValues(alpha: 0.25),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.sorting.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _demoOrdered
                ? 'Resultado: 2, 3, 5, 7, 9'
                : 'Entrada: 7, 3, 9, 2, 5',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() => _demoOrdered = !_demoOrdered),
            icon: Icon(
              _demoOrdered ? Icons.refresh_rounded : Icons.sort_rounded,
            ),
            label: Text(_demoOrdered ? 'Reiniciar ejemplo' : 'Ordenar ejemplo'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Para ver las comparaciones paso a paso, abre el módulo de ordenamiento.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleDetails(_LearningModule module) {
    return FuturisticPanel(
      key: ValueKey(module.label),
      accent: module.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(module.icon, color: module.color, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            module.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          AlgorithmCardGrid(
            maxColumns: 2,
            children: [
              _DataFact(
                title: 'Datos de entrada',
                text: module.input,
                icon: Icons.input_rounded,
              ),
              _DataFact(
                title: 'Qué puedes observar',
                text: module.output,
                icon: Icons.insights_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(module.tip, style: TextStyle(color: module.color, height: 1.5)),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => _open(module.screen),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Abrir este módulo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
  final String eyebrow;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        description,
        style: const TextStyle(color: AppColors.textMuted, height: 1.5),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _KnowledgeCard extends StatelessWidget {
  const _KnowledgeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => FuturisticPanel(
    accent: color,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
      ],
    ),
  );
}

class _DataFact extends StatelessWidget {
  const _DataFact({
    required this.title,
    required this.text,
    required this.icon,
  });
  final String title;
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
      ],
    ),
  );
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({
    required this.number,
    required this.title,
    required this.body,
  });
  final String number;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => FuturisticPanel(
    padding: const EdgeInsets.all(20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({
    required this.name,
    required this.initials,
    required this.color,
  });
  final String name;
  final String initials;
  final Color color;
  @override
  Widget build(BuildContext context) => FuturisticPanel(
    accent: color,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          child: Text(
            initials,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Desarrollo de LogiVerse Core',
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
      ],
    ),
  );
}

class _LearningModule {
  const _LearningModule({
    required this.label,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.input,
    required this.output,
    required this.tip,
    required this.screen,
  });
  final String label;
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final String input;
  final String output;
  final String tip;
  final Widget screen;
}

const _modules = [
  _LearningModule(
    label: 'Grafos',
    title: 'Redes y Grafos',
    icon: Icons.hub_rounded,
    color: AppColors.graph,
    description: 'Un grafo representa relaciones mediante nodos y conexiones. Puedes usarlo para modelar redes, rutas o dependencias y estudiar su estructura.',
    input: 'Nodos, conexiones y pesos definidos en el lienzo.',
    output: 'La matriz de adyacencia y los grados de los nodos.',
    tip: 'Prueba: agrega una conexión y observa qué cambia en la matriz.',
    screen: GrafoScreen(),
  ),
  _LearningModule(
    label: 'Asignación',
    title: 'Método de Asignación',
    icon: Icons.assignment_turned_in_rounded,
    color: AppColors.primary,
    description: 'El problema de asignación vincula recursos con tareas, buscando una distribución que minimice o maximice el costo total según el objetivo.',
    input: 'Recursos, tareas y costos de cada posible asignación.',
    output: 'Las asignaciones seleccionadas y su costo total.',
    tip: 'Prueba: compara minimizar y maximizar con la misma matriz de costos.',
    screen: AsignacionScreen(),
  ),
  _LearningModule(
    label: 'Johnson',
    title: 'Red de actividades y ruta crítica',
    icon: Icons.account_tree_rounded,
    color: AppColors.johnson,
    description: 'Este módulo representa actividades y sus dependencias. Calcula tiempos tempranos, tiempos tardíos y holguras para interpretar la duración de una red de actividades.',
    input: 'Eventos, conexiones con duración y un nodo de inicio.',
    output: 'Tiempos, holguras y actividades de la ruta crítica.',
    tip: 'Prueba: cambia la duración de una actividad y vuelve a calcular la red.',
    screen: JohnsonScreen(),
  ),
  _LearningModule(
    label: 'Transporte',
    title: 'Distribución de recursos',
    icon: Icons.local_shipping_rounded,
    color: AppColors.success,
    description: 'Un problema de transporte distribuye la oferta de distintos orígenes para satisfacer la demanda de los destinos, considerando el costo de cada ruta.',
    input: 'Orígenes, destinos, ofertas, demandas y costos unitarios.',
    output: 'Las cantidades asignadas y el costo de la distribución.',
    tip: 'Prueba: modifica una oferta o una demanda y compara la nueva distribución.',
    screen: EsquinaNorOesteScreen(),
  ),
  _LearningModule(
    label: 'Ordenamiento',
    title: 'Selection, Insertion, Merge y Shell Sort',
    icon: Icons.sort_rounded,
    color: AppColors.sorting,
    description: 'Selection Sort busca el menor elemento en cada pasada. Insertion Sort inserta cada valor en la parte ya ordenada. Merge Sort divide y fusiona porciones ordenadas. Shell Sort usa inserción con saltos decrecientes. Puedes estudiar los cuatro métodos paso a paso.',
    input: 'Hasta 20 números entre 1 y 100.',
    output: 'Comparaciones, movimientos y el arreglo ordenado.',
    tip: 'Selection Sort realiza O(n²) comparaciones. Insertion Sort puede llegar a O(n) con datos ya ordenados y a O(n²) en el peor caso. Merge Sort realiza O(n log n) trabajo y usa O(n) espacio auxiliar. Shell Sort con saltos de Knuth tiene una cota de O(n^(3/2)) en el peor caso.',
    screen: SortingMethodsScreen(),
  ),
];

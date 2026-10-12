import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../shared/widgets/algorithm_card_grid.dart';
import '../features/sorting/domain/sorting_algorithm.dart';
import '../features/sorting/domain/sorting_order.dart';
import '../features/sorting/presentation/widgets/sorting_order_selector.dart';
import '../features/sorting/presentation/widgets/sorting_help_menu.dart';
import '../shared/widgets/algorithm_scaffold.dart';
import '../shared/widgets/futuristic_surface.dart';
import 'sorting_visualization_screen.dart';

class SortingMethodsScreen extends StatefulWidget {
  const SortingMethodsScreen({super.key});

  @override
  State<SortingMethodsScreen> createState() => _SortingMethodsScreenState();
}

class _SortingMethodsScreenState extends State<SortingMethodsScreen> {
  SortingOrder _order = SortingOrder.ascending;

  @override
  Widget build(BuildContext context) {
    return AlgorithmScaffold(
      accent: AppColors.sorting,
      title: 'Métodos de Ordenamiento',
      icon: Icons.sort_rounded,
      actions: const [SortingHelpMenu()],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FuturisticPanel(
                  accent: AppColors.sorting,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LABORATORIO DE ORDENAMIENTO',
                        style: TextStyle(
                          color: AppColors.sorting,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Selecciona un método de ordenamiento',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Observa cada comparación, controla la ejecución '
                        'y descubre cómo crece el trabajo de cada algoritmo.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Sentido del ordenamiento',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      SortingOrderSelector(
                        order: _order,
                        onChanged: (order) => setState(() => _order = order),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AlgorithmCardGrid(
                  maxColumns: 2,
                  children: [
                    _SortingMethodCard(
                      algorithm: SortingAlgorithm.selectionSort,
                      order: _order,
                      description: 'Selecciona el menor o el mayor de la porción pendiente y lo coloca en su posición definitiva.',
                      icon: Icons.filter_list_rounded,
                    ),
                    _SortingMethodCard(
                      algorithm: SortingAlgorithm.insertionSort,
                      order: _order,
                      description: 'Inserta cada elemento en su posición correcta dentro de la porción ordenada.',
                      icon: Icons.input_rounded,
                    ),
                    _SortingMethodCard(
                      algorithm: SortingAlgorithm.mergeSort,
                      order: _order,
                      description: 'Divide el arreglo en mitades y fusiona las porciones ordenadas usando un arreglo auxiliar.',
                      icon: Icons.merge_rounded,
                    ),
                    _SortingMethodCard(
                      algorithm: SortingAlgorithm.shellSort,
                      order: _order,
                      description: 'Ordena elementos separados por saltos cada vez menores hasta terminar con una pasada de inserción con salto 1.',
                      icon: Icons.linear_scale_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortingMethodCard extends StatelessWidget {
  final SortingAlgorithm algorithm;
  final String description;
  final IconData icon;
  final SortingOrder order;

  const _SortingMethodCard({
    required this.algorithm,
    required this.description,
    required this.icon,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.sorting.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SortingVisualizationScreen(
              algorithm: algorithm,
              initialOrder: order,
              initialArray: const [15, 47, 45, 60, 52, 84, 88, 59, 89, 86, 60],
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.sorting.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.sorting, size: 28),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                algorithm.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              const Spacer(),
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Abrir algoritmo',
                      style: TextStyle(
                        color: AppColors.sorting,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.sorting,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

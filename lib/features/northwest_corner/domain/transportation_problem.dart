enum TransportationOptimizationMode { minimize, maximize }

/// Datos de entrada para un problema de transporte.
class TransportationProblem {
  TransportationProblem({
    required List<List<num>> costs,
    required List<num> supply,
    required List<num> demand,
    List<String>? originLabels,
    List<String>? destinationLabels,
    this.mode = TransportationOptimizationMode.minimize,
  }) : costs = List.unmodifiable(
         costs.map((row) => List<num>.unmodifiable(row)),
       ),
       supply = List<num>.unmodifiable(supply),
       demand = List<num>.unmodifiable(demand),
       originLabels = List<String>.unmodifiable(
         originLabels ??
             List.generate(supply.length, (index) => 'Origen ${index + 1}'),
       ),
       destinationLabels = List<String>.unmodifiable(
         destinationLabels ??
             List.generate(demand.length, (index) => 'Destino ${index + 1}'),
       );

  final List<List<num>> costs;
  final List<num> supply;
  final List<num> demand;
  final List<String> originLabels;
  final List<String> destinationLabels;
  final TransportationOptimizationMode mode;
}

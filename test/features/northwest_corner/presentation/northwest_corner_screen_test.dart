import 'package:app_grafos/features/northwest_corner/presentation/northwest_corner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra y calcula el ejemplo inicial', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: NorthwestCornerScreen()));

    expect(find.text('Método de Esquina Noroeste'), findsOneWidget);
    expect(find.text('Calcular solución'), findsOneWidget);

    await tester.tap(find.text('Calcular solución'));
    await tester.pumpAndSettle();

    expect(find.text('Solución óptima de transporte'), findsOneWidget);
    expect(find.text('Valor mínimo de Z'), findsOneWidget);
    expect(find.text('735'), findsOneWidget);
    expect(find.text('905'), findsOneWidget);

    final nodeView = find.byKey(const ValueKey('northwest-view-nodes'));
    await tester.ensureVisible(nodeView);
    await tester.pumpAndSettle();
    await tester.tap(nodeView);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('northwest-node-solution')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('graph-node-northwest-origin-0')),
      findsOneWidget,
    );

    final procedure = find.text('Ver G1, circuitos y ecuaciones paso a paso');
    await tester.ensureVisible(procedure);
    await tester.pumpAndSettle();
    await tester.tap(procedure);
    await tester.pumpAndSettle();

    expect(find.text('Matriz inicial'), findsOneWidget);
    expect(find.textContaining('min(20, 10) = 10'), findsOneWidget);
    expect(find.text('Matriz después del paso 1'), findsOneWidget);
    expect(find.text('Matriz G1 · Solución inicial'), findsOneWidget);
    expect(find.textContaining('Circuito ='), findsWidgets);
    expect(find.textContaining('α = min'), findsWidgets);
    expect(find.textContaining('Solución óptima'), findsWidgets);
  });
}

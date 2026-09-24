import 'package:app_grafos/features/johnson/presentation/johnson_matrix_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resuelve y explica el ejemplo de Johnson', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: JohnsonMatrixScreen()));

    expect(find.text('Matriz inicial de trabajos'), findsOneWidget);
    await tester.tap(find.text('Calcular secuencia'));
    await tester.pumpAndSettle();

    expect(find.text('Resolución de Johnson'), findsOneWidget);
    expect(find.text('1. J4'), findsOneWidget);
    expect(find.text('Makespan'), findsOneWidget);

    final nodeView = find.byKey(const ValueKey('johnson-view-nodes'));
    await tester.ensureVisible(nodeView);
    await tester.pumpAndSettle();
    await tester.tap(nodeView);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('johnson-node-solution')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('graph-node-johnson-m1-0')),
      findsOneWidget,
    );

    final procedure = find.text('Ver matrices y ecuaciones paso a paso');
    await tester.ensureVisible(procedure);
    await tester.pumpAndSettle();
    await tester.tap(procedure);
    await tester.pumpAndSettle();

    expect(find.text('Matriz inicial'), findsOneWidget);
    expect(find.textContaining('Paso 1: seleccionar J4'), findsOneWidget);
    expect(
      find.textContaining('Cmax = fin del último trabajo'),
      findsOneWidget,
    );
  });
}

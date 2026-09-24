import 'package:app_grafos/features/assignment/presentation/assignment_matrix_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resuelve y explica la matriz de ejemplo', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: AssignmentMatrixScreen()));

    expect(find.text('Matriz inicial'), findsOneWidget);
    await tester.tap(find.text('Resolver asignación'));
    await tester.pumpAndSettle();

    expect(find.text('Resolución'), findsOneWidget);
    expect(find.text('Costo mínimo'), findsOneWidget);

    final nodeView = find.byKey(const ValueKey('assignment-view-nodes'));
    await tester.ensureVisible(nodeView);
    await tester.pumpAndSettle();
    await tester.tap(nodeView);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('assignment-node-solution')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('graph-node-assignment-row-0')),
      findsOneWidget,
    );

    final procedure = find.text('Ver matrices y ecuaciones paso a paso');
    await tester.ensureVisible(procedure);
    await tester.pumpAndSettle();
    await tester.tap(procedure);
    await tester.pumpAndSettle();

    expect(find.textContaining('Paso 1: Matriz inicial'), findsOneWidget);
    expect(find.textContaining('Vector α'), findsOneWidget);
    expect(find.textContaining('Vector β'), findsOneWidget);
    expect(find.textContaining('α = ['), findsWidgets);
  });
}

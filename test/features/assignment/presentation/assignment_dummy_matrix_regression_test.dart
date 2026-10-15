import 'dart:convert';
import 'dart:math';

import 'package:app_grafos/app/app_theme.dart';
import 'package:app_grafos/models/conexion.dart';
import 'package:app_grafos/models/nodo.dart';
import 'package:app_grafos/features/assignment/presentation/screens/asignacion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(1280, 900)]) {
    for (final counts in [(2, 3), (3, 2), (1, 3), (3, 1), (2, 2)]) {
      final (origins, destinations) = counts;
      testWidgets(
        'matriz $origins × $destinations con ficticios a ${size.width}',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.dark,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: const AsignacionScreen(),
            ),
          );
          await tester.pumpAndSettle();
          final panelScrollable = find
              .descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              )
              .first;
          Future<void> reveal(Finder target, {double step = 120}) async {
            await tester.scrollUntilVisible(
              target,
              step,
              scrollable: panelScrollable,
            );
            await tester.pumpAndSettle();
          }

          final dynamic state = tester.state(find.byType(AsignacionScreen));
          state.nodos = <Nodo>[
            for (int i = 0; i < origins; i++)
              Nodo(
                id: 'o$i',
                nombre: 'Origen $i',
                posicion: Offset(50, 100 + i * 80),
              ),
            for (int j = 0; j < destinations; j++)
              Nodo(
                id: 'd$j',
                nombre: 'Destino $j',
                posicion: Offset(250, 100 + j * 80),
              ),
          ];
          state.conexiones = <Conexion>[
            for (int i = 0; i < origins; i++)
              for (int j = 0; j < destinations; j++)
                if (counts != (2, 2) || i != 1 || j != 1)
                  Conexion(
                    nodoA: 'o$i',
                    nodoB: 'd$j',
                    peso: i == 0 ? 6 : j + 1,
                  ),
          ];
          await tester.tap(find.byTooltip('Mostrar matriz'));
          await tester.pumpAndSettle();
          await reveal(find.byType(DataTable));
          await tester.pumpAndSettle();
          final table = tester.widget<DataTable>(find.byType(DataTable));
          final dimension = max(origins, destinations);
          expect(table.columns.length, dimension + 1);
          expect(table.rows.length, dimension);
          for (int i = 0; i < dimension; i++) {
            final cells = table.rows[i].cells;
            expect(
              (cells.first.child as Text).data,
              i < origins ? 'Origen $i' : 'Origen ficticio ${i - origins + 1}',
            );
            for (int j = 0; j < dimension; j++) {
              final actual = (cells[j + 1].child as Text).data;
              final isDummy = i >= origins || j >= destinations;
              expect(
                actual,
                isDummy
                    ? '0'
                    : counts == (2, 2) && i == 1 && j == 1
                    ? '-'
                    : (i == 0 ? 6 : j + 1).toString(),
              );
            }
          }
          for (int j = 0; j < dimension; j++) {
            expect(
              (table.columns[j + 1].label as Text).data,
              j < destinations
                  ? 'Destino $j'
                  : 'Destino ficticio ${j - destinations + 1}',
            );
          }
          if (origins == destinations) {
            expect(find.textContaining('fictici'), findsNothing);
          } else {
            expect(
              find.textContaining('con costo 0 para completar la matriz'),
              findsOneWidget,
            );
          }
          expect((state.nodos as List<Nodo>).length, origins + destinations);
          expect(tester.takeException(), isNull);

          if (counts == (2, 3)) {
            // The user's example remains 7 for minimization and 9 for maximization.
            final calculate = find.text('Calcular Asignación Óptima');
            await reveal(calculate, step: -120);
            await tester.tap(calculate);
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 5));
            await tester.pumpAndSettle();
            await reveal(find.text('Costo Total: 7'));
            expect(find.text('Costo Total: 7'), findsOneWidget);
            expect(
              (state.detalleAsignaciones as List<String>).where(
                (detail) => !detail.contains('ficticio'),
              ),
              hasLength(2),
            );
            expect(
              (state.detalleAsignaciones as List<String>).where(
                (detail) => detail.contains('ficticio'),
              ),
              hasLength(1),
            );
            await tester.ensureVisible(find.byType(DropdownButton<String>));
            await tester.pumpAndSettle();
            await tester.tap(find.byType(DropdownButton<String>));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Maximizar').last);
            await tester.pumpAndSettle();
            await reveal(calculate, step: -120);
            await tester.tap(calculate);
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 5));
            await tester.pumpAndSettle();
            await reveal(find.text('Costo Total: 9'));
            expect(find.text('Costo Total: 9'), findsOneWidget);
            await reveal(find.text('Origen ficticio 1'), step: -120);
            expect(find.text('Origen ficticio 1'), findsOneWidget);

            // Synthetic entries are explanatory; exported editor data stays real.
            await tester.tap(find.byTooltip('Más opciones'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Guardar'));
            await tester.pumpAndSettle();
            final preview = tester
                .widget<SelectableText>(find.byType(SelectableText))
                .data!;
            final document = jsonDecode(preview) as Map<String, dynamic>;
            expect(document['nodos'], hasLength(5));
            expect(document['conexiones'], hasLength(6));
            expect(preview, isNot(contains('ficticio')));
            await tester.tap(find.text('Cancelar'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }
}

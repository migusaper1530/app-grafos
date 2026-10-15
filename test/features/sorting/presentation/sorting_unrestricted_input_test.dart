import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_grafos/app/app_theme.dart';
import 'package:app_grafos/features/sorting/domain/sorting_algorithm.dart';
import 'package:app_grafos/features/sorting/presentation/screens/sorting_race_screen.dart';
import 'package:app_grafos/features/sorting/presentation/screens/sorting_visualization_screen.dart';
import 'package:app_grafos/features/sorting/presentation/widgets/bowling_pin_widget.dart';
import 'package:app_grafos/features/sorting/presentation/widgets/sorting_visualization_widget.dart';

void main() {
  for (final algorithm in SortingAlgorithm.values) {
    testWidgets(
      '${algorithm.name}: cantidad escrita y lista manual de 125 enteros',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: SortingVisualizationScreen(
              algorithm: algorithm,
              initialArray: const [3, 1, 2],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Nuevo ordenamiento'));
        await tester.tap(find.text('Nuevo ordenamiento'));
        await tester.pumpAndSettle();
        final count = find.byKey(const ValueKey('sorting-count'));
        await tester.enterText(count, '0');
        await tester.ensureVisible(find.text('Generar aleatorios'));
        await tester.tap(find.text('Generar aleatorios'));
        await tester.pumpAndSettle();
        expect(
          find.text('Ingresa una cantidad entera mayor que cero.'),
          findsOneWidget,
        );
        await tester.enterText(count, '125');
        await tester.ensureVisible(find.text('Generar aleatorios'));
        await tester.tap(find.text('Generar aleatorios'));
        await tester.pumpAndSettle();
        var provider = tester
            .widget<SortingVisualizationWidget>(
              find.byType(SortingVisualizationWidget),
            )
            .provider;
        expect(provider.originalArray, hasLength(125));
        expect(provider.originalArray.toSet(), hasLength(125));
        expect(provider.finalArray, List<int>.generate(125, (i) => i + 1));

        await tester.ensureVisible(find.text('Nuevo ordenamiento'));
        await tester.tap(find.text('Nuevo ordenamiento'));
        await tester.pumpAndSettle();
        final input = List<int>.generate(125, (i) => (124 - i) * 1000 - 50000);
        await tester.enterText(
          find.byKey(const ValueKey('sorting-numbers')),
          input.join(',\n'),
        );
        await tester.ensureVisible(find.text('Usar estos números'));
        await tester.tap(find.text('Usar estos números'));
        await tester.pumpAndSettle();
        provider = tester
            .widget<SortingVisualizationWidget>(
              find.byType(SortingVisualizationWidget),
            )
            .provider;
        expect(provider.originalArray, input);
        expect(provider.finalArray, [...input]..sort());
        expect(
          find.byType(BowlingPinWidget).evaluate().length,
          lessThan(input.length),
        );
        final scrollable = tester.state<ScrollableState>(
          find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          ),
        );
        scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(find.byTooltip('[124]: ${input.last}'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'la carrera genera la cantidad escrita y admite negativos y valores grandes',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const SortingRaceScreen()),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('race-count')), '125');
      for (final button in [
        'Lista ordenada',
        'Lista invertida',
        'Aleatorios',
      ]) {
        await tester.ensureVisible(find.text(button));
        await tester.tap(find.text(button));
        await tester.pumpAndSettle();
        final text = tester
            .widget<TextField>(find.byKey(const ValueKey('race-numbers')))
            .controller!
            .text;
        expect(text.split(','), hasLength(125));
      }
      await tester.enterText(
        find.byKey(const ValueKey('race-numbers')),
        '-90000, 0, 1000000, -90000',
      );
      await tester.ensureVisible(find.text('Aplicar números'));
      await tester.tap(find.text('Aplicar números'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ver resultado'));
      await tester.tap(find.text('Ver resultado'));
      await tester.pumpAndSettle();
      for (final algorithm in SortingAlgorithm.values) {
        expect(
          tester
              .widget<Text>(
                find.byKey(ValueKey('race-array-${algorithm.name}')),
              )
              .data,
          '-90000 · -90000 · 0 · 1000000',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
}

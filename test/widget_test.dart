import 'package:app_grafos/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el menú inicial ofrece ayuda y cambio de tema', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LogiVerseApp());

    expect(find.text('LogiVerse Core'), findsOneWidget);
    expect(find.text('Elige un método para comenzar'), findsOneWidget);
    expect(find.text('Método de Asignación'), findsOneWidget);
    expect(find.text('Esquina Noroeste'), findsOneWidget);
    expect(find.text('Algoritmo de Johnson'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('help-button')));
    await tester.pumpAndSettle();
    expect(find.text('Ayuda rápida'), findsOneWidget);
    expect(find.text('Cómo utilizar la aplicación'), findsOneWidget);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('theme-toggle')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    final assignment = find.byKey(const ValueKey('module-assignment'));
    await tester.ensureVisible(assignment);
    await tester.pumpAndSettle();
    await tester.tap(assignment);
    await tester.pumpAndSettle();
    expect(find.text('Método de Asignación'), findsOneWidget);
  });

  testWidgets('el menú se adapta a una pantalla móvil', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LogiVerseApp());
    await tester.pumpAndSettle();

    expect(find.text('Elige un método para comenzar'), findsOneWidget);
    expect(find.byKey(const ValueKey('help-button')), findsOneWidget);
  });
}

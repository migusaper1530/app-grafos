@TestOn('browser')
library;

import 'dart:convert';
import 'dart:js_interop';

import 'package:app_grafos/app/app_theme.dart';
import 'package:app_grafos/models/nodo.dart';
import 'package:app_grafos/screens/asignacion_screen.dart';
import 'package:app_grafos/screens/esquina_nor_oeste_screen.dart';
import 'package:app_grafos/screens/grafo_screen.dart';
import 'package:app_grafos/screens/johnson_screen.dart';
import 'package:app_grafos/shared/persistence/graph_document.dart';
import 'package:app_grafos/shared/persistence/graph_document_codec.dart';
import 'package:app_grafos/shared/persistence/json_file_exporter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  final downloads = <({String name, String url})>[];
  late JSFunction listener;
  setUp(() {
    downloads.clear();
    listener = ((web.Event event) {
      final link = web.document.querySelector(
        '#__x_file_dom_element a',
      ) as web.HTMLAnchorElement?;
      if (link != null && event.target == link) {
        // Observe the real browser download request without writing test files.
        event.preventDefault();
        downloads.add((name: link.download, url: link.href));
      }
    }).toJS;
    web.document.body!.addEventListener('click', listener);
  });
  tearDown(() {
    web.document.body!.removeEventListener('click', listener);
    for (final download in downloads) {
      web.URL.revokeObjectURL(download.url);
    }
    web.document.querySelector('#__x_file_dom_element')?.remove();
  });

  test(
    'web descarga un Blob JSON UTF-8 sin consultar carpetas nativas',
    () async {
      final exporter = JsonFileExporter(
        downloadsDirectoryPath: () => throw StateError('No debe usarse en web'),
      );
      const codec = GraphDocumentCodec();
      final source = codec.encode(
        GraphDocument(
          name: 'Asignación de José',
          nodes: [
            Nodo(id: 'a', nombre: 'Álvaro', posicion: const Offset(10, 20)),
          ],
          connections: const [],
          metadata: const {'tipoOptimizacion': 'minimizar'},
        ),
      );
      expect(
        await exporter.save(source, name: 'Asignación de José.json'),
        'Asignación de José.json',
      );
      expect(downloads, hasLength(1));
      expect(downloads.single.name, 'Asignación de José.json');
      expect(downloads.single.url, startsWith('blob:'));
      final response = await web.window.fetch(downloads.single.url.toJS).toDart;
      expect(response.headers.get('content-type'), 'application/json');
      final contents = (await response.text().toDart).toDart;
      expect(contents, source);
      expect(codec.decode(contents).nodes.single.nombre, 'Álvaro');
    },
  );

  final screens = <String, Widget>{
    'Asignación': const AsignacionScreen(),
    'Grafos': const GrafoScreen(),
    'Johnson': const JohnsonScreen(),
    'Transporte': const EsquinaNorOesteScreen(),
  };
  for (final entry in screens.entries) {
    testWidgets('${entry.key}: el botón descarga JSON y cierra el diálogo', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: entry.value),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Más opciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      final fields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.first, 'Prueba Álvarez.json');
      await tester.ensureVisible(find.textContaining('Descargar'));
      await tester.tap(find.textContaining('Descargar'));
      await tester.pumpAndSettle();
      expect(downloads, hasLength(1));
      expect(downloads.single.name, 'Prueba Álvarez.json');
      final contents = await tester.runAsync(() async {
        final response = await web.window
            .fetch(downloads.single.url.toJS)
            .toDart;
        return (await response.text().toDart).toDart;
      });
      final data = jsonDecode(contents!) as Map<String, dynamic>;
      expect(data['nombreArchivo'], 'Prueba Álvarez.json');
      expect(data['nodos'], isList);
      expect(data['conexiones'], isList);
      if (entry.key == 'Asignación') {
        expect(data['tipoOptimizacion'], 'minimizar');
      }
      if (entry.key == 'Transporte') {
        expect(data['ofertas'], isMap);
        expect(data['demandas'], isMap);
      }
      if (entry.key == 'Johnson') {
        expect(data, contains('nodoInicialSeleccionadoId'));
      }
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.text('Descarga iniciada: Prueba Álvarez.json'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

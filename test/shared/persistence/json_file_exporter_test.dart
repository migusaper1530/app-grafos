@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:app_grafos/shared/persistence/json_file_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('escribe JSON UTF-8 en Descargas sin duplicar la extensión', () async {
    final directory = await Directory.systemTemp.createTemp(
      'json_export_test_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final exporter = JsonFileExporter(
      downloadsDirectoryPath: () async => directory.path,
    );
    const source =
        '{"nombreArchivo":"José Álvarez","tipoOptimizacion":"minimizar"}';
    final filename = await exporter.save(source, name: ' asignación.json ');
    expect(filename, 'asignación.json');
    expect(await File('${directory.path}/$filename').readAsString(), source);
    expect(
      jsonDecode(
        await File('${directory.path}/$filename').readAsString(),
      )['nombreArchivo'],
      'José Álvarez',
    );
  });

  test('un nombre con separadores no puede salir de Descargas', () async {
    final directory = await Directory.systemTemp.createTemp(
      'json_export_test_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final exporter = JsonFileExporter(
      downloadsDirectoryPath: () async => directory.path,
    );
    final filename = await exporter.save('{}', name: '../problema\\nuevo');
    expect(filename, '.._problema_nuevo.json');
    expect(await File('${directory.path}/$filename').exists(), isTrue);
  });

  test('informa si la carpeta Descargas no está disponible', () async {
    final exporter = JsonFileExporter(downloadsDirectoryPath: () async => null);
    await expectLater(exporter.save('{}', name: 'problema'), throwsStateError);
  });

  test(
    'usa un nombre válido para nombres vacíos y elimina caracteres inválidos',
    () {
      expect(JsonFileExporter.fileName('  '), 'proyecto.json');
      expect(JsonFileExporter.fileName('..'), 'proyecto.json');
      expect(
        JsonFileExporter.fileName('archivo\u0000?*.json'),
        'archivo___.json',
      );
    },
  );
}

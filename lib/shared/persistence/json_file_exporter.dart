import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> _downloadsDirectoryPath() async =>
    (await getDownloadsDirectory())?.path;

/// Exports JSON through the browser on web, or to Downloads on native platforms.
class JsonFileExporter {
  const JsonFileExporter({
    this.downloadsDirectoryPath = _downloadsDirectoryPath,
  });

  final Future<String?> Function() downloadsDirectoryPath;

  Future<String> save(String json, {required String name}) async {
    final filename = fileName(name);
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(json)),
      name: filename,
      mimeType: 'application/json',
    );

    if (kIsWeb) {
      // XFile uses a Blob and a download link; it does not access the filesystem.
      await file.saveTo(filename);
    } else {
      final directory = await downloadsDirectoryPath();
      if (directory == null || directory.isEmpty) {
        throw StateError('No se encontró la carpeta Descargas.');
      }
      await file.saveTo('$directory/$filename');
    }
    return filename;
  }

  /// Keep the name within Downloads and avoid duplicate JSON extensions.
  static String fileName(String name) {
    var clean = name.trim().replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_');
    clean = clean.replaceAll(RegExp(r'[. ]+$'), '');
    if (clean.isEmpty) clean = 'proyecto';
    return clean.toLowerCase().endsWith('.json') ? clean : '$clean.json';
  }
}

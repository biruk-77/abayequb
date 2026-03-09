// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  final root = Directory.current;
  final outputFile = File('full_project_dump.txt');

  final excludedFolders = [
    'build',
    '.dart_tool',
    '.git',
    '.idea',
    'node_modules',
  ];

  final buffer = StringBuffer();

  await for (var entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;

    final path = entity.path;

    // skip output file itself
    if (path.endsWith('full_project_dump.txt')) continue;

    // skip excluded folders
    if (excludedFolders.any(
      (f) => path.contains('$f${Platform.pathSeparator}'),
    )) {
      continue;
    }

    try {
      final relative = path.replaceFirst(
        root.path + Platform.pathSeparator,
        '',
      );
      final content = await entity.readAsString();

      buffer.writeln('===== FILE: $relative =====');
      buffer.writeln(content);
      buffer.writeln('\n');
    } catch (_) {
      // skip binary or unreadable files
    }
  }

  await outputFile.writeAsString(buffer.toString());

  print('✅ Project dump created: ${outputFile.path}');
}

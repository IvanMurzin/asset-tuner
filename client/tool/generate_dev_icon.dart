// Одноразовый скрипт: читает assets/icon/icon.png, переводит в grayscale
// и пишет рядом assets/icon/icon-dev.png. Запуск из client/:
//   dart run tool/generate_dev_icon.dart
import 'dart:io';

import 'package:image/image.dart' as img;

Future<void> main() async {
  final source = File('assets/icon/icon.png');
  if (!source.existsSync()) {
    stderr.writeln('Source icon not found: ${source.path}');
    exit(1);
  }

  final bytes = await source.readAsBytes();
  final decoded = img.decodePng(bytes);
  if (decoded == null) {
    stderr.writeln('Failed to decode PNG: ${source.path}');
    exit(1);
  }

  final grayscale = img.grayscale(decoded);
  final target = File('assets/icon/icon-dev.png');
  await target.writeAsBytes(img.encodePng(grayscale));
  stdout.writeln('Wrote ${target.path} (${target.lengthSync()} bytes)');
}

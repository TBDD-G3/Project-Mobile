// ignore_for_file: avoid_print

/// Script setup môi trường Web cho Drift + SQLite WASM.
///
/// Chạy lệnh này sau khi clone repo hoặc sau khi update drift_flutter:
///   dart run tool/setup_web.dart
///
/// Script sẽ:
///   1. Copy sqlite3.wasm từ pub cache vào web/
///   2. Compile drift_worker.dart → drift_worker.js
library;

import 'dart:io';

void main() async {
  print('🔧 Đang setup Drift Web assets...\n');

  // ── 1. Tìm sqlite3.wasm từ pub cache ──────────────────────────────────────
  final pubCachePaths = _getPubCacheCandidates();
  File? wasmSource;

  for (final cachePath in pubCachePaths) {
    final dir = Directory(cachePath);
    if (!dir.existsSync()) continue;
    final candidate = await _findFile(dir, 'sqlite3.wasm');
    if (candidate != null) {
      wasmSource = candidate;
      break;
    }
  }

  if (wasmSource == null) {
    _fail(
      'Không tìm thấy sqlite3.wasm trong pub cache.\n'
      'Hãy chạy "flutter pub get" trước rồi thử lại.',
    );
  }

  final webDir = Directory('web');
  if (!webDir.existsSync()) webDir.createSync();

  final wasmDest = File('web/sqlite3.wasm');
  wasmSource.copySync(wasmDest.path);
  print('✅ Đã copy: ${wasmSource.path}\n   → ${wasmDest.path}');

  // ── 2. Tạo drift_worker.dart tạm thời ─────────────────────────────────────
  final workerDart = File('web/drift_worker.dart');
  workerDart.writeAsStringSync(
    "import 'package:drift/wasm.dart';\n\n"
    "void main() {\n"
    "  WasmDatabase.workerMainForOpen();\n"
    "}\n",
  );
  print('\n📝 Đã tạo tạm: web/drift_worker.dart');

  // ── 3. Compile drift_worker.dart → drift_worker.js ────────────────────────
  print('\n🔨 Đang compile drift_worker.js (có thể mất 1-2 phút)...');
  final result = await Process.run(
    'dart',
    [
      'compile',
      'js',
      '-O2',
      '-o',
      'web/drift_worker.js',
      'web/drift_worker.dart',
    ],
    runInShell: true,
  );

  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    _fail('Compile thất bại. Kiểm tra lỗi bên trên.');
  }

  print('✅ Đã compile: web/drift_worker.js');

  // ── 4. Xóa các file tạm & không cần thiết ────────────────────────────────
  workerDart.deleteSync();
  for (final name in ['web/drift_worker.js.deps', 'web/drift_worker.js.map', 'web/drift_worker.dart']) {
    final f = File(name);
    if (f.existsSync()) f.deleteSync();
  }

  print('\n🎉 Setup hoàn tất! Chạy app bằng: flutter run -d chrome');
}

/// Tìm đệ quy file theo tên trong directory
Future<File?> _findFile(Directory dir, String filename) async {
  try {
    for (final entity in dir.listSync(recursive: false)) {
      final name = entity.path.split(Platform.pathSeparator).last;
      if (entity is File && name == filename) return entity;
      if (entity is Directory && !name.startsWith('.')) {
        final found = await _findFile(entity, filename);
        if (found != null) return found;
      }
    }
  } catch (_) {}
  return null;
}

List<String> _getPubCacheCandidates() {
  final home = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      '';
  return [
    '$home\\AppData\\Local\\Pub\\Cache\\hosted\\pub.dev',
    '$home/.pub-cache/hosted/pub.dev',
    Platform.environment['PUB_CACHE'] ?? '',
  ].where((p) => p.isNotEmpty).toList();
}

Never _fail(String msg) {
  stderr.writeln('\n❌ $msg');
  exit(1);
}

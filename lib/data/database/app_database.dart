import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/users.dart';
import 'tables/wallets.dart';
import 'tables/categories.dart';
import 'tables/transactions.dart';
import 'tables/budgets.dart';

import 'seeds/initial_seeder.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users, Wallets, Categories, Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'project_mobile_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (result) {
          if (result.missingFeatures.isNotEmpty) {
            // ignore: avoid_print
            print(
              'Drift Web: Một số tính năng không được hỗ trợ trên trình duyệt này: '
              '${result.missingFeatures}',
            );
          }
        },
      ),
    );
  }
}

/// Provider toàn cục cung cấp instance của AppDatabase
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider khởi tạo và seed dữ liệu ban đầu
final databaseInitProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  await InitialSeeder.seedDefaultData(db);
});

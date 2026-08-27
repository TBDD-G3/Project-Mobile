import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/users.dart';
import 'tables/wallets.dart';
import 'tables/categories.dart';
import 'tables/transactions.dart';
import 'tables/budgets.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users, Wallets, Categories, Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'project_mobile_db');
  }
}

/// Provider toàn cục cung cấp instance của AppDatabase
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

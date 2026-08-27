import 'package:drift/drift.dart';
import 'categories.dart';

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get month => integer()(); // 1 - 12
  IntColumn get year => integer()();
  RealColumn get limitAmount => real()();

  @override
  Set<Column> get primaryKey => {id};
}

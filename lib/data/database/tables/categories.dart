import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  // type enum values: 'income', 'expense'
  TextColumn get type => text()();
  IntColumn get iconCode => integer().nullable()();
  TextColumn get colorHex => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

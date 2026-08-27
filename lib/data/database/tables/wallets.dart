import 'package:drift/drift.dart';
import 'users.dart';

class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get name => text()();
  // type enum values: 'cash', 'bank', 'ewallet'
  TextColumn get type => text()();
  // Balance should always be updated via Transactions, never edited directly in UI
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  IntColumn get iconCode => integer().nullable()();
  TextColumn get colorHex => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

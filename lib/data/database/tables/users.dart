import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get currencyCode => text().withDefault(const Constant('VND'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

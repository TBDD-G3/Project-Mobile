import 'package:drift/drift.dart';
import 'wallets.dart';
import 'categories.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  // type enum values: 'income', 'expense', 'transfer'
  TextColumn get type => text()();
  // amount is always positive, type determines +/- sign
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get toWalletId => text().nullable().references(Wallets, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';
import 'categories.dart';
import 'wallets.dart'; // Giả định: bảng Wallets đã tồn tại cùng thư mục tables/ (do Leader / người phụ trách Wallet cung cấp)

/// Loại giao dịch: thu / chi / chuyển khoản.
enum TransactionType { income, expense, transfer }

class TransactionTypeConverter extends TypeConverter<TransactionType, String> {
  const TransactionTypeConverter();

  @override
  TransactionType fromSql(String fromDb) {
    return TransactionType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => throw ArgumentError('TransactionType không hợp lệ: $fromDb'),
    );
  }

  @override
  String toSql(TransactionType value) => value.name;
}

@DataClassName('TransactionData')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get categoryId =>
      text().nullable().references(Categories, #id)();
  TextColumn get type => text().map(const TransactionTypeConverter())();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get toWalletId => text().nullable().references(Wallets, #id)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        "CHECK (type IN ('income', 'expense', 'transfer'))",
        "CHECK (amount > 0)",
        // SQLite phải dùng tên cột thật trong schema: category_id / to_wallet_id
        "CHECK ("
            "(type = 'transfer' AND category_id IS NULL AND to_wallet_id IS NOT NULL) "
            "OR "
            "(type != 'transfer' AND category_id IS NOT NULL AND to_wallet_id IS NULL)"
            ")",
      ];
}

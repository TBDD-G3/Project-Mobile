import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/database/tables/transactions.dart';
import '../../../wallet/providers/wallet_providers.dart';

class TransactionRepository {
  final AppDatabase db;
  final Ref ref;

  TransactionRepository(this.db, this.ref);

  /// Tạo transaction mới + đồng bộ số dư ví.
  Future<void> createTransaction(Transaction tx) async {
    _validate(tx);

    await db.transaction(() async {
      await db.into(db.transactions).insert(tx.toCompanion(true));
      await _applyBalanceDelta(tx, reverse: false);
    });
  }

  /// Xoá transaction + hoàn tác đúng phần số dư ví đã áp dụng lúc tạo.
  Future<void> deleteTransaction(String id) async {
    final tx = await (db.select(db.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (tx == null) return;

    await db.transaction(() async {
      await (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();
      await _applyBalanceDelta(tx, reverse: true);
    });
  }

  Future<void> _applyBalanceDelta(Transaction tx, {required bool reverse}) async {
    final walletRepo = ref.read(walletRepositoryProvider);
    final sign = reverse ? -1 : 1;
    final type = _parseType(tx.type);

    switch (type) {
      case TransactionType.income:
        await walletRepo.updateBalance(tx.walletId, sign * tx.amount);
        break;
      case TransactionType.expense:
        await walletRepo.updateBalance(tx.walletId, -sign * tx.amount);
        break;
      case TransactionType.transfer:
        await walletRepo.updateBalance(tx.walletId, -sign * tx.amount);
        await walletRepo.updateBalance(tx.toWalletId!, sign * tx.amount);
        break;
    }
  }

  TransactionType _parseType(String typeValue) {
    return TransactionType.values.firstWhere(
      (type) => type.name == typeValue,
      orElse: () => throw ArgumentError('TransactionType không hợp lệ: $typeValue'),
    );
  }

  void _validate(Transaction tx) {
    if (tx.amount <= 0) {
      throw ArgumentError('amount phải luôn dương (> 0)');
    }

    final type = _parseType(tx.type);

    if (type == TransactionType.transfer) {
      if (tx.toWalletId == null) {
        throw ArgumentError('toWalletId bắt buộc khi type = transfer');
      }
      if (tx.toWalletId == tx.walletId) {
        throw ArgumentError('toWalletId không được trùng walletId');
      }
      if (tx.categoryId != null) {
        throw ArgumentError('categoryId phải null khi type = transfer');
      }
    } else {
      if (tx.categoryId == null) {
        throw ArgumentError('categoryId bắt buộc khi type = income/expense');
      }
      if (tx.toWalletId != null) {
        throw ArgumentError('toWalletId chỉ dùng khi type = transfer');
      }
    }
  }

  /// Dùng bởi transactionsByMonthProvider(month, year)
  Future<List<Transaction>> getByMonth(int month, int year) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (db.select(db.transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Dùng bởi transactionsByCategoryProvider(month, year)
  Future<Map<String, double>> getTotalByCategory(int month, int year) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final amountSum = db.transactions.amount.sum();
    final query = db.selectOnly(db.transactions)
      ..addColumns([db.transactions.categoryId, amountSum])
      ..where(db.transactions.date.isBiggerOrEqualValue(start) &
          db.transactions.date.isSmallerThanValue(end) &
          db.transactions.categoryId.isNotNull())
      ..groupBy([db.transactions.categoryId]);

    final rows = await query.get();
    final result = <String, double>{};
    for (final row in rows) {
      final categoryId = row.read(db.transactions.categoryId);
      final total = row.read(amountSum) ?? 0.0;
      if (categoryId != null) result[categoryId] = total;
    }
    return result;
  }
}

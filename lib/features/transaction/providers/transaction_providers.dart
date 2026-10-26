import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/firestore/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';

/// Member 2 gắn `FirestoreTransactionRepository` vào đây.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return _DefaultTransactionRepository();
});

/// Giao dịch theo tháng/năm. Member 3 dùng để vẽ biểu đồ xu hướng.
final transactionsByMonthProvider =
    StreamProvider.family<List<Transaction>, ({int month, int year})>((
      ref,
      arg,
    ) {
      return ref
          .watch(transactionRepositoryProvider)
          .watchTransactionsByMonth(arg.month, arg.year);
    });

/// Tổng tiền chi theo từng categoryId trong tháng, trả về `Map<String, double>`.
/// Member 3 dùng để vẽ pie chart và tính % ngân sách.
final transactionsByCategoryProvider =
    FutureProvider.family<Map<String, double>, ({int month, int year})>((
      ref,
      arg,
    ) async {
      final list = await ref.watch(transactionsByMonthProvider(arg).future);
      final result = <String, double>{};
      for (final tx in list) {
        if (tx.isExpense && tx.categoryId != null) {
          result[tx.categoryId!] = (result[tx.categoryId!] ?? 0.0) + tx.amount;
        }
      }
      return result;
    });

class _DefaultTransactionRepository implements TransactionRepository {
  final List<Transaction> _items = [];

  @override
  Stream<List<Transaction>> watchTransactionsByMonth(int month, int year) {
    final filtered = _items
        .where((t) => t.date.month == month && t.date.year == year)
        .toList();
    return Stream.value(filtered);
  }

  @override
  Stream<List<Transaction>> watchByWallet(String walletId) {
    return Stream.value(_items.where((t) => t.walletId == walletId).toList());
  }

  @override
  Future<void> insertTransaction(Transaction transaction) async {
    _items.insert(0, transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final idx = _items.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) _items[idx] = transaction;
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    _items.removeWhere((t) => t.id == transaction.id);
  }
}

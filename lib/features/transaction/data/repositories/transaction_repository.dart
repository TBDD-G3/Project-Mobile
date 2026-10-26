import '../../../../data/firestore/models/transaction.dart';

/// Interface dữ liệu Giao dịch. Member 2 implement bản Firestore.
/// Nhớ gọi `walletRepository.updateBalance(walletId, delta)` mỗi khi thêm/xóa giao dịch.
abstract interface class TransactionRepository {
  Stream<List<Transaction>> watchTransactionsByMonth(int month, int year);

  Stream<List<Transaction>> watchByWallet(String walletId);

  Future<void> insertTransaction(Transaction transaction);

  Future<void> updateTransaction(Transaction transaction);

  Future<void> deleteTransaction(Transaction transaction);
}

import '../../../../data/firestore/models/transaction.dart';

/// 🔒 Hợp đồng dữ liệu cố định của Giao dịch (Transaction).
///
/// - Member 2 implement `FirestoreTransactionRepository` từ interface này.
/// - Khi thêm/xóa giao dịch, Member 2 gọi `walletRepository.updateBalance(walletId, delta)`
///   để cập nhật số dư ví.
abstract interface class TransactionRepository {
  Stream<List<Transaction>> watchTransactionsByMonth(int month, int year);

  Stream<List<Transaction>> watchByWallet(String walletId);

  Future<void> insertTransaction(Transaction transaction);

  Future<void> updateTransaction(Transaction transaction);

  Future<void> deleteTransaction(Transaction transaction);
}

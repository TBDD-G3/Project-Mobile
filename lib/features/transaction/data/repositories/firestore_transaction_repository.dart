import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/models/transaction.dart';
import '../../../wallet/data/repositories/wallet_repository.dart';
import '../transaction_balance.dart';
import '../transaction_queries.dart';
import 'transaction_repository.dart';

/// Repository giao dịch chạy trên Firestore (Câu 7).
/// Mỗi giao dịch là một Document trong `transactions`, đọc/ghi qua
/// `transactionsCollection()` đã gắn converter.
///
/// Mỗi lần thêm/sửa/xóa đều cập nhật số dư ví qua
/// `WalletRepository.updateBalance` (đúng quy ước của Leader). Nếu cập nhật
/// ví lỗi thì khôi phục lại document giao dịch để dữ liệu không lệch nhau.
class FirestoreTransactionRepository implements TransactionRepository {
  final FirebaseFirestore _db;
  final WalletRepository _wallets;
  final String Function() _currentUserId;

  FirestoreTransactionRepository(
    this._db,
    this._wallets, {
    String Function()? currentUserId,
  }) : _currentUserId = currentUserId ?? _defaultUserId;

  static String _defaultUserId() =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  /// Luôn lọc theo `userId` để khớp firestore.rules, lọc tháng/ví ở Dart.
  Stream<List<Transaction>> _watchOfUser() {
    return transactionsCollection(_db)
        .where('userId', isEqualTo: _currentUserId())
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<Transaction>> watchTransactionsByMonth(int month, int year) {
    return _watchOfUser().map(
      (items) => sortNewestFirst(filterByMonth(items, month, year)),
    );
  }

  @override
  Stream<List<Transaction>> watchByWallet(String walletId) {
    return _watchOfUser().map(
      (items) =>
          sortNewestFirst(items.where((t) => involvesWallet(t, walletId))),
    );
  }

  @override
  Future<void> insertTransaction(Transaction transaction) async {
    final tx = transaction.copyWith(userId: _currentUserId());
    final ref = transactionsCollection(_db).doc(tx.id);

    await ref.set(tx);
    try {
      await applyBalanceDeltas(_wallets, balanceDeltas(after: tx));
    } catch (_) {
      await ref.delete();
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final ref = transactionsCollection(_db).doc(transaction.id);
    final snapshot = await ref.get();
    final before = snapshot.data();
    if (!snapshot.exists || before == null) {
      throw StateError('Không tìm thấy giao dịch ${transaction.id}');
    }

    final owner = before.userId.isNotEmpty ? before.userId : _currentUserId();
    final after = transaction.copyWith(userId: owner);

    await ref.set(after);
    try {
      await applyBalanceDeltas(
        _wallets,
        balanceDeltas(before: before, after: after),
      );
    } catch (_) {
      await ref.set(before);
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    final ref = transactionsCollection(_db).doc(transaction.id);
    final snapshot = await ref.get();
    final stored = snapshot.data();
    if (!snapshot.exists || stored == null) return;

    await ref.delete();
    try {
      await applyBalanceDeltas(_wallets, balanceDeltas(before: stored));
    } catch (_) {
      await ref.set(stored);
      rethrow;
    }
  }
}

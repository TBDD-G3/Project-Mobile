import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../data/firestore/models/transaction.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/repositories/firestore_transaction_repository.dart';
import '../data/repositories/mock_transaction_repository.dart';
import '../data/repositories/transaction_repository.dart';
import 'transaction_filter.dart';

/// TransactionRepository dùng Firestore, cập nhật số dư ví qua
/// `walletRepositoryProvider` của Leader.
///
/// Khi Firebase chưa được khởi tạo (chế độ `kUseMockData` hoặc widget test
/// không override) thì dùng bản in-memory rỗng nối với ví hiện tại để app vẫn
/// chạy được offline. Chạy thật thì Firebase luôn đã init nên không rơi vào
/// nhánh này.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final wallets = ref.watch(walletRepositoryProvider);
  try {
    final db = ref.watch(firebaseFirestoreProvider);
    return FirestoreTransactionRepository(db, wallets);
  } catch (_) {
    return MockTransactionRepository(walletRepository: wallets);
  }
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

/// Bộ lọc đang chọn trên màn Giao dịch (tháng, loại, ví, danh mục).
final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.forMonthOf(DateTime.now());
});

/// Giao dịch của tháng đang chọn, đã áp các bộ lọc loại/ví/danh mục.
final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((
  ref,
) {
  final filter = ref.watch(transactionFilterProvider);
  final monthAsync = ref.watch(
    transactionsByMonthProvider((month: filter.month, year: filter.year)),
  );
  return monthAsync.whenData((items) => applyTransactionFilter(items, filter));
});

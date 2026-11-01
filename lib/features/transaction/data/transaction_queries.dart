import '../../../data/firestore/models/transaction.dart';

/// Giữ các giao dịch thuộc tháng/năm chỉ định.
List<Transaction> filterByMonth(
  Iterable<Transaction> items,
  int month,
  int year,
) {
  return items
      .where((t) => t.date.month == month && t.date.year == year)
      .toList();
}

/// Giao dịch có liên quan tới ví: ví nguồn hoặc ví đích (chuyển khoản).
bool involvesWallet(Transaction tx, String walletId) {
  return tx.walletId == walletId || tx.toWalletId == walletId;
}

/// Sắp xếp mới nhất trước. Sort ở Dart để Firestore khỏi cần composite index.
List<Transaction> sortNewestFirst(Iterable<Transaction> items) {
  final list = items.toList();
  list.sort((a, b) {
    final byDate = b.date.compareTo(a.date);
    return byDate != 0 ? byDate : a.id.compareTo(b.id);
  });
  return list;
}

import '../../../data/firestore/models/transaction.dart';
import '../data/transaction_queries.dart';

/// Bộ lọc danh sách giao dịch: tháng/năm là bắt buộc, còn lại tùy chọn.
class TransactionFilter {
  final int month;
  final int year;

  /// 'income', 'expense' hoặc 'transfer'; null là tất cả.
  final String? type;
  final String? walletId;
  final String? categoryId;

  const TransactionFilter({
    required this.month,
    required this.year,
    this.type,
    this.walletId,
    this.categoryId,
  });

  factory TransactionFilter.forMonthOf(DateTime date) {
    return TransactionFilter(month: date.month, year: date.year);
  }

  bool get hasActiveFilters =>
      type != null || walletId != null || categoryId != null;

  TransactionFilter copyWith({
    int? month,
    int? year,
    String? type,
    String? walletId,
    String? categoryId,
    bool clearType = false,
    bool clearWallet = false,
    bool clearCategory = false,
  }) {
    return TransactionFilter(
      month: month ?? this.month,
      year: year ?? this.year,
      type: clearType ? null : (type ?? this.type),
      walletId: clearWallet ? null : (walletId ?? this.walletId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    );
  }

  /// Giữ nguyên tháng, bỏ hết điều kiện lọc.
  TransactionFilter cleared() => TransactionFilter(month: month, year: year);

  /// Dịch tháng đi [delta] tháng (âm là lùi), tự xử lý qua năm.
  TransactionFilter shiftMonth(int delta) {
    final moved = DateTime(year, month + delta);
    return copyWith(month: moved.month, year: moved.year);
  }

  /// Ví khớp nếu là ví nguồn hoặc ví đích của chuyển khoản.
  bool matches(Transaction tx) {
    if (type != null && tx.type != type) return false;
    if (walletId != null && !involvesWallet(tx, walletId!)) return false;
    if (categoryId != null && tx.categoryId != categoryId) return false;
    return true;
  }
}

List<Transaction> applyTransactionFilter(
  Iterable<Transaction> items,
  TransactionFilter filter,
) {
  return items.where(filter.matches).toList();
}

/// Các giao dịch trong cùng một ngày.
class TransactionDayGroup {
  final DateTime day;
  final List<Transaction> items;

  const TransactionDayGroup({required this.day, required this.items});

  /// Thu trừ chi trong ngày (chuyển khoản không tính).
  double get net {
    var sum = 0.0;
    for (final tx in items) {
      if (tx.isIncome) sum += tx.amount;
      if (tx.isExpense) sum -= tx.amount;
    }
    return sum;
  }
}

/// Gom theo ngày, ngày mới nhất lên trước, trong ngày cũng mới nhất trước.
List<TransactionDayGroup> groupTransactionsByDay(Iterable<Transaction> items) {
  final byDay = <DateTime, List<Transaction>>{};
  for (final tx in sortNewestFirst(items)) {
    final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
    byDay.putIfAbsent(day, () => []).add(tx);
  }
  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return [for (final d in days) TransactionDayGroup(day: d, items: byDay[d]!)];
}

/// Tổng thu và tổng chi của danh sách (chuyển khoản không tính).
({double income, double expense}) summarize(Iterable<Transaction> items) {
  var income = 0.0;
  var expense = 0.0;
  for (final tx in items) {
    if (tx.isIncome) income += tx.amount;
    if (tx.isExpense) expense += tx.amount;
  }
  return (income: income, expense: expense);
}

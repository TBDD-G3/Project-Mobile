import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/firestore/models/transaction.dart';
import '../../transaction/providers/transaction_providers.dart';

/// Tổng thu và tổng chi của một tháng.
class MonthTotals {
  const MonthTotals({required this.income, required this.expense});

  final double income;
  final double expense;

  double get balance => income - expense;
}

/// Một cột trên biểu đồ sáu tháng.
class MonthPoint {
  const MonthPoint({
    required this.month,
    required this.year,
    required this.income,
    required this.expense,
  });

  final int month;
  final int year;
  final double income;
  final double expense;
}

/// Tháng đang xem ở tab Báo cáo.
final analyticsMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Tổng thu/chi của tháng — đọc qua `transactionsByMonthProvider` của Member 2.
final monthTotalsProvider =
    FutureProvider.family<MonthTotals, ({int month, int year})>((ref, arg) async {
      final transactions = await ref.watch(
        transactionsByMonthProvider(arg).future,
      );
      return _totalsOf(transactions);
    });

/// Sáu tháng gần nhất tính tới tháng đang chọn, cho biểu đồ cột.
final sixMonthTotalsProvider = FutureProvider<List<MonthPoint>>((ref) async {
  final selected = ref.watch(analyticsMonthProvider);
  final futures = <Future<MonthTotals>>[];
  final months = <DateTime>[];

  for (var i = 5; i >= 0; i--) {
    final month = DateTime(selected.year, selected.month - i);
    months.add(month);
    // ref.watch phải gọi trước await để không dùng ref sau khi bất đồng bộ.
    futures.add(ref.watch(monthTotalsProvider((
      month: month.month,
      year: month.year,
    )).future));
  }

  final totals = await Future.wait(futures);
  return [
    for (var i = 0; i < months.length; i++)
      MonthPoint(
        month: months[i].month,
        year: months[i].year,
        income: totals[i].income,
        expense: totals[i].expense,
      ),
  ];
});

MonthTotals _totalsOf(List<Transaction> transactions) {
  var income = 0.0;
  var expense = 0.0;
  for (final transaction in transactions) {
    if (transaction.isIncome) {
      income += transaction.amount;
    } else if (transaction.isExpense) {
      expense += transaction.amount;
    }
  }
  return MonthTotals(income: income, expense: expense);
}

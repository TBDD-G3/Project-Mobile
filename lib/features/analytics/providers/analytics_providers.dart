import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../budget/providers/budget_providers.dart';

class AnalyticsSummary {
  final double totalBudget;
  final double totalIncome;
  final double totalSpent;
  final List<CategorySpendRow> categoryRows;
  final List<CashFlowRow> cashFlowRows;

  const AnalyticsSummary({
    required this.totalBudget,
    required this.totalIncome,
    required this.totalSpent,
    required this.categoryRows,
    required this.cashFlowRows,
  });
}

class CategorySpendRow {
  final String categoryId;
  final String name;
  final double amount;
  final String colorHex;

  const CategorySpendRow({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.colorHex,
  });
}

class CashFlowRow {
  final String label;
  final double income;
  final double expense;

  const CashFlowRow({
    required this.label,
    required this.income,
    required this.expense,
  });
}

final analyticsWalletsProvider = FutureProvider<List<Wallet>>((ref) {
  return ref.watch(appDatabaseProvider).select(ref.watch(appDatabaseProvider).wallets).get();
});

final analyticsProvider = FutureProvider.family<AnalyticsSummary, ({DateTime start, DateTime endExclusive, String? walletId})>(
  (ref, args) async {
    final db = ref.watch(appDatabaseProvider);
    final budgetRepo = ref.watch(budgetRepositoryProvider);
    final summary = await budgetRepo.getBudgetSummaryForMonth(args.start.month, args.start.year);

    final categories = await db.select(db.categories).get();
    final categoryMap = {for (final item in categories) item.id: item};
    final transactionQuery = db.select(db.transactions)
      ..where(
        (transaction) =>
            transaction.date.isBiggerOrEqualValue(args.start) &
            transaction.date.isSmallerThanValue(args.endExclusive),
      );
    if (args.walletId != null) {
      transactionQuery.where((transaction) => transaction.walletId.equals(args.walletId!));
    }
    final monthTransactions = await transactionQuery.get();
    final expenses = monthTransactions.where((transaction) => transaction.type == 'expense').toList();
    final incomeTransactions = monthTransactions.where((transaction) => transaction.type == 'income').toList();

    final rows = <CategorySpendRow>[];
    final spendingByCategory = <String, double>{};
    for (final expense in expenses) {
      final categoryId = expense.categoryId ?? 'uncategorized';
      spendingByCategory[categoryId] =
          (spendingByCategory[categoryId] ?? 0) + expense.amount;
    }

    for (final entry in spendingByCategory.entries) {
      final category = categoryMap[entry.key];
      rows.add(
        CategorySpendRow(
          categoryId: entry.key,
          name: category?.name ?? 'Chưa phân loại',
          amount: entry.value,
          colorHex: category?.colorHex ?? '#64748B',
        ),
      );
    }

    rows.sort((a, b) => b.amount.compareTo(a.amount));
    final dayCount = args.endExclusive.difference(args.start).inDays;
    final cashFlowRows = List.generate((dayCount + 6) ~/ 7, (index) {
      final start = args.start.add(Duration(days: index * 7));
      final endExclusive = start.add(const Duration(days: 7)).isBefore(args.endExclusive)
          ? start.add(const Duration(days: 7))
          : args.endExclusive;
      final income = incomeTransactions
          .where((transaction) => !transaction.date.isBefore(start) && transaction.date.isBefore(endExclusive))
          .fold<double>(0, (total, transaction) => total + transaction.amount);
      final expense = expenses
          .where((transaction) => !transaction.date.isBefore(start) && transaction.date.isBefore(endExclusive))
          .fold<double>(0, (total, transaction) => total + transaction.amount);

      return CashFlowRow(
        label: '${start.day}/${start.month}',
        income: income,
        expense: expense,
      );
    });

    return AnalyticsSummary(
      totalBudget: summary.totalBudget,
      totalIncome: incomeTransactions.fold<double>(
        0,
        (total, transaction) => total + transaction.amount,
      ),
      totalSpent: expenses.fold<double>(0, (total, transaction) => total + transaction.amount),
      categoryRows: rows,
      cashFlowRows: cashFlowRows,
    );
  },
);

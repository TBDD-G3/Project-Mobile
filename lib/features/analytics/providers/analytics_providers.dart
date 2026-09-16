import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../budget/data/repositories/budget_repository.dart';

class AnalyticsSummary {
  final double totalBudget;
  final double totalSpent;
  final List<_CategorySpendRow> categoryRows;

  const AnalyticsSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.categoryRows,
  });
}

class _CategorySpendRow {
  final String categoryId;
  final String name;
  final double amount;
  final String colorHex;

  const _CategorySpendRow({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.colorHex,
  });
}

final analyticsProvider = FutureProvider.family<AnalyticsSummary, ({int month, int year})>(
  (ref, args) async {
    final db = ref.watch(appDatabaseProvider);
    final budgetRepo = ref.watch(budgetRepositoryProvider);
    final summary = await budgetRepo.getBudgetSummaryForMonth(args.month, args.year);

    final categories = await db.select(db.categories).get();
    final categoryMap = {for (final item in categories) item.id: item};

    final rows = <_CategorySpendRow>[];
    for (final entry in summary.categorySpending.entries) {
      final category = categoryMap[entry.key];
      rows.add(
        _CategorySpendRow(
          categoryId: entry.key,
          name: category?.name ?? 'Khác',
          amount: entry.value,
          colorHex: category?.colorHex ?? '#64748B',
        ),
      );
    }

    rows.sort((a, b) => b.amount.compareTo(a.amount));

    return AnalyticsSummary(
      totalBudget: summary.totalBudget,
      totalSpent: summary.spentAmount,
      categoryRows: rows,
    );
  },
);

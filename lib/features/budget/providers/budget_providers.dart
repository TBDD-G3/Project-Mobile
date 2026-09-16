import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../data/repositories/budget_repository.dart';

class BudgetRow {
  final Category category;
  double budgetAmount;

  BudgetRow({required this.category, required this.budgetAmount});

  double get amount => budgetAmount;
  set amount(double value) => budgetAmount = value;
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BudgetRepository(db);
});

final budgetRowsProvider = FutureProvider.family<List<BudgetRow>, ({int month, int year})>(
  (ref, args) async {
    final db = ref.watch(appDatabaseProvider);
    final repo = ref.watch(budgetRepositoryProvider);

    final categories = await db.select(db.categories).get();
    final budgets = await repo.getBudgetsForMonth(args.month, args.year);
    final budgetByCategory = {
      for (final budget in budgets) budget.categoryId: budget.limitAmount,
    };

    final rows = <BudgetRow>[];
    for (final category in categories.where((item) => item.type == 'expense')) {
      rows.add(
        BudgetRow(
          category: category,
          budgetAmount: budgetByCategory[category.id] ?? 0,
        ),
      );
    }

    return rows;
  },
);

final budgetSummaryProvider = FutureProvider.family<BudgetSummary, ({int month, int year})>(
  (ref, args) => ref.watch(budgetRepositoryProvider).getBudgetSummaryForMonth(args.month, args.year),
);

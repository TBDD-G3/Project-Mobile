import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/database/app_database.dart';

class BudgetSummary {
  final double totalBudget;
  final double spentAmount;
  final double remainingAmount;
  final Map<String, double> categorySpending;

  const BudgetSummary({
    required this.totalBudget,
    required this.spentAmount,
    required this.remainingAmount,
    required this.categorySpending,
  });
}

class BudgetRepository {
  final AppDatabase _db;

  BudgetRepository(this._db);

  Future<List<Budget>> getBudgetsForMonth(int month, int year) {
    return (_db.select(_db.budgets)
          ..where((tbl) => tbl.month.equals(month) & tbl.year.equals(year)))
        .get();
  }

  Future<void> upsertBudget({
    required String categoryId,
    required int month,
    required int year,
    required double limitAmount,
  }) async {
    final existing = await (_db.select(_db.budgets)
          ..where(
            (tbl) =>
                tbl.categoryId.equals(categoryId) &
                tbl.month.equals(month) &
                tbl.year.equals(year),
          ))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.budgets)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(BudgetsCompanion(limitAmount: Value(limitAmount)));
      return;
    }

    await _db.into(_db.budgets).insert(
      BudgetsCompanion.insert(
        id: const Uuid().v4(),
        categoryId: categoryId,
        month: month,
        year: year,
        limitAmount: limitAmount,
      ),
    );
  }

  Future<BudgetSummary> getBudgetSummaryForMonth(int month, int year) async {
    final budgets = await getBudgetsForMonth(month, year);
    final totalBudget = budgets.fold<double>(0, (sum, budget) => sum + budget.limitAmount);

    final budgetCategoryIds = budgets.map((budget) => budget.categoryId).toList();
    final categorySpending = <String, double>{};

    if (budgetCategoryIds.isNotEmpty) {
      final expenses = await (_db.select(_db.transactions)
            ..where(
              (t) =>
                  t.type.equals('expense') &
                  t.date.month.equals(month) &
                  t.date.year.equals(year) &
                  t.categoryId.isNotNull() &
                  t.categoryId.isIn(budgetCategoryIds),
            ))
        .get();

      for (final item in expenses) {
        final categoryId = item.categoryId;
        if (categoryId != null) {
          categorySpending[categoryId] =
              (categorySpending[categoryId] ?? 0) + item.amount;
        }
      }
    }

    final spentAmount = categorySpending.values.fold<double>(0, (sum, value) => sum + value);

    return BudgetSummary(
      totalBudget: totalBudget,
      spentAmount: spentAmount,
      remainingAmount: totalBudget - spentAmount,
      categorySpending: categorySpending,
    );
  }
}

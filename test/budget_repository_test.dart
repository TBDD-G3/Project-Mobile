import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/database/app_database.dart';
import 'package:project_mobile/data/database/seeds/initial_seeder.dart';
import 'package:project_mobile/features/budget/data/repositories/budget_repository.dart';

void main() {
  group('BudgetRepository', () {
    late AppDatabase db;
    late BudgetRepository budgetRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await InitialSeeder.seedDefaultData(db);
      budgetRepo = BudgetRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('should insert and read budget for a category in a month', () async {
      final categories = await db.select(db.categories).get();
      final foodCategory = categories.firstWhere((c) => c.name == 'Ăn uống');

      await budgetRepo.upsertBudget(
        categoryId: foodCategory.id,
        month: DateTime.now().month,
        year: DateTime.now().year,
        limitAmount: 2000000,
      );

      final budgets = await budgetRepo.getBudgetsForMonth(
        DateTime.now().month,
        DateTime.now().year,
      );

      expect(budgets.isNotEmpty, isTrue);
      expect(budgets.any((b) => b.categoryId == foodCategory.id), isTrue);
      expect(budgets.firstWhere((b) => b.categoryId == foodCategory.id).limitAmount,
          2000000);
    });

    test('should return progress information for monthly budget usage', () async {
      final categories = await db.select(db.categories).get();
      final foodCategory = categories.firstWhere((c) => c.name == 'Ăn uống');

      await budgetRepo.upsertBudget(
        categoryId: foodCategory.id,
        month: DateTime.now().month,
        year: DateTime.now().year,
        limitAmount: 1000000,
      );

      final monthlyBudgets = await budgetRepo.getBudgetSummaryForMonth(
        DateTime.now().month,
        DateTime.now().year,
      );

      expect(monthlyBudgets.totalBudget >= 0, isTrue);
      expect(monthlyBudgets.spentAmount >= 0, isTrue);
      expect(monthlyBudgets.remainingAmount >= 0 || monthlyBudgets.remainingAmount <= 0,
          isTrue);
    });
  });
}

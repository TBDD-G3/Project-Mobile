import '../../../../data/firestore/models/budget.dart';

/// Interface dữ liệu Ngân sách. Member 3 implement bản Firestore từ đây.
abstract interface class BudgetRepository {
  Stream<List<Budget>> watchBudgetsByMonth(int month, int year);

  Future<Budget?> getBudgetByCategory(String categoryId, int month, int year);

  Future<void> insertBudget(Budget budget);

  Future<void> updateBudget(Budget budget);

  Future<void> deleteBudget(String id);
}

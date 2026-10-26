import '../../../../data/firestore/models/budget.dart';

/// 🔒 Hợp đồng dữ liệu cố định của Ngân sách (Budget).
///
/// - Member 3 implement `FirestoreBudgetRepository` từ interface này.
abstract interface class BudgetRepository {
  Stream<List<Budget>> watchBudgetsByMonth(int month, int year);

  Future<Budget?> getBudgetByCategory(String categoryId, int month, int year);

  Future<void> insertBudget(Budget budget);

  Future<void> updateBudget(Budget budget);

  Future<void> deleteBudget(String id);
}

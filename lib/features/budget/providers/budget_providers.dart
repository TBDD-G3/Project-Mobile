import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/firestore/models/budget.dart';
import '../data/repositories/budget_repository.dart';

/// 📌 Member 3 implement `FirestoreBudgetRepository` cho chức năng quản lý Ngân sách.
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return _DefaultBudgetRepository();
});

/// Stream danh sách ngân sách theo tháng/năm.
final budgetsByMonthProvider =
    StreamProvider.family<List<Budget>, ({int month, int year})>((ref, arg) {
      return ref
          .watch(budgetRepositoryProvider)
          .watchBudgetsByMonth(arg.month, arg.year);
    });

class _DefaultBudgetRepository implements BudgetRepository {
  final List<Budget> _items = [];

  @override
  Stream<List<Budget>> watchBudgetsByMonth(int month, int year) {
    final filtered = _items
        .where((b) => b.month == month && b.year == year)
        .toList();
    return Stream.value(filtered);
  }

  @override
  Future<Budget?> getBudgetByCategory(
    String categoryId,
    int month,
    int year,
  ) async {
    for (final b in _items) {
      if (b.categoryId == categoryId && b.month == month && b.year == year) {
        return b;
      }
    }
    return null;
  }

  @override
  Future<void> insertBudget(Budget budget) async {
    _items.add(budget);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final idx = _items.indexWhere((b) => b.id == budget.id);
    if (idx != -1) _items[idx] = budget;
  }

  @override
  Future<void> deleteBudget(String id) async {
    _items.removeWhere((b) => b.id == id);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../data/firestore/models/budget.dart';
import '../../../data/firestore/models/category.dart';
import '../../category/providers/category_providers.dart';
import '../../transaction/providers/transaction_providers.dart';
import '../data/budget_progress.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/firestore_budget_repository.dart';

/// Repository ngân sách chạy trên Firestore (Câu 7).
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return FirestoreBudgetRepository(ref.watch(firebaseFirestoreProvider));
});

/// Tháng đang xem ở tab Ngân sách (mặc định tháng hiện tại).
final budgetMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Danh sách ngân sách theo tháng/năm.
final budgetsByMonthProvider =
    StreamProvider.family<List<Budget>, ({int month, int year})>((ref, arg) {
      return ref
          .watch(budgetRepositoryProvider)
          .watchBudgetsByMonth(arg.month, arg.year);
    });

/// Tiến độ từng ngân sách: ghép ngân sách với tổng chi theo danh mục.
final budgetProgressProvider =
    Provider.family<AsyncValue<List<BudgetProgress>>, ({int month, int year})>(
      (ref, arg) {
        final budgets = ref.watch(budgetsByMonthProvider(arg));
        final spending = ref.watch(transactionsByCategoryProvider(arg));
        return budgets.when(
          loading: () => const AsyncLoading(),
          error: (error, stack) => AsyncError(error, stack),
          data: (list) => spending.when(
            loading: () => const AsyncLoading(),
            error: (error, stack) => AsyncError(error, stack),
            data: (byCategory) => AsyncData(
              buildBudgetProgress(list, byCategory),
            ),
          ),
        );
      },
    );

/// Các danh mục chi — dùng cho form đặt hạn mức và biểu đồ.
final expenseCategoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  return ref.watch(categoriesStreamProvider).whenData(
    (list) => list.where((category) => category.isExpense).toList()
      ..sort((a, b) => a.name.compareTo(b.name)),
  );
});

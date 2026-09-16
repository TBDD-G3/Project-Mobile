import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../data/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionRepository(db, ref);
});

final transactionsByMonthProvider =
    FutureProvider.family<List<Transaction>, ({int month, int year})>(
  (ref, params) {
    return ref
        .watch(transactionRepositoryProvider)
        .getByMonth(params.month, params.year);
  },
);

final transactionsByCategoryProvider =
    FutureProvider.family<Map<String, double>, ({int month, int year})>(
  (ref, params) {
    return ref
        .watch(transactionRepositoryProvider)
        .getTotalByCategory(params.month, params.year);
  },
);

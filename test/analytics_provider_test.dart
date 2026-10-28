import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/database/app_database.dart';
import 'package:project_mobile/data/database/seeds/initial_seeder.dart';
import 'package:project_mobile/features/analytics/providers/analytics_providers.dart';

void main() {
  test('reports income and all expenses for the selected month', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await InitialSeeder.seedDefaultData(db);
    final categories = await db.select(db.categories).get();
    final shoppingCategory = categories.firstWhere((category) => category.name == 'Mua sắm');
    final incomeCategory = categories.firstWhere((category) => category.type == 'income');
    final wallet = (await db.select(db.wallets).get()).first;
    final now = DateTime.now();

    await db.batch((batch) {
      batch.insertAll(db.transactions, [
        TransactionsCompanion.insert(
          id: 'unbudgeted-expense',
          walletId: wallet.id,
          categoryId: Value(shoppingCategory.id),
          type: 'expense',
          amount: 125000,
          date: DateTime(now.year, now.month, 8),
        ),
        TransactionsCompanion.insert(
          id: 'monthly-income',
          walletId: wallet.id,
          categoryId: Value(incomeCategory.id),
          type: 'income',
          amount: 900000,
          date: DateTime(now.year, now.month, 8),
        ),
        TransactionsCompanion.insert(
          id: 'next-month-expense',
          walletId: wallet.id,
          categoryId: Value(shoppingCategory.id),
          type: 'expense',
          amount: 70000,
          date: DateTime(now.year, now.month + 1, 1),
        ),
      ]);
    });
    expect(await db.select(db.transactions).get(), hasLength(3));

    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    final report = await container.read(
      analyticsProvider((
        start: DateTime(now.year, now.month),
        endExclusive: DateTime(now.year, now.month + 1),
        walletId: null,
      )).future,
    );

    expect(report.totalIncome, 900000);
    expect(report.totalSpent, 125000);
    expect(report.categoryRows.single.name, 'Mua sắm');
    expect(report.cashFlowRows[1].income, 900000);
    expect(report.cashFlowRows[1].expense, 125000);
  });
}
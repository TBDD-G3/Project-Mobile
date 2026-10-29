import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/firestore/models/transaction.dart';
import 'package:project_mobile/features/transaction/data/repositories/mock_transaction_repository.dart';
import 'package:project_mobile/features/transaction/providers/transaction_filter.dart';
import 'package:project_mobile/features/transaction/providers/transaction_providers.dart';
import 'package:project_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:project_mobile/features/wallet/providers/wallet_providers.dart';

Transaction _tx({
  required String id,
  String walletId = 'mock-cash',
  String? categoryId = 'cat-exp-an-uong',
  String type = 'expense',
  double amount = 100000,
  DateTime? date,
  String? toWalletId,
}) {
  return Transaction(
    id: id,
    userId: 'mock-user',
    walletId: walletId,
    categoryId: categoryId,
    type: type,
    amount: amount,
    date: date ?? DateTime(2026, 10, 15, 9),
    toWalletId: toWalletId,
  );
}

void main() {
  const october = (month: 10, year: 2026);
  late MockWalletRepository wallets;
  late MockTransactionRepository repo;
  late ProviderContainer container;

  setUp(() {
    wallets = MockWalletRepository.seeded();
    repo = MockTransactionRepository(
      walletRepository: wallets,
      initial: [
        _tx(id: 'food-1', amount: 50000),
        _tx(id: 'food-2', amount: 70000, date: DateTime(2026, 10, 16)),
        _tx(id: 'shop', categoryId: 'cat-exp-mua-sam', amount: 200000),
        _tx(
          id: 'salary',
          type: 'income',
          categoryId: 'cat-inc-luong',
          walletId: 'mock-bank',
          amount: 15000000,
        ),
        _tx(
          id: 'move',
          type: 'transfer',
          categoryId: null,
          toWalletId: 'mock-bank',
          amount: 1000000,
        ),
        _tx(id: 'last-month', date: DateTime(2026, 9, 20), amount: 999),
      ],
    );
    container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(repo),
        walletRepositoryProvider.overrideWithValue(wallets),
      ],
    );
    addTearDown(container.dispose);
  });

  test('transactionRepositoryProvider trả về repository được override', () {
    expect(container.read(transactionRepositoryProvider), same(repo));
  });

  group('transactionsByMonthProvider', () {
    test('chỉ phát giao dịch của tháng được hỏi', () async {
      final list = await container.read(
        transactionsByMonthProvider(october).future,
      );

      expect(list.length, 5);
      expect(list.any((t) => t.id == 'last-month'), isFalse);
    });

    test('phát lại khi có giao dịch mới trong tháng', () async {
      final sub = container.listen(
        transactionsByMonthProvider(october),
        (_, _) {},
      );
      addTearDown(sub.close);
      await container.read(transactionsByMonthProvider(october).future);

      await repo.insertTransaction(_tx(id: 'extra'));
      await pumpEventQueue();

      expect(
        container.read(transactionsByMonthProvider(october)).value!.length,
        6,
      );
    });

    test('tháng không có dữ liệu thì phát danh sách rỗng', () async {
      final list = await container.read(
        transactionsByMonthProvider((month: 1, year: 2020)).future,
      );

      expect(list, isEmpty);
    });
  });

  group('transactionsByCategoryProvider', () {
    test('cộng tiền chi theo categoryId, bỏ thu và chuyển khoản', () async {
      final totals = await container.read(
        transactionsByCategoryProvider(october).future,
      );

      expect(totals, {'cat-exp-an-uong': 120000, 'cat-exp-mua-sam': 200000});
    });

    test('cập nhật khi thêm giao dịch chi mới', () async {
      final sub = container.listen(
        transactionsByCategoryProvider(october),
        (_, _) {},
      );
      addTearDown(sub.close);
      await container.read(transactionsByCategoryProvider(october).future);

      await repo.insertTransaction(_tx(id: 'food-3', amount: 30000));
      await pumpEventQueue();

      final totals = await container.read(
        transactionsByCategoryProvider(october).future,
      );
      expect(totals['cat-exp-an-uong'], 150000);
    });
  });

  group('filteredTransactionsProvider', () {
    Future<List<String>> idsFor(TransactionFilter filter) async {
      container.read(transactionFilterProvider.notifier).state = filter;
      await container.read(
        transactionsByMonthProvider((month: filter.month, year: filter.year))
            .future,
      );
      return container
          .read(filteredTransactionsProvider)
          .value!
          .map((t) => t.id)
          .toList();
    }

    const base = TransactionFilter(month: 10, year: 2026);

    test('bộ lọc mặc định là tháng hiện tại', () {
      final now = DateTime.now();
      final filter = container.read(transactionFilterProvider);

      expect((filter.month, filter.year), (now.month, now.year));
      expect(filter.hasActiveFilters, isFalse);
    });

    test('không lọc thì trả đủ giao dịch của tháng', () async {
      expect((await idsFor(base)).length, 5);
    });

    test('lọc theo loại', () async {
      expect(await idsFor(base.copyWith(type: 'income')), ['salary']);
      expect(await idsFor(base.copyWith(type: 'transfer')), ['move']);
    });

    test('lọc theo ví gồm cả ví đích của chuyển khoản', () async {
      final ids = await idsFor(base.copyWith(walletId: 'mock-bank'));

      expect(ids, unorderedEquals(['salary', 'move']));
    });

    test('lọc theo danh mục', () async {
      final ids = await idsFor(base.copyWith(categoryId: 'cat-exp-an-uong'));

      expect(ids, unorderedEquals(['food-1', 'food-2']));
    });

    test('đổi sang tháng khác lấy dữ liệu tháng đó', () async {
      final ids = await idsFor(base.shiftMonth(-1));

      expect(ids, ['last-month']);
    });
  });
}

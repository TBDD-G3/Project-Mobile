import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/firestore/models/transaction.dart';
import 'package:project_mobile/data/firestore/models/wallet.dart';
import 'package:project_mobile/features/transaction/data/repositories/mock_transaction_repository.dart';
import 'package:project_mobile/features/transaction/data/transaction_balance.dart';
import 'package:project_mobile/features/transaction/data/transaction_queries.dart';
import 'package:project_mobile/features/transaction/providers/transaction_filter.dart';
import 'package:project_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';

Wallet _wallet(String id, double balance) {
  return Wallet(
    id: id,
    userId: 'u-1',
    name: id,
    type: 'cash',
    balance: balance,
    createdAt: DateTime(2026, 1, 1),
  );
}

Transaction _tx({
  String id = 't-1',
  String walletId = 'w-cash',
  String? categoryId = 'cat-exp-an-uong',
  String type = 'expense',
  double amount = 100000,
  DateTime? date,
  String? note,
  String? toWalletId,
}) {
  return Transaction(
    id: id,
    userId: 'u-1',
    walletId: walletId,
    categoryId: categoryId,
    type: type,
    amount: amount,
    date: date ?? DateTime(2026, 10, 15, 9),
    note: note,
    toWalletId: toWalletId,
  );
}

/// Ví giả luôn lỗi khi cập nhật số dư của ví [failOn].
class _FailingWalletRepository extends MockWalletRepository {
  _FailingWalletRepository(List<Wallet> wallets, this.failOn) : super(wallets);

  final String failOn;

  @override
  Future<void> updateBalance(String walletId, double delta) async {
    if (walletId == failOn) throw Exception('wallet error');
    await super.updateBalance(walletId, delta);
  }
}

void main() {
  group('Transaction ORM (Document ↔ Model)', () {
    test('toDocument/fromDocument round-trip giữ nguyên mọi trường', () {
      final tx = _tx(
        type: 'transfer',
        categoryId: null,
        toWalletId: 'w-bank',
        note: 'Rút tiền',
      );

      final restored = Transaction.fromDocument(tx.id, tx.toDocument());

      expect(restored.userId, tx.userId);
      expect(restored.walletId, tx.walletId);
      expect(restored.categoryId, isNull);
      expect(restored.type, 'transfer');
      expect(restored.amount, tx.amount);
      expect(restored.date, tx.date);
      expect(restored.note, 'Rút tiền');
      expect(restored.toWalletId, 'w-bank');
    });
  });

  group('balanceDeltas (ảnh hưởng của giao dịch lên số dư ví)', () {
    test('chi trừ ví, thu cộng ví', () {
      expect(balanceDeltas(after: _tx(amount: 50000)), {'w-cash': -50000});
      expect(balanceDeltas(after: _tx(type: 'income', amount: 70000)), {
        'w-cash': 70000,
      });
    });

    test('chuyển khoản trừ ví nguồn và cộng ví đích', () {
      final tx = _tx(
        type: 'transfer',
        categoryId: null,
        amount: 300000,
        toWalletId: 'w-bank',
      );

      expect(balanceDeltas(after: tx), {'w-cash': -300000, 'w-bank': 300000});
    });

    test('xóa giao dịch hoàn lại đúng số tiền', () {
      expect(balanceDeltas(before: _tx(amount: 50000)), {'w-cash': 50000});
      expect(balanceDeltas(before: _tx(type: 'income', amount: 70000)), {
        'w-cash': -70000,
      });
    });

    test('sửa số tiền chỉ áp phần chênh lệch', () {
      final deltas = balanceDeltas(
        before: _tx(amount: 50000),
        after: _tx(amount: 80000),
      );

      expect(deltas, {'w-cash': -30000});
    });

    test('sửa sang ví khác: hoàn ví cũ và trừ ví mới', () {
      final deltas = balanceDeltas(
        before: _tx(amount: 50000),
        after: _tx(amount: 50000, walletId: 'w-bank'),
      );

      expect(deltas, {'w-cash': 50000, 'w-bank': -50000});
    });

    test('sửa chi thành thu: chênh lệch gấp đôi số tiền', () {
      final deltas = balanceDeltas(
        before: _tx(amount: 50000),
        after: _tx(type: 'income', amount: 50000),
      );

      expect(deltas, {'w-cash': 100000});
    });

    test('không có thay đổi số dư thì trả về map rỗng', () {
      final tx = _tx(note: 'ghi chú cũ');
      final edited = _tx(note: 'ghi chú mới');

      expect(balanceDeltas(before: tx, after: edited), isEmpty);
    });
  });

  group('MockTransactionRepository + cập nhật số dư ví', () {
    late MockWalletRepository wallets;
    late MockTransactionRepository repo;

    Future<double> balanceOf(String id) async =>
        (await wallets.getWalletById(id))!.balance;

    setUp(() {
      wallets = MockWalletRepository([
        _wallet('w-cash', 1000000),
        _wallet('w-bank', 5000000),
      ]);
      repo = MockTransactionRepository(walletRepository: wallets);
    });

    test('thêm giao dịch chi trừ số dư ví', () async {
      await repo.insertTransaction(_tx(amount: 200000));

      expect(await balanceOf('w-cash'), 800000);
    });

    test('thêm giao dịch thu cộng số dư ví', () async {
      await repo.insertTransaction(_tx(type: 'income', amount: 300000));

      expect(await balanceOf('w-cash'), 1300000);
    });

    test('thêm chuyển khoản trừ ví nguồn và cộng ví đích', () async {
      await repo.insertTransaction(
        _tx(
          type: 'transfer',
          categoryId: null,
          amount: 400000,
          toWalletId: 'w-bank',
        ),
      );

      expect(await balanceOf('w-cash'), 600000);
      expect(await balanceOf('w-bank'), 5400000);
    });

    test('sửa số tiền điều chỉnh số dư theo phần chênh lệch', () async {
      await repo.insertTransaction(_tx(amount: 200000));

      await repo.updateTransaction(_tx(amount: 250000, note: 'đã sửa'));

      expect(await balanceOf('w-cash'), 750000);
      final stored = await repo.watchTransactionsByMonth(10, 2026).first;
      expect(stored.single.amount, 250000);
      expect(stored.single.note, 'đã sửa');
    });

    test('sửa sang ví khác hoàn ví cũ và trừ ví mới', () async {
      await repo.insertTransaction(_tx(amount: 200000));

      await repo.updateTransaction(_tx(amount: 200000, walletId: 'w-bank'));

      expect(await balanceOf('w-cash'), 1000000);
      expect(await balanceOf('w-bank'), 4800000);
    });

    test('xóa giao dịch hoàn lại số dư', () async {
      final tx = _tx(amount: 200000);
      await repo.insertTransaction(tx);

      await repo.deleteTransaction(tx);

      expect(await balanceOf('w-cash'), 1000000);
      expect(await repo.watchTransactionsByMonth(10, 2026).first, isEmpty);
    });

    test('xóa giao dịch không tồn tại thì không đổi số dư', () async {
      await repo.deleteTransaction(_tx(id: 'khong-ton-tai', amount: 999));

      expect(await balanceOf('w-cash'), 1000000);
    });

    test('sửa giao dịch không tồn tại ném StateError', () async {
      expect(
        () => repo.updateTransaction(_tx(id: 'khong-ton-tai')),
        throwsStateError,
      );
    });

    test('cập nhật ví lỗi thì hoàn tác, giao dịch không được lưu', () async {
      final failing = _FailingWalletRepository([
        _wallet('w-cash', 1000000),
        _wallet('w-bank', 5000000),
      ], 'w-bank');
      final failingRepo = MockTransactionRepository(walletRepository: failing);

      await expectLater(
        failingRepo.insertTransaction(
          _tx(
            type: 'transfer',
            categoryId: null,
            amount: 400000,
            toWalletId: 'w-bank',
          ),
        ),
        throwsException,
      );

      expect(
        await failingRepo.watchTransactionsByMonth(10, 2026).first,
        isEmpty,
      );
      // Ví nguồn đã bị trừ trước khi ví đích lỗi, phải được hoàn lại.
      expect((await failing.getWalletById('w-cash'))!.balance, 1000000);
    });

    test('không truyền ví thì chỉ lưu giao dịch, không đụng số dư', () async {
      final standalone = MockTransactionRepository();

      await standalone.insertTransaction(_tx());

      expect(
        (await standalone.watchTransactionsByMonth(10, 2026).first).length,
        1,
      );
    });
  });

  group('MockTransactionRepository (truy vấn)', () {
    late MockTransactionRepository repo;

    setUp(() {
      repo = MockTransactionRepository(
        initial: [
          _tx(id: 'old', date: DateTime(2026, 10, 1, 8)),
          _tx(id: 'new', date: DateTime(2026, 10, 20, 8)),
          _tx(id: 'other-month', date: DateTime(2026, 9, 30, 8)),
          _tx(id: 'other-year', date: DateTime(2025, 10, 15, 8)),
          _tx(
            id: 'in-transfer',
            walletId: 'w-bank',
            toWalletId: 'w-cash',
            type: 'transfer',
            categoryId: null,
            date: DateTime(2026, 10, 10, 8),
          ),
        ],
      );
    });

    test(
      'watchTransactionsByMonth chỉ lấy đúng tháng/năm, mới nhất trước',
      () async {
        final list = await repo.watchTransactionsByMonth(10, 2026).first;

        expect(list.map((t) => t.id), ['new', 'in-transfer', 'old']);
      },
    );

    test('watchByWallet gồm cả chuyển khoản đến ví đó', () async {
      final list = await repo.watchByWallet('w-cash').first;

      expect(list.map((t) => t.id), containsAll(['new', 'old', 'in-transfer']));
      expect(list.map((t) => t.id), isNot(contains('khong-lien-quan')));
      expect(await repo.watchByWallet('w-khong-co').first, isEmpty);
    });

    test('watch phát lại danh sách mới khi thêm giao dịch', () async {
      final emissions = <int>[];
      final sub = repo
          .watchTransactionsByMonth(10, 2026)
          .listen((l) => emissions.add(l.length));
      await pumpEventQueue();

      await repo.insertTransaction(
        _tx(id: 'extra', date: DateTime(2026, 10, 5)),
      );
      await pumpEventQueue();
      await sub.cancel();

      expect(emissions, [3, 4]);
    });
  });

  group('transaction_queries', () {
    test('filterByMonth, involvesWallet, sortNewestFirst', () {
      final a = _tx(id: 'a', date: DateTime(2026, 10, 1));
      final b = _tx(id: 'b', date: DateTime(2026, 11, 1));
      final c = _tx(id: 'c', date: DateTime(2026, 10, 1));

      expect(filterByMonth([a, b, c], 10, 2026).map((t) => t.id), ['a', 'c']);
      expect(involvesWallet(a, 'w-cash'), isTrue);
      expect(involvesWallet(a, 'w-bank'), isFalse);
      // Cùng ngày thì xếp theo id để thứ tự ổn định.
      expect(sortNewestFirst([a, b, c]).map((t) => t.id), ['b', 'a', 'c']);
    });
  });

  group('TransactionFilter', () {
    final expense = _tx(id: 'e', categoryId: 'cat-1');
    final income = _tx(id: 'i', type: 'income', categoryId: 'cat-2');
    final transfer = _tx(
      id: 't',
      type: 'transfer',
      categoryId: null,
      toWalletId: 'w-bank',
    );
    final all = [expense, income, transfer];
    const base = TransactionFilter(month: 10, year: 2026);

    test('không có điều kiện thì giữ tất cả', () {
      expect(base.hasActiveFilters, isFalse);
      expect(applyTransactionFilter(all, base).length, 3);
    });

    test('lọc theo loại, ví (cả ví đích), danh mục', () {
      expect(
        applyTransactionFilter(
          all,
          base.copyWith(type: 'income'),
        ).map((t) => t.id),
        ['i'],
      );
      expect(
        applyTransactionFilter(
          all,
          base.copyWith(walletId: 'w-bank'),
        ).map((t) => t.id),
        ['t'],
      );
      expect(
        applyTransactionFilter(
          all,
          base.copyWith(categoryId: 'cat-1'),
        ).map((t) => t.id),
        ['e'],
      );
    });

    test('kết hợp nhiều điều kiện', () {
      final filter = base.copyWith(type: 'expense', categoryId: 'cat-2');
      expect(applyTransactionFilter(all, filter), isEmpty);
      expect(filter.hasActiveFilters, isTrue);
    });

    test('clear* bỏ từng điều kiện, cleared bỏ hết và giữ tháng', () {
      final filter = base.copyWith(
        type: 'expense',
        walletId: 'w',
        categoryId: 'c',
      );

      expect(filter.copyWith(clearType: true).type, isNull);
      expect(filter.copyWith(clearWallet: true).walletId, isNull);
      expect(filter.copyWith(clearCategory: true).categoryId, isNull);
      final cleared = filter.cleared();
      expect(cleared.hasActiveFilters, isFalse);
      expect(cleared.month, 10);
      expect(cleared.year, 2026);
    });

    test('shiftMonth tự chuyển năm', () {
      final dec = const TransactionFilter(month: 12, year: 2026).shiftMonth(1);
      expect((dec.month, dec.year), (1, 2027));

      final jan = const TransactionFilter(month: 1, year: 2026).shiftMonth(-1);
      expect((jan.month, jan.year), (12, 2025));
    });
  });

  group('groupTransactionsByDay / summarize', () {
    test('gom theo ngày, ngày mới trước, tính chênh lệch thu chi', () {
      final groups = groupTransactionsByDay([
        _tx(id: 'a', date: DateTime(2026, 10, 1, 8), amount: 100000),
        _tx(
          id: 'b',
          date: DateTime(2026, 10, 3, 9),
          type: 'income',
          amount: 500000,
        ),
        _tx(id: 'c', date: DateTime(2026, 10, 3, 18), amount: 120000),
        _tx(
          id: 'd',
          date: DateTime(2026, 10, 3, 20),
          type: 'transfer',
          categoryId: null,
          toWalletId: 'w-bank',
          amount: 999999,
        ),
      ]);

      expect(groups.map((g) => g.day), [
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 1),
      ]);
      expect(groups.first.items.map((t) => t.id), ['d', 'c', 'b']);
      expect(groups.first.net, 500000 - 120000);
      expect(groups.last.net, -100000);
    });

    test('danh sách rỗng cho nhóm rỗng', () {
      expect(groupTransactionsByDay(const []), isEmpty);
    });

    test('summarize chỉ cộng thu và chi, bỏ chuyển khoản', () {
      final totals = summarize([
        _tx(amount: 100000),
        _tx(type: 'income', amount: 300000),
        _tx(
          type: 'transfer',
          categoryId: null,
          toWalletId: 'w-bank',
          amount: 777,
        ),
      ]);

      expect(totals.income, 300000);
      expect(totals.expense, 100000);
    });
  });
}

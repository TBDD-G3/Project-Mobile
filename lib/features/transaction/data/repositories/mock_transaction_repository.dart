import 'dart:async';

import '../../../../data/firestore/models/transaction.dart';
import '../../../wallet/data/repositories/wallet_repository.dart';
import '../transaction_balance.dart';
import '../transaction_queries.dart';
import 'transaction_repository.dart';

/// Repository giao dịch giả, giữ dữ liệu trong bộ nhớ. Dùng khi test hoặc
/// lúc không có mạng/Firebase. Truyền [walletRepository] để mô phỏng việc
/// cập nhật số dư ví giống bản Firestore.
class MockTransactionRepository implements TransactionRepository {
  MockTransactionRepository({
    List<Transaction>? initial,
    WalletRepository? walletRepository,
  }) : _items = [...?initial],
       _wallets = walletRepository;

  final List<Transaction> _items;
  final WalletRepository? _wallets;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  void _emit() => _changes.add(null);

  Stream<List<Transaction>> _watch(List<Transaction> Function() select) {
    // Đăng ký nghe thay đổi ngay lúc listen để không bỏ lỡ sự kiện nào.
    late final StreamController<List<Transaction>> out;
    StreamSubscription<void>? sub;
    out = StreamController<List<Transaction>>(
      onListen: () {
        out.add(select());
        sub = _changes.stream.listen((_) => out.add(select()));
      },
      onCancel: () => sub?.cancel(),
    );
    return out.stream;
  }

  @override
  Stream<List<Transaction>> watchTransactionsByMonth(int month, int year) {
    return _watch(() => sortNewestFirst(filterByMonth(_items, month, year)));
  }

  @override
  Stream<List<Transaction>> watchByWallet(String walletId) {
    return _watch(
      () => sortNewestFirst(_items.where((t) => involvesWallet(t, walletId))),
    );
  }

  Future<void> _applyDeltas(Map<String, double> deltas) async {
    final wallets = _wallets;
    if (wallets == null) return;
    await applyBalanceDeltas(wallets, deltas);
  }

  @override
  Future<void> insertTransaction(Transaction transaction) async {
    _items.add(transaction);
    try {
      await _applyDeltas(balanceDeltas(after: transaction));
    } catch (_) {
      _items.removeWhere((t) => t.id == transaction.id);
      rethrow;
    }
    _emit();
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _items.indexWhere((t) => t.id == transaction.id);
    if (index == -1) {
      throw StateError('Không tìm thấy giao dịch ${transaction.id}');
    }
    final before = _items[index];

    _items[index] = transaction;
    try {
      await _applyDeltas(balanceDeltas(before: before, after: transaction));
    } catch (_) {
      _items[index] = before;
      rethrow;
    }
    _emit();
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    final index = _items.indexWhere((t) => t.id == transaction.id);
    if (index == -1) return;
    final stored = _items[index];

    _items.removeAt(index);
    try {
      await _applyDeltas(balanceDeltas(before: stored));
    } catch (_) {
      _items.insert(index, stored);
      rethrow;
    }
    _emit();
  }
}

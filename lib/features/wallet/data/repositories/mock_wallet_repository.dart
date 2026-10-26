import 'dart:async';

import '../../../../data/firestore/models/wallet.dart';
import 'wallet_repository.dart';

/// Repository ví chạy trên bộ nhớ (in-memory) — dùng cho chế độ mock
/// và kiểm thử khi không có kết nối Firebase.
class MockWalletRepository implements WalletRepository {
  MockWalletRepository([List<Wallet>? initial]) : _wallets = [...?initial];

  factory MockWalletRepository.seeded() {
    final created = DateTime(2024, 1, 1);
    return MockWalletRepository([
      Wallet(
        id: 'mock-cash',
        userId: 'mock-user',
        name: 'Tiền mặt',
        type: 'cash',
        balance: 1250000,
        colorHex: '#4CAF50',
        createdAt: created,
      ),
      Wallet(
        id: 'mock-bank',
        userId: 'mock-user',
        name: 'Vietcombank',
        type: 'bank',
        balance: 12500000,
        colorHex: '#2196F3',
        createdAt: created,
      ),
      Wallet(
        id: 'mock-ewallet',
        userId: 'mock-user',
        name: 'MoMo',
        type: 'ewallet',
        balance: 450000,
        colorHex: '#9C27B0',
        createdAt: created,
      ),
    ]);
  }

  final List<Wallet> _wallets;
  final StreamController<List<Wallet>> _controller =
      StreamController<List<Wallet>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_wallets));

  @override
  Stream<List<Wallet>> watchAllWallets() async* {
    yield List.unmodifiable(_wallets);
    yield* _controller.stream;
  }

  @override
  Future<Wallet?> getWalletById(String id) async {
    for (final wallet in _wallets) {
      if (wallet.id == id) return wallet;
    }
    return null;
  }

  @override
  Future<void> insertWallet(Wallet wallet) async {
    _wallets.add(wallet);
    _emit();
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    final index = _wallets.indexWhere((w) => w.id == wallet.id);
    if (index == -1) return;
    _wallets[index] = wallet;
    _emit();
  }

  @override
  Future<void> updateBalance(String walletId, double delta) async {
    final index = _wallets.indexWhere((w) => w.id == walletId);
    if (index == -1) return;
    final old = _wallets[index];
    _wallets[index] = old.copyWith(balance: old.balance + delta);
    _emit();
  }

  @override
  Future<void> deleteWallet(String id) async {
    final before = _wallets.length;
    _wallets.removeWhere((w) => w.id == id);
    if (_wallets.length != before) _emit();
  }
}

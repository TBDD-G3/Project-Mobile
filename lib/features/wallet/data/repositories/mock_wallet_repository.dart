import 'dart:async';
import '../../../../data/database/app_database.dart';
import 'wallet_repository.dart';

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
  Future<int> insertWallet(WalletsCompanion wallet) async {
    _wallets.add(_merge(wallet, null));
    _emit();
    return 1;
  }

  @override
  Future<int> updateWallet(WalletsCompanion wallet) async {
    final index = _wallets.indexWhere((w) => w.id == wallet.id.value);
    if (index == -1) return 0;
    _wallets[index] = _merge(wallet, _wallets[index]);
    _emit();
    return 1;
  }

  @override
  Future<void> updateBalance(String walletId, double delta) async {
    final index = _wallets.indexWhere((w) => w.id == walletId);
    if (index == -1) return;
    final old = _wallets[index];
    _wallets[index] = Wallet(
      id: old.id,
      userId: old.userId,
      name: old.name,
      type: old.type,
      balance: old.balance + delta,
      iconCode: old.iconCode,
      colorHex: old.colorHex,
      createdAt: old.createdAt,
    );
    _emit();
  }

  @override
  Future<int> deleteWallet(String id) async {
    final before = _wallets.length;
    _wallets.removeWhere((w) => w.id == id);
    final removed = before - _wallets.length;
    if (removed > 0) _emit();
    return removed;
  }

  Wallet _merge(WalletsCompanion c, Wallet? fallback) {
    return Wallet(
      id: c.id.present ? c.id.value : (fallback?.id ?? ''),
      userId: c.userId.present
          ? c.userId.value
          : (fallback?.userId ?? 'mock-user'),
      name: c.name.present ? c.name.value : (fallback?.name ?? ''),
      type: c.type.present ? c.type.value : (fallback?.type ?? 'cash'),
      balance: c.balance.present ? c.balance.value : (fallback?.balance ?? 0),
      iconCode: c.iconCode.present ? c.iconCode.value : fallback?.iconCode,
      colorHex: c.colorHex.present ? c.colorHex.value : fallback?.colorHex,
      createdAt: c.createdAt.present
          ? c.createdAt.value
          : (fallback?.createdAt ?? DateTime.now()),
    );
  }
}

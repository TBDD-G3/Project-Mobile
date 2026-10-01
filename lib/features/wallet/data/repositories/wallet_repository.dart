import 'package:drift/drift.dart';
import '../../../../data/database/app_database.dart';

abstract interface class WalletRepository {
  Stream<List<Wallet>> watchAllWallets();

  Future<Wallet?> getWalletById(String id);

  Future<int> insertWallet(WalletsCompanion wallet);

  Future<int> updateWallet(WalletsCompanion wallet);

  Future<void> updateBalance(String walletId, double delta);

  Future<int> deleteWallet(String id);
}

class DriftWalletRepository implements WalletRepository {
  final AppDatabase _db;

  DriftWalletRepository(this._db);

  @override
  Stream<List<Wallet>> watchAllWallets() {
    return _db.select(_db.wallets).watch();
  }

  @override
  Future<Wallet?> getWalletById(String id) {
    return (_db.select(_db.wallets)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> insertWallet(WalletsCompanion wallet) {
    return _db.into(_db.wallets).insert(wallet);
  }

  /// Chỉ ghi các trường có trong [wallet], các trường khác giữ nguyên.
  /// KHÔNG dùng để sửa số dư — số dư luôn đi qua [updateBalance] từ Transaction.
  @override
  Future<int> updateWallet(WalletsCompanion wallet) {
    return (_db.update(_db.wallets)
          ..where((tbl) => tbl.id.equals(wallet.id.value)))
        .write(wallet);
  }

  /// Số dư CHỈ được thay đổi qua method này (khi tạo/sửa/xóa Transaction).
  /// [delta]: số tiền thay đổi (+ tăng tiền, - giảm tiền).
  @override
  Future<void> updateBalance(String walletId, double delta) async {
    final wallet = await getWalletById(walletId);
    if (wallet != null) {
      await (_db.update(_db.wallets)..where((tbl) => tbl.id.equals(walletId)))
          .write(WalletsCompanion(balance: Value(wallet.balance + delta)));
    }
  }

  @override
  Future<int> deleteWallet(String id) {
    return (_db.delete(_db.wallets)..where((tbl) => tbl.id.equals(id))).go();
  }
}

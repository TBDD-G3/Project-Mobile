import 'package:drift/drift.dart';
import '../../../../data/database/app_database.dart';

class WalletRepository {
  final AppDatabase _db;

  WalletRepository(this._db);

  /// Lấy danh sách tất cả các ví
  Stream<List<Wallet>> watchAllWallets() {
    return _db.select(_db.wallets).watch();
  }

  /// Lấy thông tin 1 ví theo ID
  Future<Wallet?> getWalletById(String id) {
    return (_db.select(_db.wallets)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Thêm ví mới
  Future<int> insertWallet(WalletsCompanion wallet) {
    return _db.into(_db.wallets).insert(wallet);
  }

  /// CẬP NHẬT SỐ DƯ VÍ — BẮT BUỘC DÙNG METHOD NÀY KHI TẠO/SỬA/XÓA TRANSACTION
  /// [delta]: số tiền thay đổi (+ tăng tiền, - giảm tiền)
  Future<void> updateBalance(String walletId, double delta) async {
    final wallet = await getWalletById(walletId);
    if (wallet != null) {
      final newBalance = wallet.balance + delta;
      await (_db.update(_db.wallets)..where((tbl) => tbl.id.equals(walletId)))
          .write(WalletsCompanion(balance: Value(newBalance)));
    }
  }

  /// Xóa ví
  Future<int> deleteWallet(String id) {
    return (_db.delete(_db.wallets)..where((tbl) => tbl.id.equals(id))).go();
  }
}

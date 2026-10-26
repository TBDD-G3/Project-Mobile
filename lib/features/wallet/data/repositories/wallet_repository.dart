import '../../../../data/firestore/models/wallet.dart';

/// Hợp đồng dữ liệu của Ví tiền.
///
/// Có 2 implementation:
/// - [FirestoreWalletRepository] — dùng trong ứng dụng thật (Câu 7: Firebase).
/// - [MockWalletRepository] — dùng cho chế độ mock / kiểm thử không cần mạng.
abstract interface class WalletRepository {
  Stream<List<Wallet>> watchAllWallets();

  Future<Wallet?> getWalletById(String id);

  Future<void> insertWallet(Wallet wallet);

  Future<void> updateWallet(Wallet wallet);

  /// Số dư CHỈ được thay đổi qua method này (khi tạo/sửa/xóa Transaction).
  /// [delta]: số tiền thay đổi (+ tăng tiền, - giảm tiền).
  Future<void> updateBalance(String walletId, double delta);

  Future<void> deleteWallet(String id);
}

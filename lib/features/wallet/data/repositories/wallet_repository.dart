import '../../../../data/firestore/models/wallet.dart';

/// Interface dữ liệu Ví tiền, có 2 bản implement:
/// - [FirestoreWalletRepository] dùng trong app thật (Câu 7)
/// - [MockWalletRepository] dùng cho mock và test
abstract interface class WalletRepository {
  Stream<List<Wallet>> watchAllWallets();

  Future<Wallet?> getWalletById(String id);

  Future<void> insertWallet(Wallet wallet);

  Future<void> updateWallet(Wallet wallet);

  /// Số dư chỉ nên đổi qua hàm này (lúc thêm/sửa/xóa giao dịch).
  /// delta dương là cộng tiền, âm là trừ.
  Future<void> updateBalance(String walletId, double delta);

  Future<void> deleteWallet(String id);
}

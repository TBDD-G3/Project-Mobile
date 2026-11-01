import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../data/firestore/models/wallet.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/repositories/firestore_wallet_repository.dart';
import '../data/repositories/wallet_repository.dart';

/// WalletRepository dùng Firestore (Leader viết).
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return FirestoreWalletRepository(db);
});

/// Danh sách ví của người đang đăng nhập.
///
/// `autoDispose` + watch uid: đăng xuất là provider bị huỷ, stream Firestore
/// đóng luôn. Nếu để sống, ngay sau khi đăng xuất stream nhận
/// `permission-denied` từ rules và cache lỗi đó vĩnh viễn — đăng nhập lại sẽ
/// thấy "Không tải được danh sách ví" dù dữ liệu vẫn còn.
final walletsStreamProvider = StreamProvider.autoDispose<List<Wallet>>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) return Stream.value(const <Wallet>[]);
  return ref.watch(walletRepositoryProvider).watchAllWallets();
});

/// Tổng số dư các ví, Member 3 dùng cho màn tổng quan.
final totalBalanceProvider = Provider.autoDispose<AsyncValue<double>>((ref) {
  final walletsAsync = ref.watch(walletsStreamProvider);
  return walletsAsync.whenData((wallets) {
    return wallets.fold<double>(0.0, (sum, wallet) => sum + wallet.balance);
  });
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../data/firestore/models/wallet.dart';
import '../data/repositories/firestore_wallet_repository.dart';
import '../data/repositories/wallet_repository.dart';

/// 🔒 Provider cung cấp WalletRepository (Firestore — do Leader implement).
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return FirestoreWalletRepository(db);
});

/// 🔒 Stream danh sách tất cả các ví (của người dùng đang đăng nhập).
final walletsStreamProvider = StreamProvider<List<Wallet>>((ref) {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.watchAllWallets();
});

/// 🔒 Provider tính tổng số dư tất cả các ví (Leader implement, Member 3 dùng).
final totalBalanceProvider = Provider<AsyncValue<double>>((ref) {
  final walletsAsync = ref.watch(walletsStreamProvider);
  return walletsAsync.whenData((wallets) {
    return wallets.fold<double>(0.0, (sum, wallet) => sum + wallet.balance);
  });
});

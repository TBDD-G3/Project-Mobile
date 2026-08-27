import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../data/repositories/wallet_repository.dart';

/// 🔒 Provider cung cấp WalletRepository (Do Leader implement)
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WalletRepository(db);
});

/// 🔒 Stream danh sách tất cả các ví
final walletsStreamProvider = StreamProvider<List<Wallet>>((ref) {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.watchAllWallets();
});

/// 🔒 Provider tính tổng số dư tất cả các ví (Do Leader implement, Member 3 dùng)
final totalBalanceProvider = Provider<AsyncValue<double>>((ref) {
  final walletsAsync = ref.watch(walletsStreamProvider);
  return walletsAsync.whenData((wallets) {
    return wallets.fold<double>(0.0, (sum, wallet) => sum + wallet.balance);
  });
});

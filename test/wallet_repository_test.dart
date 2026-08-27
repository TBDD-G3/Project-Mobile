import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/database/app_database.dart';
import 'package:project_mobile/data/database/seeds/initial_seeder.dart';
import 'package:project_mobile/features/wallet/data/repositories/wallet_repository.dart';

void main() {
  group('Wallet & Seeder Tests', () {
    late AppDatabase db;
    late WalletRepository walletRepo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      walletRepo = WalletRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('InitialSeeder seeds default user, wallets, and categories', () async {
      await InitialSeeder.seedDefaultData(db);

      final users = await db.select(db.users).get();
      final wallets = await db.select(db.wallets).get();
      final categories = await db.select(db.categories).get();

      expect(users.length, 1);
      expect(wallets.length, 2);
      expect(categories.length, 13); // 8 expense + 5 income
    });

    test('WalletRepository updateBalance correctly modifies wallet balance', () async {
      await InitialSeeder.seedDefaultData(db);
      final wallets = await db.select(db.wallets).get();
      final cashWallet = wallets.firstWhere((w) => w.type == 'cash');

      expect(cashWallet.balance, 0.0);

      // Cộng 500,000 VND
      await walletRepo.updateBalance(cashWallet.id, 500000.0);
      var updated = await walletRepo.getWalletById(cashWallet.id);
      expect(updated?.balance, 500000.0);

      // Trừ 200,000 VND
      await walletRepo.updateBalance(cashWallet.id, -200000.0);
      updated = await walletRepo.getWalletById(cashWallet.id);
      expect(updated?.balance, 300000.0);
    });
  });
}

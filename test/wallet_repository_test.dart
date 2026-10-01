import 'package:drift/drift.dart';
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

    test('WalletRepository updateWallet edits info and keeps balance and other fields', () async {
      await InitialSeeder.seedDefaultData(db);
      final wallets = await db.select(db.wallets).get();
      final cashWallet = wallets.firstWhere((w) => w.type == 'cash');

      await walletRepo.updateWallet(
        WalletsCompanion(
          id: Value(cashWallet.id),
          name: const Value('Ví tiền mặt'),
          type: const Value('cash'),
          iconCode: Value(cashWallet.iconCode),
          colorHex: const Value('#2196F3'),
        ),
      );

      final updated = await walletRepo.getWalletById(cashWallet.id);
      expect(updated?.name, 'Ví tiền mặt');
      expect(updated?.colorHex, '#2196F3');
      expect(updated?.balance, cashWallet.balance);
      expect(updated?.userId, cashWallet.userId);
      expect(updated?.createdAt, cashWallet.createdAt);
    });
  });
}

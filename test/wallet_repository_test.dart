import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/firestore/models/wallet.dart';
import 'package:project_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';

void main() {
  group('Wallet ORM (Document ↔ Model) — Câu 7', () {
    test('toDocument/fromDocument round-trip giữ nguyên mọi trường', () {
      final wallet = Wallet(
        id: 'w-1',
        userId: 'u-1',
        name: 'Tiền mặt',
        type: 'cash',
        balance: 1250000,
        iconCode: 0xe3af,
        colorHex: '#4CAF50',
        createdAt: DateTime(2026, 10, 20, 8, 30),
      );

      final restored = Wallet.fromDocument(wallet.id, wallet.toDocument());

      expect(restored.id, wallet.id);
      expect(restored.userId, wallet.userId);
      expect(restored.name, wallet.name);
      expect(restored.type, wallet.type);
      expect(restored.balance, wallet.balance);
      expect(restored.iconCode, wallet.iconCode);
      expect(restored.colorHex, wallet.colorHex);
      expect(restored.createdAt, wallet.createdAt);
    });

    test('fromDocument xử lý document thiếu trường (giá trị mặc định)', () {
      final wallet = Wallet.fromDocument('w-x', {'name': 'Ví test'});

      expect(wallet.id, 'w-x');
      expect(wallet.name, 'Ví test');
      expect(wallet.userId, '');
      expect(wallet.type, 'cash');
      expect(wallet.balance, 0.0);
      expect(wallet.iconCode, isNull);
      expect(wallet.colorHex, isNull);
    });
  });

  group('MockWalletRepository (CRUD + updateBalance)', () {
    late MockWalletRepository repo;

    setUp(() {
      repo = MockWalletRepository([
        Wallet(
          id: 'w-cash',
          userId: 'u-1',
          name: 'Tiền mặt',
          type: 'cash',
          balance: 500000,
          createdAt: DateTime(2026, 1, 1),
        ),
      ]);
    });

    test('insertWallet thêm ví và watchAllWallets phát danh sách mới', () async {
      final newWallet = Wallet(
        id: 'w-bank',
        userId: 'u-1',
        name: 'Vietcombank',
        type: 'bank',
        balance: 0,
        createdAt: DateTime(2026, 1, 2),
      );

      await repo.insertWallet(newWallet);

      final wallets = await repo.watchAllWallets().first;
      expect(wallets.length, 2);
      expect(await repo.getWalletById('w-bank'), isNotNull);
    });

    test('updateBalance cộng/trừ số dư đúng', () async {
      await repo.updateBalance('w-cash', 500000);
      expect((await repo.getWalletById('w-cash'))!.balance, 1000000);

      await repo.updateBalance('w-cash', -300000);
      expect((await repo.getWalletById('w-cash'))!.balance, 700000);
    });

    test('updateWallet sửa thông tin, giữ nguyên userId/createdAt/balance', () async {
      final original = await repo.getWalletById('w-cash');

      await repo.updateWallet(
        original!.copyWith(name: 'Ví tiền mặt', colorHex: '#2196F3'),
      );

      final updated = await repo.getWalletById('w-cash');
      expect(updated!.name, 'Ví tiền mặt');
      expect(updated.colorHex, '#2196F3');
      expect(updated.userId, original.userId);
      expect(updated.createdAt, original.createdAt);
      expect(updated.balance, original.balance);
    });

    test('updateBalance với id không tồn tại không gây lỗi', () async {
      await repo.updateBalance('khong-ton-tai', 100);
      expect(await repo.getWalletById('khong-ton-tai'), isNull);
    });

    test('deleteWallet chỉ xóa đúng ví được chọn', () async {
      await repo.deleteWallet('w-cash');

      expect(await repo.getWalletById('w-cash'), isNull);
      expect(await repo.watchAllWallets().first, isEmpty);
    });
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/firestore/models/transaction.dart';
import 'package:project_mobile/data/firestore/models/user.dart';
import 'package:project_mobile/features/auth/providers/auth_providers.dart';
import 'package:project_mobile/features/category/data/repositories/mock_category_repository.dart';
import 'package:project_mobile/features/category/providers/category_providers.dart';
import 'package:project_mobile/features/transaction/data/repositories/mock_transaction_repository.dart';
import 'package:project_mobile/features/transaction/presentation/transactions_screen.dart';
import 'package:project_mobile/features/transaction/providers/transaction_providers.dart';
import 'package:project_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:project_mobile/features/wallet/providers/wallet_providers.dart';

/// Repository lỗi khi thêm giao dịch, để test thông báo lỗi.
class _FailingInsertRepository extends MockTransactionRepository {
  @override
  Future<void> insertTransaction(Transaction transaction) async {
    throw Exception('firestore down');
  }
}

/// Giao dịch nằm trong tháng hiện tại, vì màn hình mặc định mở tháng này.
DateTime _thisMonth(int day) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, day, 10);
}

Transaction _expense() => Transaction(
  id: 't1',
  userId: 'mock-user',
  walletId: 'mock-cash',
  categoryId: 'cat-exp-an-uong',
  type: 'expense',
  amount: 50000,
  date: _thisMonth(1),
  note: 'Phở bò',
);

Transaction _income() => Transaction(
  id: 't2',
  userId: 'mock-user',
  walletId: 'mock-bank',
  categoryId: 'cat-inc-luong',
  type: 'income',
  amount: 15000000,
  date: _thisMonth(2),
  note: 'Lương tháng',
);

class _Env {
  final MockWalletRepository wallets = MockWalletRepository.seeded();
  final MockCategoryRepository categories = MockCategoryRepository.seeded();
  late final MockTransactionRepository transactions;

  _Env({
    MockTransactionRepository? transactionRepo,
    List<Transaction>? initial,
  }) {
    transactions =
        transactionRepo ??
        MockTransactionRepository(initial: initial, walletRepository: wallets);
  }

  /// Được gán trong _pumpScreen. Dùng để chạy các lời gọi async "thật"
  /// (stream.first, Future của mock) ngoài FakeAsync của testWidgets,
  /// nếu không `await` sẽ chờ mãi vì không có ai bơm microtask/timer.
  WidgetTester? tester;

  Future<T> _real<T>(Future<T> Function() body) async {
    final t = tester;
    if (t == null) return body();
    return (await t.runAsync(body)) as T;
  }

  Future<double> balanceOf(String walletId) async =>
      (await _real(() => wallets.getWalletById(walletId)))!.balance;

  Future<List<Transaction>> thisMonth() {
    final now = DateTime.now();
    return _real(
      () => transactions.watchTransactionsByMonth(now.month, now.year).first,
    );
  }
}

/// Thay cho pumpAndSettle: chỉ bơm số frame cố định nên không bao giờ treo
/// khi màn hình có animation chạy mãi (spinner, con trỏ nhấp nháy...).
Future<void> _settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _Env env, {
  List<Override> overrides = const [],
}) async {
  env.tester = tester;
  tester.view.physicalSize = const Size(900, 3600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(env.wallets),
        categoryRepositoryProvider.overrideWithValue(env.categories),
        transactionRepositoryProvider.overrideWithValue(env.transactions),
        currentUserProvider.overrideWith(
          (ref) => Stream.value(
            AppUser(
              id: 'mock-user',
              email: 'user@projectmobile.local',
              displayName: 'Người dùng',
              currencyCode: 'VND',
              createdAt: DateTime(2024, 1, 1),
            ),
          ),
        ),
        ...overrides,
      ],
      child: const MaterialApp(home: Scaffold(body: TransactionsScreen())),
    ),
  );
}

Future<void> _openAddSheet(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await _settle(tester);
}

/// Điền form chi tiêu hợp lệ: 200.000đ, Ăn uống, ví Tiền mặt.
Future<void> _fillValidExpense(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Số tiền (VNĐ)'),
    '200000',
  );

  await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
  await _settle(tester);
  await tester.tap(find.text('Ăn uống').last);
  await _settle(tester);

  await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
  await _settle(tester);
  await tester.tap(find.text('Tiền mặt').last);
  await _settle(tester);
}

void main() {
  group('TransactionsScreen — trạng thái danh sách', () {
    testWidgets('loading: hiện vòng xoay khi chưa có dữ liệu', (tester) async {
      await _pumpScreen(
        tester,
        _Env(),
        overrides: [
          transactionsByMonthProvider.overrideWith(
            (ref, arg) => StreamController<List<Transaction>>().stream,
          ),
        ],
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('empty: chưa có giao dịch thì hiện lời mời thêm', (
      tester,
    ) async {
      await _pumpScreen(tester, _Env());
      await _settle(tester);

      expect(find.text('Chưa có giao dịch trong tháng này'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('data: hiện giao dịch gom theo ngày kèm tổng kết', (
      tester,
    ) async {
      await _pumpScreen(tester, _Env(initial: [_expense(), _income()]));
      await _settle(tester);

      expect(find.byIcon(Icons.more_vert), findsNWidgets(2));
      expect(find.textContaining('Phở bò'), findsOneWidget);
      expect(find.textContaining('Lương tháng'), findsOneWidget);
      expect(find.text('Chênh lệch'), findsOneWidget);
    });

    testWidgets('error: hiện lỗi và nút thử lại', (tester) async {
      await _pumpScreen(
        tester,
        _Env(),
        overrides: [
          transactionsByMonthProvider.overrideWith(
            (ref, arg) => Stream<List<Transaction>>.error(Exception('boom')),
          ),
        ],
      );
      await _settle(tester);

      expect(find.textContaining('Không tải được giao dịch'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });
  });

  group('TransactionsScreen — bộ lọc', () {
    testWidgets('lọc theo loại, rồi xóa bộ lọc khi không có kết quả', (
      tester,
    ) async {
      await _pumpScreen(tester, _Env(initial: [_expense(), _income()]));
      await _settle(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Thu'));
      await _settle(tester);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.textContaining('Lương tháng'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Chuyển'));
      await _settle(tester);
      expect(find.text('Không có giao dịch phù hợp'), findsOneWidget);

      await tester.tap(find.text('Xóa bộ lọc'));
      await _settle(tester);
      expect(find.byIcon(Icons.more_vert), findsNWidgets(2));
    });

    testWidgets('chuyển tháng trước thì không còn giao dịch của tháng này', (
      tester,
    ) async {
      await _pumpScreen(tester, _Env(initial: [_expense()]));
      await _settle(tester);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      await tester.tap(find.byTooltip('Tháng trước'));
      await _settle(tester);

      expect(find.byIcon(Icons.more_vert), findsNothing);
      expect(find.text('Chưa có giao dịch trong tháng này'), findsOneWidget);
    });
  });

  group('TransactionsScreen — form thêm/sửa', () {
    testWidgets('validate: bỏ trống thì báo thiếu số tiền, danh mục, ví', (
      tester,
    ) async {
      final env = _Env();
      await _pumpScreen(tester, env);
      await _settle(tester);
      await _openAddSheet(tester);

      await tester.tap(find.text('Lưu'));
      await _settle(tester);

      expect(find.text('Vui lòng nhập số tiền'), findsOneWidget);
      expect(find.text('Vui lòng chọn danh mục'), findsOneWidget);
      expect(find.text('Vui lòng chọn ví'), findsOneWidget);
      expect(await env.thisMonth(), isEmpty);
    });

    testWidgets('validate: số tiền bằng 0 bị từ chối', (tester) async {
      await _pumpScreen(tester, _Env());
      await _settle(tester);
      await _openAddSheet(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Số tiền (VNĐ)'),
        '0',
      );
      await tester.tap(find.text('Lưu'));
      await _settle(tester);

      expect(find.text('Số tiền phải lớn hơn 0'), findsOneWidget);
    });

    testWidgets('chuyển khoản: không cần danh mục, bắt buộc chọn ví nhận', (
      tester,
    ) async {
      await _pumpScreen(tester, _Env());
      await _settle(tester);
      await _openAddSheet(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Chuyển khoản'));
      await _settle(tester);
      await tester.tap(find.text('Lưu'));
      await _settle(tester);

      expect(find.text('Vui lòng chọn ví'), findsOneWidget);
      expect(find.text('Vui lòng chọn ví nhận'), findsOneWidget);
      expect(find.text('Vui lòng chọn danh mục'), findsNothing);
    });

    testWidgets('thêm giao dịch chi hợp lệ: lưu và trừ số dư ví', (
      tester,
    ) async {
      final env = _Env();
      await _pumpScreen(tester, env);
      await _settle(tester);
      await _openAddSheet(tester);

      await _fillValidExpense(tester);
      await tester.tap(find.text('Lưu'));
      await _settle(tester);

      final saved = await env.thisMonth();
      expect(saved.length, 1);
      expect(saved.single.amount, 200000);
      expect(saved.single.type, 'expense');
      expect(saved.single.categoryId, 'cat-exp-an-uong');
      expect(saved.single.walletId, 'mock-cash');
      expect(await env.balanceOf('mock-cash'), 1250000 - 200000);
      expect(find.text('Giao dịch mới'), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('lưu lỗi thì hiện SnackBar và giữ nguyên form', (tester) async {
      final env = _Env(transactionRepo: _FailingInsertRepository());
      await _pumpScreen(tester, env);
      await _settle(tester);
      await _openAddSheet(tester);

      await _fillValidExpense(tester);
      await tester.tap(find.text('Lưu'));
      await _settle(tester);

      expect(find.textContaining('Không lưu được giao dịch'), findsOneWidget);
      expect(find.text('Giao dịch mới'), findsOneWidget);
    });

    testWidgets('sửa giao dịch: điền sẵn dữ liệu và điều chỉnh số dư ví', (
      tester,
    ) async {
      final env = _Env(initial: [_expense()]);
      await _pumpScreen(tester, env);
      await _settle(tester);

      await tester.tap(find.textContaining('Phở bò'));
      await _settle(tester);
      expect(find.text('Sửa giao dịch'), findsOneWidget);
      expect(find.text('50000'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Số tiền (VNĐ)'),
        '80000',
      );
      await tester.tap(find.text('Lưu'));
      await _settle(tester);

      final updated = (await env.thisMonth()).single;
      expect(updated.amount, 80000);
      expect(updated.note, 'Phở bò');
      // Chi tăng thêm 30.000đ nên ví bị trừ thêm đúng phần chênh lệch.
      expect(await env.balanceOf('mock-cash'), 1250000 - 30000);
    });
  });

  group('TransactionsScreen — xóa', () {
    testWidgets('menu xóa có xác nhận: Hủy giữ lại, Xóa hoàn số dư ví', (
      tester,
    ) async {
      final env = _Env(initial: [_expense(), _income()]);
      await _pumpScreen(tester, env);
      await _settle(tester);
      final menuOfT1 = find.descendant(
        of: find.byKey(const ValueKey('tx-t1')),
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(menuOfT1);
      await _settle(tester);
      await tester.tap(find.text('Xóa'));
      await _settle(tester);
      expect(find.text('Xác nhận xóa'), findsOneWidget);
      await tester.tap(find.text('Hủy'));
      await _settle(tester);
      expect(find.byIcon(Icons.more_vert), findsNWidgets(2));
      expect(await env.balanceOf('mock-cash'), 1250000);

      await tester.tap(menuOfT1);
      await _settle(tester);
      await tester.tap(find.text('Xóa'));
      await _settle(tester);
      await tester.tap(find.text('Xóa'));
      await _settle(tester);

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect((await env.thisMonth()).map((t) => t.id), ['t2']);
      expect(await env.balanceOf('mock-cash'), 1250000 + 50000);
    });

    testWidgets('menu Sửa mở form điền sẵn dữ liệu', (tester) async {
      final env = _Env(initial: [_expense()]);
      await _pumpScreen(tester, env);
      await _settle(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await _settle(tester);
      await tester.tap(find.text('Sửa'));
      await _settle(tester);

      expect(find.text('Sửa giao dịch'), findsOneWidget);
      expect(find.text('50000'), findsOneWidget);
    });

    testWidgets('xóa từ form sửa cũng có hộp thoại xác nhận', (tester) async {
      final env = _Env(initial: [_expense()]);
      await _pumpScreen(tester, env);
      await _settle(tester);

      await tester.tap(find.textContaining('Phở bò'));
      await _settle(tester);
      await tester.tap(find.text('Xóa giao dịch'));
      await _settle(tester);
      expect(find.text('Xác nhận xóa'), findsOneWidget);
      await tester.tap(find.text('Xóa'));
      await _settle(tester);

      expect(await env.thisMonth(), isEmpty);
      expect(find.text('Sửa giao dịch'), findsNothing);
      expect(find.text('Chưa có giao dịch trong tháng này'), findsOneWidget);
    });
  });
}
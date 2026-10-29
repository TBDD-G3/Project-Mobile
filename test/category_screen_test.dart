import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/firestore/models/category.dart';
import 'package:project_mobile/features/category/data/repositories/category_repository.dart';
import 'package:project_mobile/features/category/data/repositories/mock_category_repository.dart';
import 'package:project_mobile/features/category/presentation/categories_screen.dart';
import 'package:project_mobile/features/category/providers/category_providers.dart';

/// Repository lỗi khi thêm danh mục, để test thông báo lỗi.
class _FailingInsertRepository extends MockCategoryRepository {
  @override
  Future<void> insertCategory(Category category) async {
    throw Exception('firestore down');
  }
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  CategoryRepository? repo,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (repo != null) categoryRepositoryProvider.overrideWithValue(repo),
        ...overrides,
      ],
      child: const MaterialApp(home: CategoriesScreen()),
    ),
  );
}

void main() {
  group('CategoriesScreen — trạng thái danh sách', () {
    testWidgets('loading: hiện vòng xoay khi chưa có dữ liệu', (tester) async {
      await _pumpScreen(
        tester,
        overrides: [
          categoriesStreamProvider.overrideWith(
            (ref) => StreamController<List<Category>>().stream,
          ),
        ],
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('empty: chưa có danh mục thì hiện trạng thái rỗng', (
      tester,
    ) async {
      await _pumpScreen(tester, repo: MockCategoryRepository());
      await tester.pumpAndSettle();

      expect(find.text('Chưa có danh mục chi tiêu'), findsOneWidget);

      await tester.tap(find.text('Thu nhập'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có danh mục thu nhập'), findsOneWidget);
    });

    testWidgets('data: tách danh mục chi và thu theo tab', (tester) async {
      await _pumpScreen(tester, repo: MockCategoryRepository.seeded());
      await tester.pumpAndSettle();

      expect(find.text('Ăn uống'), findsOneWidget);
      expect(find.text('Tiền lương'), findsNothing);

      await tester.tap(find.text('Thu nhập'));
      await tester.pumpAndSettle();
      expect(find.text('Tiền lương'), findsOneWidget);
      expect(find.text('Ăn uống'), findsNothing);
    });

    testWidgets('danh mục mặc định bị khóa, không có nút xóa', (tester) async {
      await _pumpScreen(tester, repo: MockCategoryRepository.seeded());
      await tester.pumpAndSettle();

      expect(find.text('Mặc định'), findsWidgets);
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('error: hiện lỗi và nút thử lại', (tester) async {
      await _pumpScreen(
        tester,
        overrides: [
          categoriesStreamProvider.overrideWith(
            (ref) => Stream<List<Category>>.error(Exception('boom')),
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Không tải được danh mục'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });
  });

  group('CategoriesScreen — thêm/sửa/xóa', () {
    testWidgets('form: bỏ trống tên thì báo lỗi và không lưu', (tester) async {
      final repo = MockCategoryRepository();
      await _pumpScreen(tester, repo: repo);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Thêm danh mục mới'), findsOneWidget);

      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập tên danh mục'), findsOneWidget);
      expect(await repo.getAll(), isEmpty);
    });

    testWidgets('form: tên trùng trong cùng loại thì báo lỗi', (tester) async {
      final repo = MockCategoryRepository.seeded();
      await _pumpScreen(tester, repo: repo);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'ăn uống');
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Đã có danh mục này'), findsOneWidget);
      expect((await repo.getAll()).length, 13);
    });

    testWidgets('thêm danh mục hợp lệ thì lưu và hiện trong danh sách', (
      tester,
    ) async {
      final repo = MockCategoryRepository();
      await _pumpScreen(tester, repo: repo);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Cà phê');
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      final saved = await repo.getAll();
      expect(saved.single.name, 'Cà phê');
      expect(saved.single.type, 'expense');
      expect(saved.single.isDefault, isFalse);
      expect(find.text('Thêm danh mục mới'), findsNothing);
      expect(find.text('Cà phê'), findsOneWidget);
    });

    testWidgets('lưu lỗi thì hiện SnackBar và giữ nguyên form', (tester) async {
      await _pumpScreen(tester, repo: _FailingInsertRepository());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Cà phê');
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Không lưu được danh mục'), findsOneWidget);
      expect(find.text('Thêm danh mục mới'), findsOneWidget);
    });

    testWidgets('sửa danh mục tự tạo: đổi tên, loại bị khóa', (tester) async {
      final repo = MockCategoryRepository([
        const Category(id: 'c-1', name: 'Cà phê', type: 'expense'),
      ]);
      await _pumpScreen(tester, repo: repo);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cà phê'));
      await tester.pumpAndSettle();
      expect(find.text('Sửa danh mục'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Trà sữa');
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      final updated = (await repo.getById('c-1'))!;
      expect(updated.name, 'Trà sữa');
      expect(updated.type, 'expense');
    });

    testWidgets('xóa có xác nhận: Hủy giữ lại, Xóa mới xóa thật', (
      tester,
    ) async {
      final repo = MockCategoryRepository([
        const Category(id: 'c-1', name: 'Cà phê', type: 'expense'),
      ]);
      await _pumpScreen(tester, repo: repo);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Xác nhận xóa'), findsOneWidget);
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(await repo.getById('c-1'), isNotNull);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();

      expect(await repo.getById('c-1'), isNull);
      expect(find.text('Cà phê'), findsNothing);
    });
  });
}

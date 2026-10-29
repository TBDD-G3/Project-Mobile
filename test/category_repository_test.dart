import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/firestore/models/category.dart';
import 'package:project_mobile/features/category/data/repositories/mock_category_repository.dart';
import 'package:project_mobile/features/category/presentation/category_visuals.dart';

Category _category({
  String id = 'c-food',
  String name = 'Ăn uống',
  String type = 'expense',
  bool isDefault = false,
}) {
  return Category(
    id: id,
    name: name,
    type: type,
    iconCode: Icons.restaurant.codePoint,
    colorHex: '#FF5722',
    isDefault: isDefault,
  );
}

void main() {
  group('Category ORM (Document ↔ Model)', () {
    test('toDocument/fromDocument round-trip giữ nguyên mọi trường', () {
      final category = _category(isDefault: true);

      final restored = Category.fromDocument(
        category.id,
        category.toDocument(),
      );

      expect(restored.id, category.id);
      expect(restored.name, category.name);
      expect(restored.type, category.type);
      expect(restored.iconCode, category.iconCode);
      expect(restored.colorHex, category.colorHex);
      expect(restored.isDefault, isTrue);
    });

    test('fromDocument xử lý document thiếu trường (giá trị mặc định)', () {
      final category = Category.fromDocument('c-x', {'name': 'Test'});

      expect(category.name, 'Test');
      expect(category.type, 'expense');
      expect(category.iconCode, isNull);
      expect(category.colorHex, isNull);
      expect(category.isDefault, isFalse);
    });
  });

  group('MockCategoryRepository (CRUD)', () {
    late MockCategoryRepository repo;

    setUp(() {
      repo = MockCategoryRepository([_category()]);
    });

    test('insertCategory thêm danh mục và getAll trả về đủ', () async {
      await repo.insertCategory(
        _category(id: 'c-salary', name: 'Lương', type: 'income'),
      );

      final all = await repo.getAll();
      expect(all.length, 2);
      expect(await repo.getById('c-salary'), isNotNull);
    });

    test('getAll sắp xếp theo tên', () async {
      await repo.insertCategory(_category(id: 'c-a', name: 'An'));
      await repo.insertCategory(_category(id: 'c-z', name: 'Zebra'));

      final names = (await repo.getAll()).map((c) => c.name).toList();
      expect(names, ['An', 'Ăn uống', 'Zebra']);
    });

    test('getById trả về null nếu không tồn tại', () async {
      expect(await repo.getById('khong-ton-tai'), isNull);
    });

    test(
      'updateCategory đổi tên/icon/màu, giữ nguyên loại và isDefault',
      () async {
        final original = (await repo.getById('c-food'))!;

        await repo.updateCategory(
          original.copyWith(name: 'Cà phê', colorHex: '#2196F3'),
        );

        final updated = (await repo.getById('c-food'))!;
        expect(updated.name, 'Cà phê');
        expect(updated.colorHex, '#2196F3');
        expect(updated.type, original.type);
        expect(updated.isDefault, original.isDefault);
      },
    );

    test('updateCategory với id không tồn tại không làm gì', () async {
      await repo.updateCategory(_category(id: 'khong-ton-tai'));
      expect((await repo.getAll()).length, 1);
    });

    test('deleteCategory chỉ xóa đúng danh mục được chọn', () async {
      await repo.insertCategory(_category(id: 'c-2', name: 'Khác'));

      await repo.deleteCategory('c-food');

      final all = await repo.getAll();
      expect(all.map((c) => c.id), ['c-2']);
    });

    test(
      'watchAll phát danh sách hiện tại rồi phát lại sau mỗi thay đổi',
      () async {
        final emissions = <List<Category>>[];
        final sub = repo.watchAll().listen(emissions.add);
        await pumpEventQueue();

        await repo.insertCategory(_category(id: 'c-2', name: 'Khác'));
        await pumpEventQueue();
        await repo.deleteCategory('c-food');
        await pumpEventQueue();
        await sub.cancel();

        expect(emissions.map((l) => l.length), [1, 2, 1]);
      },
    );

    test('seeded có 13 danh mục mặc định (8 chi, 5 thu)', () async {
      final seeded = MockCategoryRepository.seeded();

      final all = await seeded.getAll();
      expect(all.length, 13);
      expect(all.where((c) => c.isExpense).length, 8);
      expect(all.where((c) => c.isIncome).length, 5);
      expect(all.every((c) => c.isDefault), isTrue);
    });
  });

  group('category_visuals', () {
    test('iconForCode tìm đúng icon, không thấy thì trả icon mặc định', () {
      expect(iconForCode(Icons.restaurant.codePoint), Icons.restaurant);
      expect(iconForCode(Icons.payments.codePoint), Icons.payments);
      expect(iconForCode(null), Icons.category_outlined);
      expect(iconForCode(0x1), Icons.category_outlined);
    });

    test('colorFromHex đọc #RRGGBB và có màu dự phòng khi sai định dạng', () {
      expect(colorFromHex('#FF5722'), const Color(0xFFFF5722));
      expect(colorFromHex('4CAF50'), const Color(0xFF4CAF50));
      expect(colorFromHex(null), const Color(0xFF607D8B));
      expect(colorFromHex('xyz'), const Color(0xFF607D8B));
      expect(colorFromHex('#GGGGGG'), const Color(0xFF607D8B));
    });

    test('mọi icon của 13 danh mục seed đều nằm trong bộ chọn icon', () {
      final seeded = MockCategoryRepository.seeded();
      return seeded.getAll().then((all) {
        for (final c in all) {
          expect(
            iconForCode(c.iconCode),
            isNot(Icons.category_outlined),
            reason: 'Thiếu icon của danh mục ${c.name}',
          );
        }
      });
    });
  });
}

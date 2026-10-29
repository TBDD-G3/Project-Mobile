import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/firestore/models/category.dart';
import 'package:project_mobile/features/category/data/repositories/mock_category_repository.dart';
import 'package:project_mobile/features/category/providers/category_providers.dart';

void main() {
  late MockCategoryRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockCategoryRepository.seeded();
    container = ProviderContainer(
      overrides: [categoryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  test('categoryRepositoryProvider trả về repository được override', () {
    expect(container.read(categoryRepositoryProvider), same(repo));
  });

  test('categoriesStreamProvider phát 13 danh mục mặc định', () async {
    final list = await container.read(categoriesStreamProvider.future);
    expect(list.length, 13);
  });

  test('categoriesStreamProvider cập nhật khi thêm, sửa, xóa', () async {
    final sub = container.listen(categoriesStreamProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(categoriesStreamProvider.future);

    await repo.insertCategory(
      const Category(id: 'c-new', name: 'Cà phê', type: 'expense'),
    );
    await pumpEventQueue();
    expect(container.read(categoriesStreamProvider).value!.length, 14);

    await repo.updateCategory(
      const Category(id: 'c-new', name: 'Trà sữa', type: 'expense'),
    );
    await pumpEventQueue();
    final names = container
        .read(categoriesStreamProvider)
        .value!
        .map((c) => c.name);
    expect(names, contains('Trà sữa'));
    expect(names, isNot(contains('Cà phê')));

    await repo.deleteCategory('c-new');
    await pumpEventQueue();
    expect(container.read(categoriesStreamProvider).value!.length, 13);
  });

  test('provider báo lỗi khi repository lỗi', () async {
    final failing = ProviderContainer(
      overrides: [
        categoriesStreamProvider.overrideWith(
          (ref) => Stream<List<Category>>.error(Exception('boom')),
        ),
      ],
    );
    addTearDown(failing.dispose);

    await expectLater(
      failing.read(categoriesStreamProvider.future),
      throwsA(isA<Exception>()),
    );
  });
}

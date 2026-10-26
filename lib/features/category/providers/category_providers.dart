import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/firestore/models/category.dart';
import '../../../data/firestore/seed/initial_seeder.dart';
import '../data/repositories/category_repository.dart';

/// Member 2 sẽ thay repository mặc định bên dưới bằng bản Firestore.
/// Member 3 chỉ cần đọc qua [categoriesStreamProvider].
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return _DefaultCategoryRepository();
});

/// Stream toàn bộ danh mục, dùng chung cho Member 2 và Member 3.
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

/// Bản tạm dùng 13 danh mục seed sẵn để Member 3 test UI/biểu đồ
/// trong lúc chờ repo Firestore của Member 2.
class _DefaultCategoryRepository implements CategoryRepository {
  final List<Category> _items = List<Category>.of(
    InitialSeeder.defaultCategories,
  );

  @override
  Stream<List<Category>> watchAll() => Stream.value(List.unmodifiable(_items));

  @override
  Future<List<Category>> getAll() async => List.unmodifiable(_items);

  @override
  Future<Category?> getById(String id) async {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<void> insertCategory(Category category) async {
    _items.add(category);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final idx = _items.indexWhere((c) => c.id == category.id);
    if (idx != -1) _items[idx] = category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    _items.removeWhere((c) => c.id == id);
  }
}

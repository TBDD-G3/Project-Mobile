import '../../../../data/firestore/models/category.dart';

/// Interface dữ liệu Danh mục. Member 2 implement bản Firestore,
/// Member 3 chỉ đọc qua `categoryRepositoryProvider` / `categoriesStreamProvider`.
abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll();

  Future<List<Category>> getAll();

  Future<Category?> getById(String id);

  Future<void> insertCategory(Category category);

  Future<void> updateCategory(Category category);

  Future<void> deleteCategory(String id);
}

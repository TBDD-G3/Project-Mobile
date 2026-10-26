import '../../../../data/firestore/models/category.dart';

/// 🔒 Hợp đồng dữ liệu cố định của Danh mục thu/chi (Category).
///
/// - Member 2 implement `FirestoreCategoryRepository` từ interface này.
/// - Member 3 chỉ đọc dữ liệu thông qua `categoryRepositoryProvider` / `categoriesStreamProvider`.
abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll();

  Future<List<Category>> getAll();

  Future<Category?> getById(String id);

  Future<void> insertCategory(Category category);

  Future<void> updateCategory(Category category);

  Future<void> deleteCategory(String id);
}

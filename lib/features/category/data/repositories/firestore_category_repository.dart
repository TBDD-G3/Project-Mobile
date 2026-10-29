import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/models/category.dart';
import 'category_repository.dart';

/// Repository danh mục chạy trên Firestore (Câu 7).
/// Mỗi danh mục là một Document trong `categories`, đọc/ghi đều qua
/// `categoriesCollection()` đã gắn converter nên làm việc thẳng với [Category].
///
/// Model `Category` không có `userId` nên danh mục dùng chung toàn app
/// (13 danh mục mặc định do seeder tạo, id cố định).
class FirestoreCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _db;

  FirestoreCategoryRepository(this._db);

  /// Sort ở Dart cho khỏi phải tạo index cho orderBy.
  static List<Category> _sorted(Iterable<Category> items) {
    final list = items.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  @override
  Stream<List<Category>> watchAll() {
    return categoriesCollection(_db)
        .snapshots()
        .map((snapshot) => _sorted(snapshot.docs.map((doc) => doc.data())));
  }

  @override
  Future<List<Category>> getAll() async {
    final snapshot = await categoriesCollection(_db).get();
    return _sorted(snapshot.docs.map((doc) => doc.data()));
  }

  @override
  Future<Category?> getById(String id) async {
    final snapshot = await categoriesCollection(_db).doc(id).get();
    return snapshot.exists ? snapshot.data() : null;
  }

  @override
  Future<void> insertCategory(Category category) async {
    await categoriesCollection(_db).doc(category.id).set(category);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await categoriesCollection(_db)
        .doc(category.id)
        .update(category.toDocument());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await categoriesCollection(_db).doc(id).delete();
  }
}

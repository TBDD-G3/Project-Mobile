import '../../data/database/app_database.dart';
import '../../data/database/tables/categories.dart';

/// Giả định: `AppDatabase` (gộp các bảng Categories/Transactions/Wallets,
/// sinh từ `app_database.dart` + build_runner) đã có sẵn trong dự án.
class CategoryRepository {
  final AppDatabase db;
  CategoryRepository(this.db);

  Future<List<CategoryData>> getAll() => db.select(db.categories).get();

  Future<CategoryData?> getById(String id) {
    return (db.select(db.categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }
}

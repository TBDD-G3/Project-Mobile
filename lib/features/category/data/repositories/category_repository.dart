import '../../../../data/database/app_database.dart';

class CategoryRepository {
  final AppDatabase db;

  CategoryRepository(this.db);

  Future<List<Category>> getAll() => db.select(db.categories).get();

  Future<Category?> getById(String id) {
    return (db.select(db.categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/categories.dart';
import 'category_repository.dart';

// Giả định: `appDatabaseProvider` (Provider<AppDatabase>) đã được khai báo sẵn
// trong dự án (thường ở app_database.dart hoặc 1 file provider dùng chung cấp
// bởi Leader) và export được từ đường dẫn import phía trên.

part 'category_providers.g.dart';

/// Provider công khai theo yêu cầu: categoryRepositoryProvider
@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryRepository(db);
}

/// Tiện ích: expose getAll()/getById() sẵn dưới dạng provider cho UI dùng trực tiếp.
@riverpod
Future<List<CategoryData>> categoryList(CategoryListRef ref) {
  return ref.watch(categoryRepositoryProvider).getAll();
}

@riverpod
Future<CategoryData?> categoryById(CategoryByIdRef ref, String id) {
  return ref.watch(categoryRepositoryProvider).getById(id);
}

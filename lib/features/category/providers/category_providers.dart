import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../data/firestore/models/category.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/firestore_category_repository.dart';
import '../data/repositories/mock_category_repository.dart';

/// CategoryRepository dùng Firestore. Member 3 đọc qua provider này
/// (`getAll()`, `getById(id)`...) hoặc qua [categoriesStreamProvider].
///
/// Khi Firebase chưa được khởi tạo (chế độ `kUseMockData` hoặc widget test
/// không override) thì dùng bản in-memory với 13 danh mục mặc định để app
/// vẫn chạy được offline. Chạy thật thì Firebase luôn đã init nên không bao
/// giờ rơi vào nhánh này.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  try {
    final db = ref.watch(firebaseFirestoreProvider);
    return FirestoreCategoryRepository(db);
  } catch (_) {
    return MockCategoryRepository.seeded();
  }
});

/// Stream toàn bộ danh mục, dùng chung cho Member 2 và Member 3.
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

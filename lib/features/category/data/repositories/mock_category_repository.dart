import 'dart:async';

import '../../../../data/firestore/models/category.dart';
import '../../../../data/firestore/seed/initial_seeder.dart';
import 'category_repository.dart';

/// Repository danh mục giả, giữ dữ liệu trong bộ nhớ. Dùng khi test
/// hoặc lúc không có mạng/Firebase.
class MockCategoryRepository implements CategoryRepository {
  MockCategoryRepository([List<Category>? initial]) : _items = [...?initial];

  /// Bắt đầu với 13 danh mục mặc định giống bản seed trên Firestore.
  factory MockCategoryRepository.seeded() {
    return MockCategoryRepository(InitialSeeder.defaultCategories);
  }

  final List<Category> _items;
  final StreamController<List<Category>> _controller =
      StreamController<List<Category>>.broadcast();

  List<Category> _snapshot() {
    final list = [..._items];
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(list);
  }

  void _emit() => _controller.add(_snapshot());

  @override
  Stream<List<Category>> watchAll() {
    // Đăng ký nghe thay đổi ngay lúc listen để không bỏ lỡ sự kiện nào.
    late final StreamController<List<Category>> out;
    StreamSubscription<List<Category>>? sub;
    out = StreamController<List<Category>>(
      onListen: () {
        out.add(_snapshot());
        sub = _controller.stream.listen(out.add);
      },
      onCancel: () => sub?.cancel(),
    );
    return out.stream;
  }

  @override
  Future<List<Category>> getAll() async => _snapshot();

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
    _emit();
  }

  @override
  Future<void> updateCategory(Category category) async {
    final index = _items.indexWhere((c) => c.id == category.id);
    if (index == -1) return;
    _items[index] = category;
    _emit();
  }

  @override
  Future<void> deleteCategory(String id) async {
    final before = _items.length;
    _items.removeWhere((c) => c.id == id);
    if (_items.length != before) _emit();
  }
}

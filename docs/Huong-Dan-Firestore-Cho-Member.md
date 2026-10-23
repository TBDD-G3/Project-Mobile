# 🚀 Hướng dẫn công nghệ cho Member 2 & 3 — Firebase + Firestore + Riverpod

> Leader viết để các bạn đồng bộ với luồng code mới. Đọc kỹ trước khi code tiếp.
> Nếu có gì không rõ, hỏi Leader trong nhóm chat.

---

## 1. Vì sao đổi sang Firebase?

Đề bài tập lớn **Câu 7** (1 điểm): *"Kết nối cơ sở dữ liệu, thực hiện ORM (Object Related Mapping) với **Documents của Firebase**"*.

Vì vậy toàn bộ dữ liệu (User, Wallet, Category, Transaction, Budget) chuyển từ Drift/SQLite sang **Cloud Firestore**, và đăng nhập dùng **Firebase Authentication**. Code của các bạn sẽ được chấm trên phần này, nên phải thao tác đúng theo mẫu.

---

## 2. Cách chạy project

```bash
git checkout develop
git pull origin develop

git checkout -b feature/<ten-nhanh-cua-ban>

flutter pub get
flutter run -d chrome          # hoặc chọn emulator Android
```

**2 chế độ chạy** (xem `kUseMockData` trong `lib/main.dart`):

| Chế độ | Khi nào dùng | Cần gì |
|---|---|---|
| Mock (`kUseMockData = true` — hiện tại) | Đang code UI, test widget, chưa có Firebase project | Không cần gì |
| Firebase thật (`false`) | Demo cuối kỳ | Leader đã cấu hình `flutterfire configure` |

⚠️ **Không chạy trên Windows/Linux desktop nữa** — Firebase không hỗ trợ 2 nền tảng đó. Dùng Chrome hoặc emulator Android.

---

## 3. Kiến trúc 3 lớp các bạn cần nắm

```text
UI (màn hình) 
   │  ref.watch(<xxx>Provider)
   ▼
Providers (Riverpod, trong features/<tên>/providers/)
   │  gọi repository
   ▼
Repository (interface + Firestore implement)
   │  gọi hàm collection có converter
   ▼
Firestore (cloud) — mỗi bản ghi là 1 Document
```

### 3.1. Model = Document (tầng ORM)

Mỗi model có 2 hàm chuyển đổi:

```dart
factory Category.fromDocument(String id, Map<String, dynamic> data) { ... }  // Document → Object
Map<String, dynamic> toDocument() { ... }                                     // Object → Document
```

Converter được gắn sẵn trong `lib/data/firestore/firestore_collections.dart`, nên các bạn **không bao giờ** phải tự gõ tên collection hay Map thủ công:

```dart
final ref = categoriesCollection(db);          // CollectionReference<Category>
await ref.doc(id).set(category);               // tự gọi toDocument()
final list = (await ref.get()).docs.map((d) => d.data()).toList(); // tự gọi fromDocument()
```

### 3.2. Repository mẫu (Leader đã viết sẵn 1 cái)

Xem file `lib/features/wallet/data/repositories/firestore_wallet_repository.dart` — đây là **mẫu chuẩn**. Các bạn viết `CategoryRepository`, `TransactionRepository`, `BudgetRepository` theo đúng cấu trúc này (interface trước, implement sau).

---

## 4. Việc của Member 2 — Transaction & Category

Tạo trong nhánh `feature/member2-transaction-category`:

### Bước 1 — CategoryRepository (`lib/features/category/data/repositories/`)

```dart
abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll();
  Future<List<Category>> getAll();
  Future<Category?> getById(String id);
  Future<void> insertCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
```

Implement `FirestoreCategoryRepository`:

```dart
class FirestoreCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _db;
  FirestoreCategoryRepository(this._db);

  @override
  Stream<List<Category>> watchAll() => categoriesCollection(_db)
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());

  @override
  Future<void> insertCategory(Category category) async {
    await categoriesCollection(_db).doc(category.id).set(category);
  }
  // ... viết tiếp getById, update, delete tương tự Wallet
}
```

Sửa `lib/features/category/providers/category_providers.dart`:

```dart
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return FirestoreCategoryRepository(db);
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});
```

### Bước 2 — TransactionRepository

- Viết `transactionsByMonthProvider` (đã có khung sẵn trong `lib/features/transaction/providers/transaction_providers.dart`) — query theo `walletId`/`date` trong khoảng tháng.
- **Khi tạo/xóa giao dịch phải cập nhật số dư ví** qua `walletRepositoryProvider` (🔒 của Leader):

```dart
final walletRepo = ref.read(walletRepositoryProvider);
// thu: cộng, chi: trừ, chuyển khoản: trừ ví nguồn + cộng ví đích
await walletRepo.updateBalance(walletId, delta);
```

### Bước 3 — UI

Thay placeholder "Giao dịch" trong `main_nav_screen.dart` bằng màn hình của bạn. Báo Leader để ghép.

---

## 5. Việc của Member 3 — Budget & Analytics

Tạo trong nhánh `feature/member3-budget-analytics`:

### Bước 1 — BudgetRepository (`lib/features/budget/data/repositories/`)

Interface + `FirestoreBudgetRepository` theo đúng mẫu Wallet. Query theo `month` + `year`:

```dart
budgetsCollection(_db)
    .where('month', isEqualTo: month)
    .where('year', isEqualTo: year)
    .snapshots()
```

### Bước 2 — Analytics

- Dùng `transactionsByMonthProvider` và `transactionsByCategoryProvider` (Member 2 cung cấp) để vẽ biểu đồ bằng `fl_chart` (đã có sẵn trong pubspec).
- Dùng `totalBalanceProvider` (🔒 Leader) cho màn hình tổng quan.

### Bước 3 — UI

Thay placeholder "Ngân sách" + "Báo cáo" trong `main_nav_screen.dart`. Báo Leader để ghép.

---

## 6. Quy ước làm việc

1. **Mỗi tính năng nhỏ = 1 commit** có message rõ ràng (vd `feat(transaction): repository Firestore cho giao dịch`). Điểm Câu 10 chấm lịch sử commit.
2. Pull `develop` thường xuyên vì Leader sẽ merge phần nền tảng trước.
3. Không sửa file của người khác; cần gì báo Leader.
4. Chạy `flutter analyze` và `flutter test` trước khi push.
5. Mọi thao tác Firestore phải bọc `try/catch` và hiển thị lỗi cho người dùng (SnackBar) — đây là yêu cầu Câu 8a.

---

## 7. Lỗi thường gặp

| Lỗi | Nguyên nhân | Cách sửa |
|---|---|---|
| `No Firebase App '[DEFAULT]' has been created` | Chạy chế độ thật khi chưa cấu hình Firebase | Chạy `flutterfire configure` hoặc để `kUseMockData = true` |
| `MissingPluginException` trên Windows desktop | Firebase không hỗ trợ desktop | Chạy trên Chrome/emulator Android |
| Document đọc ra bị null | Truy vấn không đúng `userId` | Luôn `where('userId', isEqualTo: uid)` với dữ liệu riêng của user |
| Seeder tạo danh mục trùng | — | Không xảy ra: seeder dùng id cố định (idempotent) |

---

## 8. Tài liệu liên quan

- `docs/Schema-Va-Ban-Giao.md` — schema Firestore đầy đủ + bảng Provider chuẩn
- `docs/bao-cao/` — tài liệu báo cáo (Leader sẽ tạo dần)
- `lib/features/wallet/data/repositories/` — **repository mẫu chuẩn** để copy theo

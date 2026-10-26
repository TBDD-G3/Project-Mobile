# 🚀 Hướng dẫn công nghệ cho Member 2 & 3 — Firebase + Firestore + Riverpod

> Leader viết để các bạn đồng bộ với luồng code mới. Đọc kỹ trước khi code tiếp.
> Toàn bộ thư mục `lib/data/database/` (Drift/SQLite cũ) đã được **xóa bỏ hoàn toàn** khỏi nhánh `develop`. Chỉ sử dụng `lib/data/firestore/`.

---

## 1. Vì sao đổi sang Firebase?

Đề bài tập lớn **Câu 7** (1 điểm): *"Kết nối cơ sở dữ liệu, thực hiện ORM (Object Related Mapping) với **Documents của Firebase**"*.

Vì vậy toàn bộ dữ liệu (`AppUser`, `Wallet`, `Category`, `Transaction`, `Budget`) chuyển từ Drift/SQLite sang **Cloud Firestore**, và đăng nhập dùng **Firebase Authentication**. Code của các bạn sẽ được chấm trên phần này, nên phải thao tác đúng theo mẫu.

---

## 2. Cách đồng bộ nhánh `develop` mới và chạy project

⚠️ **QUAN TRỌNG**: Nhánh cũ của các bạn từ tháng 9 đang chứa code Drift/SQLite cũ. Để tránh xung đột (conflict) với code cũ, các bạn thực hiện đúng các lệnh sau:

```bash
# 1. Lưu tạm hoặc tạo nhánh backup từ nhánh cũ (nếu muốn giữ code UI cũ để tham khảo)
git branch backup-old-code

# 2. Chuyển về develop và cập nhật code mới nhất từ Leader
git fetch origin
git checkout develop
git reset --hard origin/develop

# 3. Tạo lại nhánh làm việc mới từ develop sạch
# - Member 2 (Hải Đăng):
git checkout -B feature/member2-transaction-category
# - Member 3:
git checkout -B feature/member3-budget-analytics

# 4. Cài dependencies và chạy thử
flutter pub get
flutter run -d chrome          # hoặc chọn emulator Android
```

**2 chế độ chạy** (xem `kUseMockData` trong `lib/main.dart`):

| Chế độ | Khi nào dùng | Cần gì |
|---|---|---|
| Mock (`kUseMockData = true` — hiện tại) | Đang code UI, test widget, chưa có Firebase project | Không cần gì |
| Firebase thật (`false`) | Demo cuối kỳ & tích hợp thật | Leader cấu hình `flutterfire configure` |

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
Repository (interface + Firestore implement + Mock implement)
   │  gọi hàm collection có converter
   ▼
Firestore (cloud) — mỗi bản ghi là 1 Document
```

### 3.1. Model = Document (tầng ORM — `lib/data/firestore/models/`)

Mỗi model đều có 2 hàm chuyển đổi chuẩn ORM:

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

Xem file `lib/features/wallet/data/repositories/firestore_wallet_repository.dart` và `mock_wallet_repository.dart` — đây là **mẫu chuẩn**. Các bạn viết `CategoryRepository`, `TransactionRepository`, `BudgetRepository` theo đúng cấu trúc này (interface trước, implement sau).

### 3.3. Design System — giao diện theo mẫu Agoda (BẮT BUỘC làm theo)

Toàn bộ UI mới phải dùng **design tokens + widget có sẵn** để các màn hình của mọi người đồng nhất. Không tự chế màu/kiểu mới.

#### Màu (dùng qua `AppColors` trong `lib/core/constants/app_colors.dart`)

| Token | Giá trị | Dùng cho |
|---|---|---|
| `primary` | `#3F82EF` | tab active, link, nút CTA |
| `primaryLink` | `#2067DA` | link "Xem chi tiết" |
| `textPrimary` / `textSecondary` | `#191919` / `#64748B` | chữ chính / meta |
| `hairline` | `#EDEEEF` | **viền card 1px thay cho shadow** |
| `badge` | `#C53829` | badge đỏ |
| `mintChip` + `mintChipIcon` | `#E2F2E5` / `#00622F` | chip số dư trên appbar |
| `pastelIncome`…`pastelSaving` | xem file | nền tile/icon (5 màu pastel) |
| `income` / `expense` / `transfer` | `#10B981` / `#EF4444` / `#3B82F6` | **chỉ cho số tiền** |
| `radiusTile/Card/Chip/Sheet/Button` | 24/16/10/24/12 | bo góc |

Quy tắc vàng: **số tiền không bao giờ đặt trên nền pastel** — chỉ nền trắng/trung tính.

#### Widget dùng chung (`lib/core/widgets/`)

```dart
import 'package:project_mobile/core/widgets/pastel_tile.dart';
import 'package:project_mobile/core/widgets/section_header.dart';
import 'package:project_mobile/core/widgets/amount_text.dart';
import 'package:project_mobile/core/widgets/empty_state.dart';
import 'package:project_mobile/core/widgets/primary_button.dart';
import 'package:project_mobile/core/widgets/insight_card.dart';
```

| Widget | Cách dùng |
|---|---|
| `PastelTile(label, icon, background, onTap)` | tile nền pastel bo 24, icon tràn mép — dùng cho lưới chức năng/danh mục |
| `SectionHeader(title, actionLabel, onAction)` | tiêu đề section w800 + action phải |
| `AmountText(amount, kind)` | số tiền có dấu +/− đúng màu |
| `EmptyState(icon, title, actionLabel, onAction)` | trạng thái rỗng + CTA |
| `PrimaryButton(label, loading, onPressed)` | nút full-width đậm bo 12 |
| `InsightCard(message, onAction)` | card khuyến nghị + link xanh |

#### Quy ước màn hình (đúng wireframe của nhóm)

1. **Màn hình tab gốc**: không có nút back; nội dung nằm trong `Scaffold` + `SingleChildScrollView` padding ngang 16.
2. **Mọi màn hình con** (thêm/sửa giao dịch, tạo hạn mức, chi tiết...): `AppBar` có **nút back** (mặc định khi `Navigator.push`) + title w800.
3. **Form nhập liệu**: dùng **bottom sheet bo góc 24** (mẫu: `lib/features/wallet/presentation/add_edit_wallet_sheet.dart`) — tay cầm kéo + nút X + `PrimaryButton` đáy.
4. **Xóa**: dialog xác nhận ở giữa màn hình, nút Hủy/Xóa.
5. **Mọi thao tác Firestore**: bọc `try/catch` + hiện lỗi bằng SnackBar (Câu 8a).

---

## 4. Việc của Member 2 (Hải Đăng) — Transaction & Category

Thực hiện trên nhánh `feature/member2-transaction-category`:

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
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => d.data()).toList();
        list.sort((a, b) => a.name.compareTo(b.name));
        return list;
      });

  @override
  Future<void> insertCategory(Category category) async {
    await categoriesCollection(_db).doc(category.id).set(category);
  }
  // ... viết tiếp getAll, getById, update, delete tương tự Wallet
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

### Bước 2 — TransactionRepository (`lib/features/transaction/data/repositories/`)

- Viết `TransactionRepository` & `FirestoreTransactionRepository`.
- Hoàn thiện `transactionsByMonthProvider` và `transactionsByCategoryProvider` trong `lib/features/transaction/providers/transaction_providers.dart`.
- **Khi tạo/xóa giao dịch phải cập nhật số dư ví** qua `walletRepositoryProvider` (🔒 của Leader):

```dart
final walletRepo = ref.read(walletRepositoryProvider);
// thu: cộng (+amount), chi: trừ (-amount), chuyển khoản: trừ ví nguồn + cộng ví đích
await walletRepo.updateBalance(walletId, delta);
```

### Bước 3 — UI & Unit Test

1. Hoàn thiện `transaction_screen.dart` và `add_edit_transaction_sheet.dart` theo Agoda Design System.
2. Viết unit test trong `test/transaction_repository_test.dart` (Câu 8b).
3. Báo Leader để ghép vào `main_nav_screen.dart`.

---

## 5. Việc của Member 3 — Budget & Analytics

Thực hiện trên nhánh `feature/member3-budget-analytics`:

### Bước 1 — BudgetRepository (`lib/features/budget/data/repositories/`)

Interface + `FirestoreBudgetRepository` theo đúng mẫu Wallet. Query theo `userId`, `month`, `year`:

```dart
budgetsCollection(_db)
    .where('userId', isEqualTo: _currentUserId)
    .where('month', isEqualTo: month)
    .where('year', isEqualTo: year)
    .snapshots()
```

### Bước 2 — Analytics

- Dùng `transactionsByMonthProvider` và `transactionsByCategoryProvider` (Member 2 cung cấp) để vẽ biểu đồ bằng `fl_chart` (đã có sẵn trong `pubspec.yaml`).
- Dùng `totalBalanceProvider` (🔒 Leader) cho màn hình tổng quan.

### Bước 3 — UI & Unit Test

1. Hoàn thiện `budget_screen.dart` và `analytics_screen.dart` theo Agoda Design System.
2. Viết unit test trong `test/budget_repository_test.dart` (Câu 8b).
3. Báo Leader để ghép vào `main_nav_screen.dart`.

---

## 6. Quy ước làm việc & Tính điểm Git (Câu 10)

1. **Mỗi tính năng nhỏ = 1 commit** có message rõ ràng (vd `feat(transaction): repository Firestore cho giao dịch`). **Điểm Câu 10 chấm lịch sử commit của từng thành viên (tối thiểu 4-5 commits/người).**
2. Không tạo lại hoặc import bất kỳ file nào của Drift/SQLite cũ.
3. Không sửa file của người khác; cần gì báo Leader.
4. Chạy `flutter test` trước khi push.
5. Mọi thao tác Firestore phải bọc `try/catch` và hiển thị lỗi cho người dùng (SnackBar) — đây là yêu cầu Câu 8a.

---

## 7. Lỗi thường gặp

| Lỗi | Nguyên nhân | Cách sửa |
|---|---|---|
| `No Firebase App '[DEFAULT]' has been created` | Chạy chế độ thật khi chưa cấu hình Firebase | Chạy `flutterfire configure` hoặc dùng Mock repository khi `kUseMockData = true` |
| `The query requires an index` | Kết hợp `.where('fieldA')` và `.orderBy('fieldB')` trên Firestore | Không gọi `.orderBy` khác field `.where` trên Firestore; hãy `.sort()` trong Dart sau khi lấy list |
| `MissingPluginException` trên Windows desktop | Firebase không hỗ trợ desktop | Chạy trên Chrome/emulator Android |
| Document đọc ra bị null | Truy vấn không đúng `userId` | Luôn `where('userId', isEqualTo: uid)` với dữ liệu riêng của user |
| Seeder tạo danh mục trùng | — | Không xảy ra: seeder dùng id cố định (idempotent) |

---

## 8. Tài liệu liên quan

- `docs/Schema-Va-Ban-Giao.md` — schema Firestore đầy đủ + bảng Provider chuẩn
- `lib/features/wallet/data/repositories/` — **repository mẫu chuẩn** để copy theo

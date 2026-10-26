# Tài liệu bàn giao (v2) — Firestore schema và quy ước Provider

**Người viết:** Leader (Member 1) | **Nhánh chuẩn:** `develop` (đã xóa bỏ hoàn toàn Drift/SQLite cũ)
**Lý do đổi từ Drift/SQLite sang Firestore:** Đề bài tập lớn **Câu 7** yêu cầu "Kết nối CSDL, thực hiện ORM (Object Related Mapping) với **Documents của Firebase**" → toàn bộ tầng dữ liệu chuyển sang **Cloud Firestore**, xác thực chuyển sang **Firebase Authentication**.

> Member 2 và 3 đọc file này cùng `docs/Huong-Dan-Firestore-Cho-Member.md` để nắm cách thao tác dữ liệu. **Đừng gọi thẳng `FirebaseFirestore.instance` trong feature.**

---

## 1. Tổng quan công nghệ

| Lớp | Công nghệ | Ghi chú |
|---|---|---|
| State management | Riverpod | Giữ nguyên |
| Xác thực | **Firebase Authentication** (email/password) | Mật khẩu KHÔNG lưu trong DB |
| Database | **Cloud Firestore** | Mỗi bản ghi = 01 Document |
| ORM | `withConverter` + model classes | Ánh xạ Document ↔ Object tự động |
| Chạy/kiểm thử | Chrome hoặc emulator Android | Firebase không hỗ trợ Windows/Linux desktop |

---

## 2. Các collection (5 đối tượng chính trong hệ thống)

```text
users (1) ──< wallets (nhiều)
users (1) ──< transactions (nhiều)
users (1) ──< budgets (nhiều)
wallets (1) ──< transactions (nhiều)
categories (1) ──< transactions (nhiều)
categories (1) ──< budgets (nhiều)
```

### 2.1. `users` — model `AppUser` (`lib/data/firestore/models/user.dart`)

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` (Document ID) | `String` | **= uid từ Firebase Auth** |
| `email` | `String` | |
| `displayName` | `String` | |
| `currencyCode` | `String` | mặc định `'VND'` |
| `createdAt` | `Timestamp` | |

### 2.2. `wallets` — model `Wallet` (`lib/data/firestore/models/wallet.dart`)

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` (Document ID) | `String` | UUID |
| `userId` | `String` | = uid, dùng để lọc ví theo người đăng nhập |
| `name` | `String` | vd: "Tiền mặt" |
| `type` | `String` (`cash` / `bank` / `ewallet`) | |
| `balance` | `double` | **luôn cập nhật qua `updateBalance`, không sửa tay** |
| `iconCode` | `int?` | |
| `colorHex` | `String?` | vd `'#4CAF50'` |
| `createdAt` | `Timestamp` | |

### 2.3. `categories` — model `Category` (`lib/data/firestore/models/category.dart`) *(Member 2 sở hữu, Member 3 chỉ đọc)*

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` (Document ID) | `String` | danh mục mặc định dùng **id cố định** (seeder idempotent) |
| `name` | `String` | |
| `type` | `String` (`income` / `expense`) | |
| `iconCode` | `int?` | codepoint Material Icon |
| `colorHex` | `String?` | |
| `isDefault` | `bool` | `true` = danh mục seed sẵn |

### 2.4. `transactions` — model `Transaction` (`lib/data/firestore/models/transaction.dart`) *(Member 2 sở hữu, Member 3 chỉ đọc)*

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` (Document ID) | `String` | UUID |
| `userId` | `String` | = uid, dùng để lọc giao dịch theo người đăng nhập |
| `walletId` | `String` | → wallets |
| `categoryId` | `String?` | → categories; null nếu `transfer` |
| `type` | `String` (`income` / `expense` / `transfer`) | |
| `amount` | `double` | **luôn dương**, dấu +/- do `type` quyết định |
| `date` | `Timestamp` | |
| `note` | `String?` | |
| `toWalletId` | `String?` | chỉ khi `type = transfer` |

### 2.5. `budgets` — model `Budget` (`lib/data/firestore/models/budget.dart`) *(Member 3 sở hữu)*

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` (Document ID) | `String` | UUID |
| `userId` | `String` | = uid, dùng để lọc ngân sách theo người đăng nhập |
| `categoryId` | `String` | → categories |
| `month` | `int` | 1–12 |
| `year` | `int` | |
| `limitAmount` | `double` | |

---

## 3. Cách thao tác dữ liệu (đọc kỹ phần này)

### 3.1. Luôn đi qua tầng ORM

```dart
// ĐÚNG: dùng hàm collection có sẵn converter
import 'package:project_mobile/data/firestore/firestore_collections.dart';
final ref = walletsCollection(db).doc(id);  // CollectionReference<Wallet>
await ref.set(wallet);                       // tự gọi wallet.toDocument()
final wallet = (await ref.get()).data();     // tự gọi Wallet.fromDocument()

// SAI: đừng tự tay thao tác Map
FirebaseFirestore.instance.collection('wallets').doc(id).set({'name': '...'});
```

Các hàm có sẵn trong `lib/data/firestore/firestore_collections.dart`:
`usersCollection`, `walletsCollection`, `categoriesCollection`, `transactionsCollection`, `budgetsCollection` — tất cả đã gắn converter.

### 3.2. Repository pattern

Mỗi feature có 2 file:

```text
lib/features/<ten-feature>/data/repositories/
├── <ten>_repository.dart            # interface (hợp đồng dữ liệu)
└── firestore_<ten>_repository.dart  # implement bằng Firestore
```

Mẫu tham khảo: `lib/features/wallet/data/repositories/firestore_wallet_repository.dart`.

### 3.3. Lọc theo người dùng

Firestore không tự biết "của ai" — luôn lọc bằng `userId`:

```dart
final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
walletsCollection(db).where('userId', isEqualTo: uid)...
```

### 3.4. Cập nhật số dư ví từ Transaction (Member 2 phải dùng)

```dart
// Trong TransactionRepository khi tạo giao dịch:
final walletRepo = ref.read(walletRepositoryProvider);   // Leader cung cấp
await walletRepo.updateBalance(walletId, delta);         // delta: + thu / - chi
```

---

## 4. Tên Provider/Repository — dùng đúng tên này, đừng tự đặt tên khác

> Mấy provider mà cột "Ai implement" ghi Leader là Leader viết sẵn rồi, Member 2/3 chỉ import và dùng.

| Provider/Repository | Ai implement | Ai được dùng | Input | Output |
|---|---|---|---|---|
| `firebaseFirestoreProvider` | Leader | Tất cả repository | — | `FirebaseFirestore` |
| `firebaseAuthProvider` | Leader | Auth | — | `FirebaseAuth` |
| `authServiceProvider` | Leader | Màn hình đăng nhập | — | `AuthService` (`register`, `signIn`, `signOut`) |
| `currentUserProvider` | Leader | Member 2, 3 (lấy `id`, `currencyCode`) | — | `AsyncValue<AppUser?>` |
| `firebaseSeedProvider` | Leader | Khởi động app | — | seed 13 danh mục mặc định |
| `walletRepositoryProvider` | Leader | Member 2 (cập nhật số dư khi tạo transaction) | — | `WalletRepository` (`updateBalance(walletId, delta)`) |
| `totalBalanceProvider` | Leader | Member 3 (tổng quan) | — | `AsyncValue<double>` |
| `categoryRepositoryProvider` | Member 2 | Member 3 (đọc danh mục) | — | `CategoryRepository` (`getAll()`, `getById(id)`, ...) |
| `transactionsByMonthProvider` | Member 2 | Member 3 (biểu đồ xu hướng) | `({int month, int year})` | `Stream<List<Transaction>>` |
| `transactionsByCategoryProvider` | Member 2 | Member 3 (pie chart + % budget) | `({int month, int year})` | `AsyncValue<Map<String, double>>` |
| `budgetRepositoryProvider` | Member 3 | — (nội bộ) | — | `BudgetRepository` |

**Quy tắc chung:** ai sở hữu collection nào thì người đó viết Repository cho collection đó và công bố Provider public như bảng trên. Nếu cần thêm Provider mới → báo Leader trong nhóm chat trước khi tạo.

---

## 5. Auth (Firebase Authentication)

- `currentUserProvider` là `StreamProvider<AppUser?>` — lắng nghe trạng thái đăng nhập theo thời gian thực.
- Màn hình đăng nhập/đăng ký do **Leader** phụ trách (đã hoàn thành).
- Member 2/3 khi cần `userId`: `ref.watch(currentUserProvider).value?.id` (xử lý cả trường hợp null = chưa đăng nhập).

---

## 6. Checklist bàn giao

- [x] Tầng ORM Firestore (`models`, `firestore_collections`) build thành công
- [x] Xóa toàn bộ thư mục `lib/data/database/` (Drift/SQLite cũ) và dependencies thừa
- [x] `WalletRepository` chạy trên Firestore, giữ nguyên interface cũ
- [x] `AuthService` (đăng ký/đăng nhập/đăng xuất/quên mật khẩu) + `currentUserProvider`
- [x] Màn hình đăng nhập/đăng ký (`LoginScreen`, `RegisterScreen`, `AuthGate`)
- [x] Seeder 13 danh mục mặc định lên Firestore (idempotent)
- [x] Unit test + widget test xanh (không phụ thuộc Drift)
- [ ] Member 2: `CategoryRepository` + `TransactionRepository` + UI trên Firestore
- [ ] Member 3: `BudgetRepository` + `Analytics` + UI trên Firestore
- [ ] Merge toàn bộ vào `develop`, cả nhóm chạy kiểm thử cuối kỳ

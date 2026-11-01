# 📱 Project Mobile — Expense Tracker App

Ứng dụng quản lý tài chính cá nhân được xây dựng bằng **Flutter**, **Riverpod**, **Firebase Authentication** và **Cloud Firestore (ORM Document)**.

---

## 👥 Phân chia công việc theo vai trò

| Thành viên | Trách nhiệm chính | Nhánh Git |
| --- | --- | --- |
| **Member 1 (Leader — Minh, MSSV: 22010009)** | Firebase Auth, Quản lý Ví (`Wallet`), Tầng ORM Firestore (`lib/data/firestore/`), Design System | `feature/leader-auth-wallet-v2` |
| **Member 2 (Hải Đăng, MSSV: 24100454)** | Quản lý Giao dịch (`Transaction`), Danh mục (`Category`) trên Firestore | `feature/member2-transaction-category-v2` |
| **Member 3 (Đinh Đức Thịnh, MSSV: 24100005)** | Quản lý Ngân sách (`Budget`), Báo cáo & Biểu đồ (`Analytics`) trên Firestore | `feature/member3-budget-analytics-v2` |

> 📖 **Tài liệu bắt buộc cho thành viên:**
> - [docs/Huong-Dan-Firestore-Cho-Member.md](docs/Huong-Dan-Firestore-Cho-Member.md) — Hướng dẫn công nghệ Firebase + Firestore + Riverpod + Design System.
> - [docs/Schema-Va-Ban-Giao.md](docs/Schema-Va-Ban-Giao.md) — Schema 5 Collection Firestore & Bảng quy ước Provider chuẩn.

---

## 🛠️ Hướng dẫn bắt đầu cho thành viên nhóm

### 1. Đồng bộ nhánh `develop` mới nhất (đã xóa bỏ hoàn toàn Drift/SQLite cũ)

```bash
git fetch origin
git checkout develop
git reset --hard origin/develop

# Tạo lại nhánh làm việc từ develop sạch:
# Dành cho Member 2:
git checkout -B feature/member2-transaction-category

# Dành cho Member 3:
git checkout -B feature/member3-budget-analytics
```

### 2. Tải dependencies & Chạy ứng dụng

```bash
flutter pub get
flutter run -d chrome          # hoặc chạy trên Android Emulator
```

### 3. Chạy kiểm thử (Unit Test & Widget Test)

```bash
flutter test
```

---

## 📁 Cấu trúc thư mục

```text
lib/
├── core/                  # Màu sắc (AppColors), Theme Agoda, Firebase Providers, Widgets dùng chung
├── data/
│   └── firestore/         # Tầng ORM với Documents của Firebase Firestore (Câu 7)
│       ├── firestore_collections.dart # CollectionReference<T> gắn sẵn withConverter
│       ├── models/        # 5 đối tượng ORM: AppUser, Wallet, Category, Transaction, Budget
│       └── seed/          # InitialSeeder (13 danh mục thu/chi mặc định idempotent)
├── entities/              # Lớp Generic và các Model kế thừa tổng quát hóa (OOP)
│   ├── Genericclass.dart  # Lớp Genericclass<T> chuẩn bài giảng
│   ├── generic_class.dart # Export chuẩn snake_case
│   └── project_models.dart# WalletModel, CategoryModel, TransactionModel, BudgetModel
├── features/              # Phân chia theo từng tính năng (3 lớp: Data -> Providers -> Presentation)
│   ├── auth/              # Đăng nhập, Đăng ký, Quên mật khẩu, AuthGate (Leader)
│   ├── wallet/            # Quản lý ví & số dư trên Firestore + Mock (Leader)
│   ├── category/          # Quản lý danh mục thu/chi (Member 2)
│   ├── transaction/       # Ghi chép giao dịch thu/chi/chuyển khoản (Member 2)
│   ├── budget/            # Hạn mức ngân sách theo tháng (Member 3)
│   ├── analytics/         # Thống kê & Biểu đồ fl_chart (Member 3)
│   ├── main_nav/          # Shell điều hướng chính (BubbleBottomNav 4 tab + BalanceChip)
│   └── generics_demo/     # Giao diện minh họa Generics Output
└── expense.dart           # Đối tượng Expense viết lại kế thừa Genericclass<Object>
```

---

## 📚 Báo cáo Bài tập: Generics, Kế thừa & Tổng quát hóa Đối tượng (OOP)

> **Căn cứ tài liệu:** Bài giảng môn Lập trình thiết bị di động — Phenikaa University: *DART : Class - Interface - Inheritance | Class - Abstract Class - Interface - Constructor - Generics*.

### 1. Mục đích (Purpose)
* **Tránh lặp lại mô tả đối tượng (To avoid repetition of Class for objects):** Các thực thể trong ứng dụng Quản lý Chi tiêu (Expense, Ví tiền, Danh mục, Giao dịch, Ngân sách) đều có những thuộc tính cốt lõi chung như mã định danh (`id`), tên gọi (`name`/`title`), và mô tả (`description`).
* **Tổng quát hóa (Generics):** Sử dụng `Genericclass<T>`, `Object class` và `Class class` (Generic Type Parameters & Đa hình) để viết một lần, áp dụng an toàn kiểu cho nhiều đối tượng khác nhau.

---

### 2. Xây dựng đối tượng Generics miêu tả chung các đối tượng trong Project
* **File mã nguồn:** [lib/entities/Genericclass.dart](lib/entities/Genericclass.dart) *(export qua [lib/entities/generic_class.dart](lib/entities/generic_class.dart))*
* **Đặc điểm thiết kế:**
  * Lớp `Genericclass<T>` tổng quát hóa kiểu dữ liệu cho 3 trường cơ sở:
    * `T id;` — Mã định danh đối tượng (có thể là `int`, `String`...).
    * `T name;` — Tên hoặc tiêu đề của đối tượng.
    * `T description;` — Mô tả chi tiết về đối tượng.
  * Cung cấp đầy đủ các phương thức getter & setter: `getId()`, `getName()`, `getDescription()`, `setId()`, `setName()`, `setDescription()`.

```dart
class Genericclass<T> {
  T id;
  T name;
  T description;

  Genericclass({
    required this.id,
    required this.name,
    required this.description,
  });

  T getId() => id;
  T getName() => name;
  T getDescription() => description;

  T setId(T newId) { id = newId; return id; }
  T setName(T newName) { name = newName; return name; }
  T setDescription(T newDescription) { description = newDescription; return description; }
}
```

---

### 3. Kế thừa (extends) & Tổng quát hóa Code trong Bài tập lớn

#### 3.1. Viết lại đối tượng `Expense` đã có trong bài tập thực hành
* **File mã nguồn:** [lib/expense.dart](lib/expense.dart)
* **Kế thừa:** `class Expense extends Genericclass<Object>`
  * Kế thừa `id`, `name`, `description` từ `Genericclass<Object>` qua `super`.
  * Có getter/setter `title` ánh xạ trực tiếp vào `name` để tương thích hoàn toàn mã nguồn cũ.
  * Bổ sung các trường chuyên biệt của bài tập chi tiêu: `amount` (số tiền), `category` (danh mục), `date` (thời gian).
  * Giữ nguyên các phương thức nghiệp vụ: `getFormattedAmount()`, `getExpenseDetails()`, `updateAmount()`.

#### 3.2. Mở rộng các đối tượng trong Bài tập lớn (Project Mobile)
* **File mã nguồn:** [lib/entities/project_models.dart](lib/entities/project_models.dart)
* Tất cả đối tượng nghiệp vụ của nhóm đều kế thừa từ `Genericclass<Object>`:
  1. **`WalletModel` (Leader):** Thêm trường `balance` (số dư), `walletType` (loại ví), phương thức `deposit()`, `withdraw()`, `getFormattedBalance()`.
  2. **`CategoryModel` (Member 2):** Thêm trường `type` (thu/chi), `iconName`, `colorHex`, phương thức `isExpense`, `isIncome`.
  3. **`TransactionModel` (Member 2):** Thêm trường `amount`, `date`, `walletId`, `categoryId`, `transactionType`, phương thức `getFormattedAmount()`.
  4. **`BudgetModel` (Member 3):** Thêm trường `limitAmount`, `spentAmount`, `startDate`, `endDate`, phương thức tính ngân sách còn lại `remainingAmount` và phần trăm đã dùng `percentageUsed`.

#### 3.3. Ứng dụng Object Class và Class class để tổng quát hóa
* **Sử dụng `Object class`:** Trong Dart, `Object` là gốc của mọi kiểu dữ liệu. Việc khai báo `extends Genericclass<Object>` cho phép trường `id` có thể nhận cả kiểu số nguyên (`int`: `1`, `101`) hoặc kiểu chuỗi (`String`: `'W-01'`, `'CAT-FOOD'`) mà không làm phá vỡ tính tương thích.
* **Sử dụng `Class class` (Generics & Đa hình):**
  * Xây dựng lớp tổng quát `GenericEntityManager<T extends Genericclass<Object>>` trong [lib/entities/project_models.dart](lib/entities/project_models.dart).
  * Lớp này cho phép lưu trữ, tìm kiếm (`findById`), và duyệt qua tất cả các thực thể khác nhau (`Expense`, `WalletModel`, `CategoryModel`, `BudgetModel`) bằng một cơ chế xử lý duy nhất, không cần viết code lặp lại cho từng bảng/đối tượng.

---

### 4. Giao diện Demo & Kiểm thử (Generics Output)

* **Màn hình Demo:** [lib/features/generics_demo/generic_demo_screen.dart](lib/features/generics_demo/generic_demo_screen.dart)
  * Tái hiện màn hình **Generics Output** (tương tự trang 4 & 5 trong slide bài giảng).
  * Hiển thị trực quan dữ liệu của `Expense` và `WalletModel` (đối tượng do Leader phụ trách) cùng danh sách tổng quát hóa từ `GenericEntityManager`.
* **Kiểm thử tự động (Unit Test):** [test/generics_test.dart](test/generics_test.dart) & [test/wallet_repository_test.dart](test/wallet_repository_test.dart)
  * Chạy toàn bộ test bằng lệnh:
    ```bash
    flutter test
    ```

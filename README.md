# 📱 Project Mobile — Expense Tracker App

Ứng dụng quản lý tài chính cá nhân được xây dựng bằng **Flutter**, **Riverpod** và **Drift (SQLite)**.

---

## 👥 Phân chia công việc theo vai trò

| Thành viên | Trách nhiệm chính | Nhánh Git |
| --- | --- | --- |
| **Member 1 (Leader)** | Auth, Quản lý Ví (`Wallet`), Base Database | `feature/leader-auth-wallet` |
| **Member 2** | Quản lý Giao dịch (`Transaction`), Danh mục (`Category`) | `feature/member2-transaction-category` |
| **Member 3** | Quản lý Ngân sách (`Budget`), Báo cáo & Biểu đồ (`Analytics`) | `feature/member3-budget-analytics` |

> 📖 **Quy ước Database & Provider:** Xem chi tiết tại [docs/Schema-Va-Ban-Giao.md](docs/Schema-Va-Ban-Giao.md).

---

## 🛠️ Hướng dẫn bắt đầu cho thành viên nhóm

### 1. Cài đặt & Lấy code mới nhất

```bash
# Checkout về nhánh develop và lấy code mới nhất
git checkout develop
git pull origin develop

# Tạo nhánh tính năng của bạn
# Dành cho Member 2:
git checkout -b feature/member2-transaction-category

# Dành cho Member 3:
git checkout -b feature/member3-budget-analytics
```

### 2. Tải dependencies & Generate code

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 3. Chạy ứng dụng

```bash
# Chạy trên Windows hoặc Emulator:
flutter run

# Nếu chạy trên Web (Chrome), chạy lệnh setup một lần trước:
dart run tool/setup_web.dart
flutter run -d chrome
```

---

## 📁 Cấu trúc thư mục

```text
lib/
├── core/                  # Màu sắc, Theme, Tiện ích (Formatters, Constants)
├── data/
│   └── database/          # Drift Database & Schema các bảng
├── entities/              # Lớp Generic và các Model kế thừa tổng quát hóa
│   ├── Genericclass.dart  # [Câu 1] Lớp Genericclass<T> chuẩn bài giảng
│   ├── generic_class.dart # Export chuẩn snake_case
│   └── project_models.dart# [Câu 2] WalletModel, CategoryModel, BudgetModel...
├── features/              # Phân chia theo từng tính năng
│   ├── auth/              # Xác thực người dùng (Leader)
│   ├── wallet/            # Quản lý ví & số dư (Leader)
│   ├── category/          # Quản lý danh mục (Member 2)
│   ├── transaction/       # Ghi chép giao dịch thu/chi (Member 2)
│   ├── budget/            # Hạn mức ngân sách (Member 3)
│   ├── analytics/         # Thống kê & Biểu đồ (Member 3)
│   └── generics_demo/     # [Demo] Giao diện minh họa Generics Output
└── expense.dart           # [Câu 2] Đối tượng Expense viết lại kế thừa Genericclass<Object>
```

---

## 📚 Báo cáo Bài tập: Generics, Kế thừa & Tổng quát hóa Đối tượng (OOP)

> **Căn cứ tài liệu:** Bài giảng môn Lập trình thiết bị di động — Phenikaa University: *DART : Class - Interface - Inheritance | Class - Abstract Class - Interface - Constructor - Generics*.

### 1. Mục đích (Purpose)
* **Tránh lặp lại mô tả đối tượng (To avoid repetition of Class for objects):** Các thực thể trong ứng dụng Quản lý Chi tiêu (Expense, Ví tiền, Danh mục, Giao dịch, Ngân sách) đều có những thuộc tính cốt lõi chung như mã định danh (`id`), tên gọi (`name`/`title`), và mô tả (`description`).
* **Tổng quát hóa (Generics):** Sử dụng `Genericclass<T>`, `Object class` và `Class class` (Generic Type Parameters & Đa hình) để viết một lần, áp dụng an toàn kiểu cho nhiều đối tượng khác nhau.

---

### 2. Câu 1: Xây dựng đối tượng Generics miêu tả chung các đối tượng trong Project
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

### 3. Câu 2: Kế thừa (extends) & Tổng quát hóa Code trong Bài tập lớn

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
  * **Cách mở trên ứng dụng:** Tại màn hình chính **Ví tiền**, bấm vào nút **"Generics Demo"** ở góc trên cùng bên phải.
* **Kiểm thử tự động (Unit Test):** [test/generics_test.dart](test/generics_test.dart)
  * Đã viết đầy đủ 4 bài test kiểm tra hoạt động của `Genericclass<T>`, kế thừa `Expense`, các Model bài tập lớn và `GenericEntityManager`.
  * Chạy test bằng lệnh:
    ```bash
    flutter test test/generics_test.dart
    ```


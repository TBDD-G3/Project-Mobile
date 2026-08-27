# 📱 Project Mobile — Expense Tracker App

Ứng dụng quản lý tài chính cá nhân được xây dựng bằng **Flutter**, **Riverpod** và **Drift (SQLite)**.

---

## 👥 Phân chia công việc theo vai trò

| Thành viên | Trách nhiệm chính | Nhánh Git |
|---|---|---|
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
# Chạy trên trình duyệt Chrome hoặc Windows / Emulator
flutter run
```

---

## 📁 Cấu trúc thư mục

```text
lib/
├── core/                  # Màu sắc, Theme, Tiện ích (Formatters, Constants)
├── data/
│   └── database/          # Drift Database & Schema các bảng
└── features/              # Phân chia theo từng tính năng
    ├── auth/              # Xác thực người dùng (Leader)
    ├── wallet/            # Quản lý ví & số dư (Leader)
    ├── category/          # Quản lý danh mục (Member 2)
    ├── transaction/       # Ghi chép giao dịch thu/chi (Member 2)
    ├── budget/            # Hạn mức ngân sách (Member 3)
    └── analytics/         # Thống kê & Biểu đồ (Member 3)
```
# 📋 TÀI LIỆU BÀN GIAO — Database Schema & Provider Convention

**Người viết:** Leader (Member 1) | **Nhánh:** `feature/leader-auth-wallet` → sẽ merge vào `develop`  
**Mục đích:** Thành viên 2 & 3 đọc file này để biết chính xác tên bảng, tên field, kiểu dữ liệu và tên Provider/Repository được phép gọi. **Không tự ý đổi tên field hoặc tạo bảng trùng chức năng.**

---

## 1. Sơ đồ quan hệ (tổng quan)

```text
User (1) ──< Wallet (nhiều)
Wallet (1) ──< Transaction (nhiều)
Category (1) ──< Transaction (nhiều)
Category (1) ──< Budget (nhiều)
```

---

## 2. Chi tiết từng bảng (Drift)

### 2.1. `User`

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `TEXT` (PK) | UUID |
| `email` | `TEXT` | unique |
| `passwordHash` | `TEXT` | nullable nếu dùng Firebase Auth |
| `displayName` | `TEXT` | nullable |
| `avatarPath` | `TEXT` | nullable |
| `currencyCode` | `TEXT` | mặc định `'VND'` |
| `createdAt` | `DATETIME` | tự động tạo timestamp |

### 2.2. `Wallet`

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `TEXT` (PK) | UUID |
| `userId` | `TEXT` (FK → User.id) | |
| `name` | `TEXT` | vd: "Tiền mặt", "Vietcombank" |
| `type` | `TEXT` (enum: `cash`, `bank`, `ewallet`) | |
| `balance` | `REAL` | **luôn cập nhật qua Transaction, không sửa tay trong UI** |
| `iconCode` | `INTEGER` | nullable, codepoint icon |
| `colorHex` | `TEXT` | nullable, vd `'#4CAF50'` |
| `createdAt` | `DATETIME` | |

### 2.3. `Category` *(Member 2 sở hữu, nhưng Member 3 chỉ đọc)*

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `TEXT` (PK) | UUID |
| `name` | `TEXT` | |
| `type` | `TEXT` (enum: `income`, `expense`) | |
| `iconCode` | `INTEGER` | nullable |
| `colorHex` | `TEXT` | nullable |
| `isDefault` | `BOOLEAN` | true nếu là danh mục seed sẵn |

### 2.4. `Transaction` *(Member 2 sở hữu, Member 3 chỉ đọc)*

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `TEXT` (PK) | UUID |
| `walletId` | `TEXT` (FK → Wallet.id) | |
| `categoryId` | `TEXT` (FK → Category.id) | nullable nếu type=`transfer` |
| `type` | `TEXT` (enum: `income`, `expense`, `transfer`) | |
| `amount` | `REAL` | luôn dương, dấu +/- do `type` quyết định |
| `date` | `DATETIME` | |
| `note` | `TEXT` | nullable |
| `toWalletId` | `TEXT` (FK → Wallet.id) | chỉ dùng khi `type = transfer` |

### 2.5. `Budget` *(Member 3 sở hữu)*

| Field | Kiểu | Ghi chú |
|---|---|---|
| `id` | `TEXT` (PK) | UUID |
| `categoryId` | `TEXT` (FK → Category.id) | |
| `month` | `INTEGER` | 1–12 |
| `year` | `INTEGER` | |
| `limitAmount` | `REAL` | |

---

## 3. Provider/Repository — tên chuẩn để gọi (không tự đặt tên khác)

> Các Provider có 🔒 là do **Leader implement sẵn**, Member 2/3 **chỉ import và dùng**, không viết lại logic bên trong.

| Provider/Repository | Ai implement | Ai được dùng | Input | Output |
|---|---|---|---|---|
| 🔒 `walletRepositoryProvider` | Leader | Member 2 (để trừ/cộng số dư khi tạo transaction) | — | `WalletRepository` (có method `updateBalance(walletId, delta)`) |
| 🔒 `totalBalanceProvider` | Leader | Member 3 (hiển thị tổng quan) | — | `double` (hoặc `AsyncValue<double>`) |
| 🔒 `currentUserProvider` | Leader | Member 2, 3 (lấy `userId`, `currencyCode` để format tiền) | — | `User?` (hoặc `AsyncValue<User?>`) |
| `categoryRepositoryProvider` | Member 2 | Member 3 (đọc danh mục để vẽ chart/đặt budget) | — | `CategoryRepository` (method `getAll()`, `getById(id)`) |
| `transactionsByMonthProvider` | Member 2 | Member 3 (vẽ biểu đồ xu hướng) | `(month, year)` | `List<Transaction>` (hoặc `AsyncValue<List<Transaction>>`) |
| `transactionsByCategoryProvider` | Member 2 | Member 3 (vẽ pie chart + tính % budget) | `(month, year)` | `Map<String, double>` |
| `budgetRepositoryProvider` | Member 3 | — (nội bộ) | — | `BudgetRepository` |

**Quy tắc chung:**

- Ai sở hữu bảng nào thì người đó viết `Repository` cho bảng đó và **công bố Provider public** để người khác dùng.
- Không được import thẳng `AppDatabase` và query tay từ feature khác — luôn đi qua Repository/Provider đã công bố ở bảng trên, để khi đổi cấu trúc DB chỉ cần sửa 1 chỗ.
- Nếu cần thêm Provider mới không có trong bảng này → báo Leader trong nhóm chat trước khi tạo, để tránh trùng chức năng.

---

## 4. Checklist bàn giao (Leader tick khi xong Sprint 0)

- [x] `AppDatabase` (Drift) build thành công, không lỗi generate code
- [x] Bảng `User`, `Wallet`, `Category`, `Transaction`, `Budget` đã có trong schema
- [x] Cấu trúc thư mục feature-first chuẩn cho các thành viên
- [ ] Seed dữ liệu Category mặc định chạy được
- [ ] `walletRepositoryProvider`, `totalBalanceProvider`, `currentUserProvider` hoạt động
- [ ] File này đã gửi vào nhóm chat + đính kèm trong PR đầu tiên vào `develop`
- [ ] Member 2 & 3 đã pull `develop`, build project chạy được trên máy họ

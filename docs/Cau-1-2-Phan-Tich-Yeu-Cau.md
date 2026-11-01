# Phân tích yêu cầu bài toán (Câu 1, Câu 2)

## Yêu cầu bài toán

Ứng dụng Expense Tracker giúp người dùng quản lý chi tiêu cá nhân. Người dùng đăng ký tài khoản bằng email rồi đăng nhập để dùng các chức năng chính: tạo và quản lý ví tiền (tiền mặt, tài khoản ngân hàng, ví điện tử), ghi chép các giao dịch thu/chi/chuyển khoản, phân loại giao dịch theo danh mục, đặt hạn mức chi tiêu (ngân sách) cho từng danh mục trong từng tháng, xem biểu đồ thu chi để nắm thói quen chi tiêu của mình. Ngoài ra ứng dụng còn có phiên đấu giá, người dùng đặt giá trực tiếp ngay trên app.

Dữ liệu lưu trên Firebase Firestore với 5 collection: users, wallets, categories, transactions, budgets. Việc xác thực dùng Firebase Authentication (email/mật khẩu). Ứng dụng viết bằng Flutter, quản lý trạng thái bằng Riverpod.

## User Stories (Câu 1)

Nhóm có 3 thành viên, mỗi thành viên phụ trách ít nhất 4 story, tổng cộng **21 user story** viết đúng định dạng "Là <vai trò>, tôi có thể <hành động>", mỗi câu một hành động nhỏ. Cả 21 câu đã chạy trên `develop`.

1. Là khách, tôi có thể đăng ký tài khoản bằng email.
2. Là người dùng, tôi có thể đăng nhập bằng email và mật khẩu.
3. Là người dùng, tôi có thể yêu cầu gửi email đặt lại mật khẩu.
4. Là người dùng, tôi có thể đăng xuất khỏi ứng dụng.
5. Là người dùng, tôi có thể tạo ví mới.
6. Là người dùng, tôi có thể đổi tên ví.
7. Là người dùng, tôi có thể xoá ví.
8. Là người dùng, tôi có thể xem tổng số dư của tất cả ví.
9. Là người dùng, tôi có thể thêm giao dịch chi.
10. Là người dùng, tôi có thể thêm giao dịch thu.
11. Là người dùng, tôi có thể thêm giao dịch chuyển khoản giữa hai ví.
12. Là người dùng, tôi có thể sửa giao dịch đã ghi.
13. Là người dùng, tôi có thể xoá giao dịch đã ghi.
14. Là người dùng, tôi có thể xem giao dịch theo tháng.
15. Là người dùng, tôi có thể lọc giao dịch theo danh mục.
16. Là người dùng, tôi có thể lọc giao dịch theo loại.
17. Là người dùng, tôi có thể tạo danh mục mới.
18. Là người dùng, tôi có thể đặt hạn mức chi tiêu tháng cho một danh mục.
19. Là người dùng, tôi có thể nhận cảnh báo khi chi vượt hạn mức.
20. Là người dùng, tôi có thể xem biểu đồ chi tiêu theo danh mục.
21. Là người dùng, tôi có thể xem biểu đồ thu chi sáu tháng.

> Màn Phiên Đấu Giá là màn hình mẫu của Câu 5, không nằm trong danh sách user story nghiệp vụ.

## Phân tích đối tượng (Câu 2)

Phần dữ liệu của ứng dụng có 5 đối tượng chính, mỗi đối tượng là một class trong thư mục `lib/data/firestore/models` và tương ứng với một collection trong Firestore. Class nào cũng có `fromDocument` (ánh xạ document Firestore thành object) và `toDocument` (ánh xạ object thành document), hầu hết có thêm `copyWith` để sửa object mà không phải tạo lại từ đầu.

### 1. AppUser (người dùng)

- Mục đích: lưu hồ sơ người dùng trong collection `users`, id của document trùng với uid của Firebase Authentication. Mật khẩu không lưu ở đây, Firebase Authentication đảm nhiệm việc xác thực.
- Thuộc tính: `id`, `email`, `displayName`, `currencyCode` (mặc định 'VND'), `createdAt`.
- Phương thức: `fromDocument(id, data)`, `toDocument()`. Class này không có `copyWith`.
- Phương thức hoạt động: `AuthService.register()` tạo tài khoản bằng `createUserWithEmailAndPassword` rồi ghi hồ sơ vào `users`; `signIn()` đăng nhập bằng email/mật khẩu; `sendPasswordReset()` gửi email đặt lại mật khẩu; `signOut()` đăng xuất; `authStateChanges` trả về stream trạng thái đăng nhập và đọc hồ sơ từ Firestore thành `AppUser`.

### 2. Wallet (ví tiền)

- Mục đích: một ví tiền của người dùng, loại 'cash' (tiền mặt), 'bank' (ngân hàng) hoặc 'ewallet' (ví điện tử). Số dư không sửa tay trên giao diện mà chỉ thay đổi khi thêm/sửa/xoá giao dịch.
- Thuộc tính: `id`, `userId`, `name`, `type`, `balance`, `iconCode`, `colorHex`, `createdAt`.
- Phương thức: `fromDocument(id, data)`, `toDocument()`, `copyWith()`.
- Phương thức hoạt động (interface `WalletRepository`): `watchAllWallets()` lấy stream danh sách ví, `getWalletById(id)`, `insertWallet(wallet)`, `updateWallet(wallet)`, `updateBalance(walletId, delta)` cộng/trừ số dư khi có giao dịch, `deleteWallet(id)`. Lớp `FirestoreWalletRepository` ghi qua `walletsCollection(db).doc(id).set()/update()/delete()`, riêng `updateBalance` dùng `FieldValue.increment(delta)` để cộng trừ nguyên tử trên server tránh race condition; `watchAllWallets` lọc `where('userId', isEqualTo: uid)` rồi sắp xếp theo `createdAt`. Ngoài ra còn có `MockWalletRepository` chạy trong bộ nhớ (List + StreamController) phục vụ chế độ mock và kiểm thử. Provider `walletsStreamProvider` và `totalBalanceProvider` đưa danh sách ví và tổng số dư lên giao diện.

### 3. Category (danh mục)

- Mục đích: phân loại giao dịch thu/chi. Có các danh mục mặc định (`isDefault = true`) và người dùng có thể tự tạo thêm. Category không có `userId` nên dùng chung cho mọi tài khoản.
- Thuộc tính: `id`, `name`, `type` ('income' | 'expense'), `iconCode`, `colorHex`, `isDefault`.
- Phương thức: `isExpense`, `isIncome` (getter), `fromDocument(id, data)`, `toDocument()`, `copyWith()`.
- Phương thức hoạt động (interface `CategoryRepository`): `watchAll()`, `getAll()`, `getById(id)`, `insertCategory(category)`, `updateCategory(category)`, `deleteCategory(id)`.

### 4. Transaction (giao dịch)

- Mục đích: ghi lại một khoản thu, chi hoặc chuyển khoản gắn với một ví cụ thể.
- Thuộc tính: `id`, `userId`, `walletId`, `categoryId`, `type` ('income' | 'expense' | 'transfer'), `amount` (luôn dương, dấu cộng/trừ do `type` quyết định), `date`, `note`, `toWalletId` (chỉ dùng khi `type` là 'transfer').
- Phương thức: `isExpense`, `isIncome`, `isTransfer` (getter), `fromDocument(id, data)`, `toDocument()`, `copyWith()`.
- Phương thức hoạt động (interface `TransactionRepository`): `watchTransactionsByMonth(month, year)`, `watchByWallet(walletId)`, `insertTransaction(transaction)`, `updateTransaction(transaction)`, `deleteTransaction(transaction)`. Theo hợp đồng ghi trong interface, khi thêm/xoá giao dịch phải gọi `walletRepository.updateBalance(walletId, delta)` để cập nhật số dư ví.

### 5. Budget (ngân sách)

- Mục đích: hạn mức chi tiêu cho một danh mục trong một tháng cụ thể.
- Thuộc tính: `id`, `userId`, `categoryId`, `month` (1-12), `year`, `limitAmount`.
- Phương thức: `fromDocument(id, data)`, `toDocument()`, `copyWith()`.
- Phương thức hoạt động (interface `BudgetRepository`): `watchBudgetsByMonth(month, year)`, `getBudgetByCategory(categoryId, month, year)`, `insertBudget(budget)`, `updateBudget(budget)`, `deleteBudget(id)`.

### Mối quan hệ giữa các đối tượng

- **AppUser 1 - n Wallet.** Mỗi ví có `userId` chỉ ra chủ sở hữu, một người dùng có thể tạo nhiều ví. Khi đọc ví, `FirestoreWalletRepository` lọc `where('userId', isEqualTo: uid)` nên mỗi người chỉ thấy ví của chính mình.
- **AppUser 1 - n Transaction.** Mỗi giao dịch có `userId` ghi lại người tạo. Danh sách giao dịch theo tháng cũng chỉ lấy của người đang đăng nhập.
- **AppUser 1 - n Budget.** Mỗi ngân sách có `userId`, một người dùng đặt nhiều ngân sách cho các danh mục và các tháng khác nhau.
- **Wallet 1 - n Transaction.** Giao dịch gắn với một ví qua `walletId`. Khi giao dịch thay đổi, số dư ví được cập nhật qua `updateBalance` với delta (dương khi thu, âm khi chi). Giao dịch chuyển khoản liên quan đến hai ví: `walletId` là ví nguồn, `toWalletId` là ví nhận tiền.
- **Transaction n - 1 Category.** Giao dịch thuộc một danh mục qua `categoryId`; `categoryId` có thể null khi giao dịch không cần phân loại.
- **Category 1 - n Budget.** Ngân sách gắn với một danh mục qua `categoryId`, kết hợp với `month`/`year` để biết hạn mức của danh mục đó trong tháng.

Về phân quyền dữ liệu: các collection `wallets`, `transactions`, `budgets` đều có trường `userId` trong document, Firestore security rules yêu cầu `userId` trùng với uid đang đăng nhập mới được đọc/ghi, nên mỗi người dùng chỉ thao tác được dữ liệu của chính mình. Riêng `categories` là collection dùng chung (chứa các danh mục mặc định), rule chỉ yêu cầu đã đăng nhập.

# Sơ đồ thiết kế (Câu 3)

Tài liệu này mô tả cấu trúc lớp và các luồng hoạt động chính của ứng dụng. Tên lớp, thuộc tính và phương thức trong sơ đồ lớp lấy đúng theo code trong thư mục `lib/data/firestore/models`. Các sơ đồ tuần tự vẽ theo luồng xử lý trong `lib/features`.

## 1. Sơ đồ lớp (Class Diagram)

```mermaid
classDiagram
    class AppUser {
        +String id
        +String email
        +String displayName
        +String currencyCode
        +DateTime createdAt
        +fromDocument(String id, Map data) AppUser
        +toDocument() Map
    }

    class Wallet {
        +String id
        +String userId
        +String name
        +String type
        +double balance
        +int iconCode
        +String colorHex
        +DateTime createdAt
        +fromDocument(String id, Map data) Wallet
        +toDocument() Map
        +copyWith(...) Wallet
    }

    class Category {
        +String id
        +String name
        +String type
        +int iconCode
        +String colorHex
        +bool isDefault
        +isExpense() bool
        +isIncome() bool
        +fromDocument(String id, Map data) Category
        +toDocument() Map
        +copyWith(...) Category
    }

    class Transaction {
        +String id
        +String userId
        +String walletId
        +String categoryId
        +String type
        +double amount
        +DateTime date
        +String note
        +String toWalletId
        +isExpense() bool
        +isIncome() bool
        +isTransfer() bool
        +fromDocument(String id, Map data) Transaction
        +toDocument() Map
        +copyWith(...) Transaction
    }

    class Budget {
        +String id
        +String userId
        +String categoryId
        +int month
        +int year
        +double limitAmount
        +fromDocument(String id, Map data) Budget
        +toDocument() Map
        +copyWith(...) Budget
    }

    AppUser "1" --> "0..*" Wallet : userId
    AppUser "1" --> "0..*" Transaction : userId
    AppUser "1" --> "0..*" Budget : userId
    Wallet "1" --> "0..*" Transaction : walletId
    Transaction "0..*" --> "0..1" Category : categoryId
    Category "1" --> "0..*" Budget : categoryId
```

Giải thích quan hệ trong sơ đồ:

- **AppUser 1 - 0..\* Wallet**: một người dùng có nhiều ví, mỗi ví thuộc đúng một người dùng qua `userId`.
- **AppUser 1 - 0..\* Transaction**: một người dùng tạo nhiều giao dịch, mỗi giao dịch có đúng một `userId`.
- **AppUser 1 - 0..\* Budget**: một người dùng đặt nhiều ngân sách, mỗi ngân sách có đúng một `userId`.
- **Wallet 1 - 0..\* Transaction**: một ví có nhiều giao dịch, mỗi giao dịch gắn với đúng một ví qua `walletId`. Số dư ví được cập nhật mỗi khi giao dịch thay đổi.
- **Transaction 0..\* - 0..1 Category**: `categoryId` có thể null nên một giao dịch có thể không có danh mục; một danh mục có nhiều giao dịch.
- **Category 1 - 0..\* Budget**: một danh mục có thể có ngân sách cho nhiều tháng, mỗi ngân sách gắn với đúng một danh mục.
- Giao dịch chuyển khoản còn tham chiếu thêm một ví nữa qua `toWalletId` (ví nhận tiền), không vẽ thêm đường nối để sơ đồ đỡ rối.

Các interface repository (`WalletRepository`, `TransactionRepository`, `CategoryRepository`, `BudgetRepository`) nằm trong `lib/features`, không phải class dữ liệu nên không đưa vào sơ đồ lớp trên; phương thức của chúng đã liệt kê ở phần phân tích Câu 2.

## 2. Sơ đồ tuần tự (Sequence Diagram)

### 2.1. Đăng ký và đăng nhập

```mermaid
sequenceDiagram
    actor ND as Người dùng
    participant UI as LoginScreen / RegisterScreen
    participant P as AuthService
    participant FA as Firebase Auth
    participant FS as Firestore

    Note over UI,P: Đăng ký tài khoản mới
    ND->>UI: nhập email, mật khẩu, tên hiển thị
    UI->>P: register(email, password, displayName)
    P->>FA: createUserWithEmailAndPassword(...)
    FA-->>P: trả về credential (uid)
    P->>FS: usersCollection(db).doc(uid).set(user)
    FS-->>P: ghi hồ sơ xong

    Note over UI,P: Đăng nhập
    ND->>UI: nhập email, mật khẩu
    UI->>P: signIn(email, password)
    P->>FA: signInWithEmailAndPassword(...)
    FA-->>P: đăng nhập thành công

    Note over P,FS: AuthGate theo dõi trạng thái đăng nhập
    P->>FA: authStateChanges() (stream)
    FA-->>P: trả về faUser
    P->>FS: usersCollection(db).doc(uid).get()
    FS-->>P: trả về AppUser
    P-->>UI: currentUserProvider phát AppUser
    UI-->>ND: AuthGate hiển thị MainNavScreen, chưa đăng nhập thì hiển thị LoginScreen
```

### 2.2. Tạo ví mới

```mermaid
sequenceDiagram
    actor ND as Người dùng
    participant UI as AddEditWalletSheet
    participant P as walletRepositoryProvider
    participant R as FirestoreWalletRepository
    participant FS as Firestore

    ND->>UI: nhập tên ví, chọn loại, nhập số dư ban đầu
    UI->>UI: tạo Wallet(id, userId, name, type, balance)
    UI->>P: đọc walletRepositoryProvider
    P->>R: insertWallet(wallet)
    R->>FS: walletsCollection(db).doc(wallet.id).set(wallet)
    FS-->>R: ghi xong
    R-->>P: hoàn tất
    P-->>UI: walletsStreamProvider phát lại danh sách ví (watchAllWallets)
    UI-->>ND: hiển thị ví mới, tổng số dư được tính lại
```

### 2.3. Thêm giao dịch và cập nhật số dư ví

```mermaid
sequenceDiagram
    actor ND as Người dùng
    participant UI as TransactionsScreen
    participant PT as transactionRepositoryProvider
    participant RT as TransactionRepository
    participant RW as WalletRepository
    participant FS as Firestore

    ND->>UI: nhập số tiền, chọn thu/chi, danh mục, ghi chú
    UI->>PT: tạo Transaction(userId, walletId, categoryId, type, amount)
    PT->>RT: insertTransaction(transaction)
    RT->>FS: transactionsCollection(db).doc(id).set(transaction)
    FS-->>RT: ghi xong
    RT-->>PT: hoàn tất
    PT->>RW: updateBalance(walletId, delta)
    Note over RW,FS: delta = +amount nếu thu, -amount nếu chi
    RW->>FS: walletsCollection(db).doc(walletId).update(balance: FieldValue.increment(delta))
    FS-->>RW: cập nhật số dư xong
    RW-->>UI: walletsStreamProvider phát số dư mới
    UI-->>ND: danh sách giao dịch và số dư ví thay đổi
```

### 2.4. Đặt ngân sách tháng

```mermaid
sequenceDiagram
    actor ND as Người dùng
    participant UI as BudgetsScreen
    participant P as budgetRepositoryProvider
    participant R as BudgetRepository
    participant FS as Firestore

    ND->>UI: chọn danh mục, chọn tháng, nhập hạn mức
    UI->>UI: tạo Budget(userId, categoryId, month, year, limitAmount)
    UI->>P: đọc budgetRepositoryProvider
    P->>R: insertBudget(budget)
    R->>FS: budgetsCollection(db).doc(budget.id).set(budget)
    FS-->>R: ghi xong
    P-->>UI: watchBudgetsByMonth(month, year) phát lại danh sách ngân sách
    UI-->>ND: hiển thị hạn mức và tiến độ chi tiêu của danh mục
```

### 2.5. Tham gia phiên đấu giá

```mermaid
sequenceDiagram
    actor ND as Người dùng
    participant UI as AuctionSessionScreen
    participant S as Trạng thái phiên đấu giá (trong bộ nhớ app)

    ND->>UI: bấm nút Đặt Giá Nhanh
    UI->>S: đọc giá hiện tại và bước giá cố định
    S-->>UI: trả về giá hiện tại, bước giá
    UI->>S: giá mới = giá hiện tại + bước giá
    UI->>S: thêm một mục vào Lịch sử trả giá (người đặt, giá mới, thời điểm)
    UI-->>ND: hiển thị giá hiện tại mới và lịch sử trả giá
    Note over UI,S: Toàn bộ xử lý chạy trong app, không ghi Firestore
```

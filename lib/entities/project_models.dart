import 'Genericclass.dart';

// ============================================================================
// CÂU 2: CÁC ĐỐI TƯỢNG TRONG PROJECT KẾ THỪA TỪ Genericclass<Object>
// ============================================================================

/// 1. Mô tả Ví tiền ([WalletModel]) trong ứng dụng Expense Tracker (Phụ trách bởi Leader)
class WalletModel extends Genericclass<Object> {
  double balance;
  String walletType; // Tiền mặt, Ngân hàng, Ví điện tử
  bool isDefault;

  WalletModel({
    required super.id,
    required super.name,
    required super.description,
    required this.balance,
    this.walletType = 'Tiền mặt',
    this.isDefault = false,
  });

  String getFormattedBalance() {
    return '${balance.toStringAsFixed(0)} đ';
  }

  void deposit(double amount) {
    if (amount > 0) balance += amount;
  }

  bool withdraw(double amount) {
    if (amount > 0 && balance >= amount) {
      balance -= amount;
      return true;
    }
    return false;
  }
}

/// 2. Mô tả Danh mục ([CategoryModel]) thu / chi (Phụ trách bởi Member 2)
class CategoryModel extends Genericclass<Object> {
  String type; // 'expense' (chi) hoặc 'income' (thu)
  String iconName;
  String colorHex;

  CategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required this.type,
    this.iconName = 'category',
    this.colorHex = '#2196F3',
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
}

/// 3. Mô tả Giao dịch ([TransactionModel]) thu chi (Phụ trách bởi Member 2)
class TransactionModel extends Genericclass<Object> {
  double amount;
  DateTime date;
  Object walletId;
  Object categoryId;
  String transactionType; // 'expense' hoặc 'income'

  TransactionModel({
    required super.id,
    required super.name, // Tiêu đề giao dịch
    required super.description,
    required this.amount,
    required this.walletId,
    required this.categoryId,
    this.transactionType = 'expense',
    DateTime? date,
  }) : date = date ?? DateTime.now();

  String getFormattedAmount() {
    final prefix = transactionType == 'expense' ? '-' : '+';
    return '$prefix${amount.toStringAsFixed(0)} đ';
  }
}

/// 4. Mô tả Ngân sách ([BudgetModel]) chi tiêu (Phụ trách bởi Member 3)
class BudgetModel extends Genericclass<Object> {
  double limitAmount;
  double spentAmount;
  DateTime startDate;
  DateTime endDate;

  BudgetModel({
    required super.id,
    required super.name,
    required super.description,
    required this.limitAmount,
    this.spentAmount = 0.0,
    required this.startDate,
    required this.endDate,
  });

  double get remainingAmount => limitAmount - spentAmount;

  double get percentageUsed =>
      limitAmount > 0 ? (spentAmount / limitAmount) * 100 : 0.0;
}

// ============================================================================
// TỔNG QUÁT HÓA CODE VỚI CLASS CLASS & OBJECT CLASS (Generic Manager)
// ============================================================================

/// Lớp quản lý tổng quát [GenericEntityManager] ứng dụng `Class class` (Generics)
/// và `Object class` để quản lý mọi đối tượng kế thừa từ [Genericclass<Object>]
/// mà không cần viết lại mã nguồn cho từng đối tượng riêng lẻ.
class GenericEntityManager<T extends Genericclass<Object>> {
  final List<T> _items = [];

  void add(T item) {
    _items.add(item);
  }

  void addAll(List<T> items) {
    _items.addAll(items);
  }

  List<T> getAll() {
    return List.unmodifiable(_items);
  }

  T? findById(Object id) {
    for (final item in _items) {
      if (item.getId() == id) {
        return item;
      }
    }
    return null;
  }

  List<String> summarizeAll() {
    return _items.map((item) {
      return '[${item.runtimeType}] ID: ${item.getId()} | Tên: ${item.getName()} | Mô tả: ${item.getDescription()}';
    }).toList();
  }
}

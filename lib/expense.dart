import 'entities/Genericclass.dart';

/// Expense của bài thực hành, viết lại để kế thừa [Genericclass<Object>]
/// theo yêu cầu tổng quát hóa của bài học.
class Expense extends Genericclass<Object> {
  double amount;
  String category;
  DateTime date;

  Expense({
    super.id = 1,
    required String title,
    super.description = 'Chi tiêu cá nhân trong bài tập',
    required this.amount,
    this.category = 'Chi tiêu cá nhân',
    DateTime? date,
  })  : date = date ?? DateTime.now(),
        super(
          name: title,
        );

  /// Getter/setter cho title, thực ra là đọc/ghi `name` bên class cha.
  String get title => getName().toString();
  set title(String newTitle) => setName(newTitle);

  /// Số tiền dạng chuỗi để hiển thị.
  String getFormattedAmount() {
    return '${amount.toStringAsFixed(0)} đ';
  }

  /// In ra thông tin khoản chi.
  String getExpenseDetails() {
    return '$title - $category: ${getFormattedAmount()}';
  }

  /// Cập nhật số tiền (không cho âm).
  void updateAmount(double newAmount) {
    if (newAmount >= 0) {
      amount = newAmount;
    }
  }
}
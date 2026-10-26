import 'entities/Genericclass.dart';

/// Lớp [Expense] trong bài tập thực hành, được viết lại kế thừa từ [Genericclass<Object>]
/// để tổng quát hóa cấu trúc đối tượng trong dự án theo yêu cầu bài học.
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

  /// Getter và Setter cho `title` ánh xạ trực tiếp vào `name` được thừa kế từ [Genericclass]
  String get title => getName().toString();
  set title(String newTitle) => setName(newTitle);

  /// Định dạng số tiền hiển thị
  String getFormattedAmount() {
    return '${amount.toStringAsFixed(0)} đ';
  }

  /// Lấy thông tin chi tiết của khoản chi tiêu
  String getExpenseDetails() {
    return '$title - $category: ${getFormattedAmount()}';
  }

  /// Cập nhật số tiền
  void updateAmount(double newAmount) {
    if (newAmount >= 0) {
      amount = newAmount;
    }
  }
}
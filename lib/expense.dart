class Expense {
  String title;
  double amount;
  String category;
  DateTime date;
  Expense({
    required this.title,
    required this.amount,
    this.category = 'Chi tiêu cá nhân',
    DateTime? date,
  }) : date = date ?? DateTime.now();

  String getFormattedAmount() {
    return '${amount.toStringAsFixed(0)} đ';
  }

  String getExpenseDetails() {
    return '$title - $category: ${getFormattedAmount()}';
  }

  void updateAmount(double newAmount) {
    if (newAmount >= 0) {
      amount = newAmount;
    }
  }
}
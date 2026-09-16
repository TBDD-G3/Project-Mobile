// lib/features/budget/budget.dart
// Member 3 - Tính năng: Hạn mức ngân sách

class Budget {
  String period;
  String categoryName;
  double limitAmount;
  double spentAmount;

  Budget({
    this.period = '12/2024',
    this.categoryName = 'Ăn uống',
    this.limitAmount = 3000000,
    this.spentAmount = 1800000,
  });

  void setBudget(
    String period,
    String categoryName,
    double limitAmount,
    double spentAmount,
  ) {
    this.period = period;
    this.categoryName = categoryName;
    this.limitAmount = limitAmount;
    this.spentAmount = spentAmount;
  }

  double get remainingAmount => limitAmount - spentAmount;

  String getBudget() {
    return '$categoryName trong $period: Hạn mức = ${limitAmount.toStringAsFixed(0)}đ, '
        'Đã chi = ${spentAmount.toStringAsFixed(0)}đ, Còn lại = ${remainingAmount.toStringAsFixed(0)}đ';
  }
}
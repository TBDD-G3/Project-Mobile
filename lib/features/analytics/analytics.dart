// lib/features/analytics/analytics.dart
// Member 3 - Tính năng: Báo cáo & Biểu đồ

class Analytics {
  String period;
  String reportName;
  double totalIncome;
  double totalExpense;

  Analytics({
    this.period = '12/2024',
    this.reportName = 'Báo cáo thu chi',
    this.totalIncome = 15000000,
    this.totalExpense = 9500000,
  });

  void setAnalytics(
    String period,
    String reportName,
    double totalIncome,
    double totalExpense,
  ) {
    this.period = period;
    this.reportName = reportName;
    this.totalIncome = totalIncome;
    this.totalExpense = totalExpense;
  }

  double get balance => totalIncome - totalExpense;

  String getAnalytics() {
    return '$reportName ($period): Tổng thu = ${totalIncome.toStringAsFixed(0)}đ, '
        'Tổng chi = ${totalExpense.toStringAsFixed(0)}đ, Số dư = ${balance.toStringAsFixed(0)}đ';
  }
}
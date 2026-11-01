import '../../../data/firestore/models/budget.dart';

/// Tiến độ của một ngân sách trong tháng: đã chi bao nhiêu trên hạn mức.
///
/// Lớp thuần Dart, không phụ thuộc Flutter/Firestore nên test được độc lập.
class BudgetProgress {
  const BudgetProgress({required this.budget, required this.spent});

  final Budget budget;

  /// Tổng tiền đã chi của danh mục trong tháng (chỉ giao dịch `expense`).
  final double spent;

  double get limit => budget.limitAmount;

  /// Tỉ lệ đã dùng. Hạn mức 0 trả về 0 thay vì chia cho 0.
  double get ratio => limit <= 0 ? 0 : spent / limit;

  /// Giá trị cho thanh tiến độ, chặn ở 1.0 để thanh không tràn.
  double get barValue => ratio.clamp(0.0, 1.0);

  bool get isOver => limit > 0 && spent > limit;

  bool get isNear => !isOver && ratio >= 0.8;

  /// Số tiền còn lại; âm nghĩa là đã vượt hạn mức.
  double get remaining => limit - spent;

  /// Nhãn trạng thái dùng cho giao diện.
  String get level {
    if (isOver) return 'over';
    if (isNear) return 'near';
    return 'ok';
  }
}

/// Ghép danh sách ngân sách với bản đồ "categoryId → đã chi" thành tiến độ.
List<BudgetProgress> buildBudgetProgress(
  List<Budget> budgets,
  Map<String, double> spentByCategory,
) {
  return [
    for (final budget in budgets)
      BudgetProgress(
        budget: budget,
        spent: spentByCategory[budget.categoryId] ?? 0,
      ),
  ];
}

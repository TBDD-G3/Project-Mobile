/// Ngân sách theo tháng — Firestore Document model (Member 3).
class Budget {
  final String id;
  final String categoryId;

  /// Tháng (1–12) và năm áp dụng ngân sách.
  final int month;
  final int year;
  final double limitAmount;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.year,
    required this.limitAmount,
  });

  factory Budget.fromDocument(String id, Map<String, dynamic> data) {
    return Budget(
      id: id,
      categoryId: data['categoryId'] as String? ?? '',
      month: (data['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      limitAmount: (data['limitAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'categoryId': categoryId,
      'month': month,
      'year': year,
      'limitAmount': limitAmount,
    };
  }
}

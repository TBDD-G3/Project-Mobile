/// Ngân sách theo tháng (Member 3 phụ trách).
class Budget {
  final String id;
  final String userId;
  final String categoryId;

  /// Tháng (1-12) và năm áp dụng ngân sách.
  final int month;
  final int year;
  final double limitAmount;

  const Budget({
    required this.id,
    this.userId = '',
    required this.categoryId,
    required this.month,
    required this.year,
    required this.limitAmount,
  });

  factory Budget.fromDocument(String id, Map<String, dynamic> data) {
    return Budget(
      id: id,
      userId: data['userId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      month: (data['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      limitAmount: (data['limitAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'month': month,
      'year': year,
      'limitAmount': limitAmount,
    };
  }

  Budget copyWith({
    String? userId,
    String? categoryId,
    int? month,
    int? year,
    double? limitAmount,
  }) {
    return Budget(
      id: id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      year: year ?? this.year,
      limitAmount: limitAmount ?? this.limitAmount,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/firestore/models/transaction.dart';

/// 📌 Member 2 implement: Lấy danh sách giao dịch theo tháng/năm
/// Member 3 dùng để vẽ biểu đồ xu hướng
final transactionsByMonthProvider = StreamProvider.family<List<Transaction>, ({int month, int year})>((ref, arg) {
  // TODO: Member 2 implement query transaction by month/year
  return const Stream.empty();
});

/// 📌 Member 2 implement: Tổng hợp số tiền theo Category ID
/// Trả về `Map<String, double>`
/// Member 3 dùng để vẽ Pie chart + tính % budget
final transactionsByCategoryProvider = FutureProvider.family<Map<String, double>, ({int month, int year})>((ref, arg) async {
  // TODO: Member 2 implement aggregate transaction by category
  return {};
});

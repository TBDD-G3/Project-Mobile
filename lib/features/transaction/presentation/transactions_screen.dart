import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

/// 📌 Màn hình Giao dịch (Thu / Chi / Chuyển khoản) — Phụ trách bởi Thành viên 2 (Hải Đăng).
///
/// Đã được gắn cố định vào Tab 1 của `MainNavScreen`.
/// Thành viên 2 chỉ cần code trực tiếp giao diện trong file này (không cần sửa `main_nav_screen.dart`).
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const EmptyState(
      icon: Icons.swap_horiz_rounded,
      background: AppColors.pastelExpense,
      title: 'Giao dịch (Thu / Chi)',
      subtitle:
          'Tính năng do Thành viên 2 phát triển (Ghi chép giao dịch, lọc theo danh mục)',
    );
  }
}

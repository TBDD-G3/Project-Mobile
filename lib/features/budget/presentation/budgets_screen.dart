import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

/// 📌 Màn hình Ngân sách theo tháng — Phụ trách bởi Thành viên 3.
///
/// Đã được gắn cố định vào Tab 2 của `MainNavScreen`.
/// Thành viên 3 chỉ cần code trực tiếp giao diện trong file này (không cần sửa `main_nav_screen.dart`).
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const EmptyState(
      icon: Icons.pie_chart_outline_rounded,
      background: AppColors.pastelBudget,
      title: 'Ngân sách',
      subtitle:
          'Tính năng do Thành viên 3 phát triển (Thiết lập hạn mức chi tiêu theo tháng)',
    );
  }
}

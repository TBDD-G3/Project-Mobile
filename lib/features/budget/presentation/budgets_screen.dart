import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

/// Màn ngân sách theo tháng. Thành viên 3 phụ trách.
/// Đã gắn vào tab 2 sẵn, sửa trực tiếp trong file này, không cần đụng
/// `main_nav_screen.dart`.
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

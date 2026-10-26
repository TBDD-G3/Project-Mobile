import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

/// Màn báo cáo + biểu đồ (fl_chart). Thành viên 3 phụ trách.
/// File này đã gắn vào tab 3, sửa trực tiếp ở đây, không cần đụng
/// `main_nav_screen.dart`.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const EmptyState(
      icon: Icons.bar_chart_rounded,
      background: AppColors.pastelTransfer,
      title: 'Báo cáo & Phân tích',
      subtitle:
          'Tính năng do Thành viên 3 phát triển (Biểu đồ thu chi, tỷ lệ chi tiêu)',
    );
  }
}

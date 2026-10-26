import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

/// 📌 Màn hình Báo cáo & Phân tích (Biểu đồ fl_chart) — Phụ trách bởi Thành viên 3.
///
/// Đã được gắn cố định vào Tab 3 của `MainNavScreen`.
/// Thành viên 3 chỉ cần code trực tiếp giao diện trong file này (không cần sửa `main_nav_screen.dart`).
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

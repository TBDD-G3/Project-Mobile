import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';

/// Màn báo cáo + biểu đồ (fl_chart). Thành viên 3 phụ trách.
/// File này đã gắn vào tab 3, sửa trực tiếp ở đây, không cần đụng
/// `main_nav_screen.dart`.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Báo cáo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Thu chi theo tháng',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: EmptyState(
            icon: Icons.bar_chart_rounded,
            title: 'Chưa có dữ liệu',
            subtitle: 'Thành viên 3 đang phát triển phần này.',
          ),
        ),
      ],
    );
  }
}

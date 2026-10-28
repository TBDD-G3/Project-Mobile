import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';

/// Màn ngân sách theo tháng. Thành viên 3 phụ trách.
/// Đã gắn vào tab 2 sẵn, sửa trực tiếp trong file này, không cần đụng
/// `main_nav_screen.dart`.
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

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
                'Ngân sách',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Hạn mức chi tiêu theo tháng',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: EmptyState(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Chưa có ngân sách',
            subtitle: 'Thành viên 3 đang phát triển phần này.',
          ),
        ),
      ],
    );
  }
}

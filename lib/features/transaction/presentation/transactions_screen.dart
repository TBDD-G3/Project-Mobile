import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';

/// Màn giao dịch thu/chi/chuyển khoản. Thành viên 2 (Hải Đăng) phụ trách.
/// Đã gắn vào tab 1 sẵn, sửa trực tiếp trong file này, không cần đụng
/// `main_nav_screen.dart`.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

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
                'Giao dịch',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Thu · Chi · Chuyển khoản',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: EmptyState(
            icon: Icons.swap_horiz_rounded,
            title: 'Chưa có giao dịch',
            subtitle: 'Thành viên 2 (Hải Đăng) đang phát triển phần này.',
          ),
        ),
      ],
    );
  }
}

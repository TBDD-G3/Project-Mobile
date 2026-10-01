import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../wallet/presentation/wallets_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(databaseInitProvider));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const WalletsScreen(),
      _buildPlaceholder(
        title: 'Giao dịch (Thu / Chi)',
        subtitle: 'Tính năng do Thành viên 2 phát triển (Ghi chép giao dịch, lọc theo danh mục)',
        icon: Icons.swap_horiz,
        color: Colors.orange,
      ),
      _buildPlaceholder(
        title: 'Ngân sách',
        subtitle: 'Tính năng do Thành viên 3 phát triển (Thiết lập hạn mức chi tiêu theo tháng)',
        icon: Icons.pie_chart,
        color: Colors.purple,
      ),
      _buildPlaceholder(
        title: 'Báo cáo & Phân tích',
        subtitle: 'Tính năng do Thành viên 3 phát triển (Biểu đồ thu chi, tỷ lệ chi tiêu)',
        icon: Icons.bar_chart,
        color: Colors.blue,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildPlaceholder({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, size: 44, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

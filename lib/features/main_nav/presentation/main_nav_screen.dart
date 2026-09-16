import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../transaction/presentation/transaction_screen.dart';
import '../../wallet/presentation/wallets_screen.dart';

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
    // Kích hoạt seeder dữ liệu ban đầu
    Future.microtask(() => ref.read(databaseInitProvider));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const WalletsScreen(),
      const TransactionsScreen(),
      _buildPlaceholderScreen(
        title: 'Ngân sách',
        subtitle: 'Tính năng do Thành viên 3 phát triển (Thiết lập hạn mức chi tiêu theo tháng)',
        icon: Icons.pie_chart,
        color: Colors.purple,
      ),
      _buildPlaceholderScreen(
        title: 'Báo cáo & Phân tích',
        subtitle: 'Tính năng do Thành viên 3 phát triển (Biểu đồ thu chi, tỷ lệ chi tiêu)',
        icon: Icons.bar_chart,
        color: Colors.blue,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primaryDark),
            label: 'Ví tiền',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Colors.orange),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart, color: Colors.purple),
            label: 'Ngân sách',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights, color: Colors.blue),
            label: 'Báo cáo',
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderScreen({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
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
      ),
    );
  }
}

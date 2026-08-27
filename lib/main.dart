import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/formatters.dart';
import 'features/wallet/providers/wallet_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalanceAsync = ref.watch(totalBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản Lý Tài Chính',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Tổng số dư
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng số dư',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    totalBalanceAsync.when(
                      data: (balance) => Text(
                        Formatters.formatCurrency(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      error: (err, _) => Text(
                        'Lỗi: $err',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tính năng dự án',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              icon: Icons.account_balance_wallet,
              title: 'Ví & Tài khoản (Leader)',
              subtitle: 'Quản lý ví tiền, cập nhật số dư',
              color: Colors.blue,
            ),
            _buildFeatureTile(
              icon: Icons.swap_horiz,
              title: 'Thu chi & Danh mục (Member 2)',
              subtitle: 'Ghi chép giao dịch, phân loại danh mục',
              color: Colors.orange,
            ),
            _buildFeatureTile(
              icon: Icons.pie_chart,
              title: 'Ngân sách & Báo cáo (Member 3)',
              subtitle: 'Thiết lập hạn mức chi tiêu, biểu đồ trực quan',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

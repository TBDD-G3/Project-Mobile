import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bubble_bottom_nav.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../budget/presentation/budgets_screen.dart';
import '../../transaction/presentation/transactions_screen.dart';
import '../../wallet/presentation/wallets_screen.dart';
import '../../wallet/providers/wallet_providers.dart';

/// 🔒 Shell chung cố định của toàn app:
/// AppBar tên app + chip số dư, nội dung 4 tab đã gắn sẵn màn hình của từng thành viên,
/// bottom nav bong bóng kiểu Agoda.
///
/// ⚠️ CÁC THÀNH VIÊN KHÔNG SỬA FILE NÀY.
/// - Member 1 (Leader): làm việc trong `lib/features/wallet/` & `lib/features/auth/`
/// - Member 2 (Hải Đăng): làm việc trong `lib/features/transaction/` & `lib/features/category/`
/// - Member 3: làm việc trong `lib/features/budget/` & `lib/features/analytics/`
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
    Future.microtask(() => ref.read(firebaseSeedProvider));
  }

  @override
  Widget build(BuildContext context) {
    const screens = [
      WalletsScreen(),
      TransactionsScreen(),
      BudgetsScreen(),
      AnalyticsScreen(),
    ];

    final totalBalance = ref.watch(totalBalanceProvider).value ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          _BalanceChip(balance: totalBalance),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BubbleBottomNav(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        items: const [
          BubbleBottomNavItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Ví tiền',
          ),
          BubbleBottomNavItem(
            icon: Icons.receipt_long_outlined,
            label: 'Giao dịch',
          ),
          BubbleBottomNavItem(
            icon: Icons.pie_chart_outline,
            label: 'Ngân sách',
          ),
          BubbleBottomNavItem(
            icon: Icons.insights_outlined,
            label: 'Báo cáo',
          ),
        ],
      ),
    );
  }
}

/// Chip mint hiển thị tổng số dư trên AppBar (kiểu chip `đ 734K` của Agoda).
class _BalanceChip extends StatelessWidget {
  final double balance;

  const _BalanceChip({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mintChip,
        borderRadius: BorderRadius.circular(AppColors.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.savings_outlined,
            size: 16,
            color: AppColors.mintChipIcon,
          ),
          const SizedBox(width: 6),
          Text(
            'Số dư: ${_compactMoney(balance)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Rút gọn số tiền kiểu Agoda: `32,5 tr` / `1,2 tỷ` — dưới 1 triệu giữ nguyên.
  String _compactMoney(double value) {
    if (value.abs() >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} tỷ';
    }
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} tr';
    }
    return Formatters.formatCurrency(value);
  }
}

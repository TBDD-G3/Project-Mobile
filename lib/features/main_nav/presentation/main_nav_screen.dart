import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../auction/presentation/auction_session_screen.dart';
import '../../auth/presentation/account_screen.dart';
import '../../auth/providers/auth_providers.dart';
import '../../budget/presentation/budgets_screen.dart';
import '../../transaction/presentation/transactions_screen.dart';
import '../../wallet/presentation/wallets_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

/// Shell chung của cả app: header có avatar tài khoản, 5 tab ở bottom nav.
///
/// Tab chỉ được dựng khi mở lần đầu (giữ state sau đó) để màn Phiên Đấu Giá
/// không chạy đồng hồ đếm ngược khi người dùng chưa xem.
///
/// Các thành viên không sửa file này.
/// - Member 1 (Leader): làm trong `lib/features/wallet/`, `lib/features/auth/`
///   và `lib/features/auction/`
/// - Member 2 (Hải Đăng): làm trong `lib/features/transaction/` và `lib/features/category/`
/// - Member 3: làm trong `lib/features/budget/` và `lib/features/analytics/`
class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  int _currentIndex = 0;
  final Set<int> _visited = {0};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(firebaseSeedProvider));
  }

  Widget _screenFor(int index) {
    switch (index) {
      case 0:
        return const WalletsScreen();
      case 1:
        return const TransactionsScreen();
      case 2:
        return const BudgetsScreen();
      case 3:
        return const AnalyticsScreen();
      default:
        return const AuctionSessionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _TopHeader(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  for (var i = 0; i < CustomBottomNavBar.tabs.length; i++)
                    _visited.contains(i)
                        ? _screenFor(i)
                        : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
          _visited.add(index);
        }),
      ),
    );
  }
}

/// Header chung của mọi màn: tên app bên trái, avatar tài khoản bên phải.
/// Bấm avatar mở màn Tài khoản (hồ sơ + đăng xuất).
class _TopHeader extends ConsumerWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final displayName = user?.displayName.trim() ?? '';
    final name = displayName.isNotEmpty ? displayName : (user?.email ?? '');
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.savings_outlined,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          const Text(
            'Expense Tracker',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AccountScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

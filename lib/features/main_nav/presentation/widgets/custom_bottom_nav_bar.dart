import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Một tab của thanh điều hướng dưới.
class NavTab {
  final IconData icon;
  final String label;

  const NavTab(this.icon, this.label);
}

/// Bottom nav của app: nền trắng, viền trên 1px, mỗi tab là icon + nhãn.
/// Tab đang chọn tô xanh `AppColors.primary`, các tab còn lại màu xám.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavTab> tabs = [
    NavTab(Icons.account_balance_wallet_outlined, 'Ví tiền'),
    NavTab(Icons.receipt_long_outlined, 'Giao dịch'),
    NavTab(Icons.pie_chart_outline, 'Ngân sách'),
    NavTab(Icons.bar_chart, 'Báo cáo'),
    NavTab(Icons.gavel, 'Đấu giá'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tabs[i].icon,
                          size: 22,
                          color: i == currentIndex
                              ? AppColors.primary
                              : AppColors.navLabel,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tabs[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: i == currentIndex
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: i == currentIndex
                                ? AppColors.primary
                                : AppColors.navLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

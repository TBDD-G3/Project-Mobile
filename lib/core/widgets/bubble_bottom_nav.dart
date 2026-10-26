import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Mục tab của [BubbleBottomNav].
class BubbleBottomNavItem {
  final IconData icon;
  final String label;

  const BubbleBottomNavItem({required this.icon, required this.label});
}

/// Bottom navigation kiểu Agoda: tab active nằm trong "bong bóng" xám
/// `#EDEDED` với icon + label màu xanh primary; tab inactive chữ đen đậm,
/// icon xám nhạt. Không dùng pill M3 nằm ngang.
class BubbleBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<BubbleBottomNavItem> items;

  const BubbleBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onDestinationSelected(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: i == selectedIndex
                              ? AppColors.navBubble
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              items[i].icon,
                              size: 20,
                              color: i == selectedIndex
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              items[i].label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: i == selectedIndex
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

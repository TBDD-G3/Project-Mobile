import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Tile nền pastel kiểu Agoda: chữ đậm ở góc trên trái,
/// icon lớn tràn ra mép dưới phải.
class PastelTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final Size size;
  final VoidCallback? onTap;

  const PastelTile({
    super.key,
    required this.label,
    required this.icon,
    required this.background,
    this.iconColor = Colors.black38,
    this.size = const Size(160, 110),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppColors.radiusTile),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusTile),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppColors.radiusTile),
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  top: 14,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    icon,
                    size: size.height * 0.62,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Card insight kiểu Agoda: thông điệp ngắn + link hành động màu xanh
/// `#2067DA` (tương ứng card coupon `Up to 18% off ... → Claim`).
class InsightCard extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  const InsightCard({
    super.key,
    required this.message,
    this.actionLabel = 'Xem chi tiết',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pastelSaving,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tips_and_updates,
              size: 22,
              color: Color(0xFFB8860B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: onAction,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

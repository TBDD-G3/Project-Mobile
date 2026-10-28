import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/app_database.dart';
import 'budget_editor_screen.dart';

class BudgetDetailScreen extends StatelessWidget {
  final Category category;
  final int month;
  final int year;
  final double limitAmount;
  final double spentAmount;

  const BudgetDetailScreen({
    super.key,
    required this.category,
    required this.month,
    required this.year,
    required this.limitAmount,
    required this.spentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = spentAmount > limitAmount;
    final percentage = limitAmount <= 0 ? 0.0 : spentAmount / limitAmount * 100;
    final difference = (spentAmount - limitAmount).abs();

    return Scaffold(
      appBar: AppBar(title: const Text('Ngân sách')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            Formatters.formatMonthYear(month, year),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (isOver)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                border: Border.all(color: const Color(0xFFFFD1CC)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.expense, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${category.name} đã vượt hạn mức ${Formatters.formatCurrency(difference)}.',
                      style: const TextStyle(color: AppColors.textPrimary, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.expense.withValues(alpha: 0.1),
                  child: const Icon(Icons.category_outlined, color: AppColors.expense),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        '${Formatters.formatCurrency(spentAmount)} / ${Formatters.formatCurrency(limitAmount)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.round()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isOver ? AppColors.expense : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => BudgetEditorScreen(
                    month: month,
                    year: year,
                    categoryId: category.id,
                    amount: limitAmount,
                  ),
                ),
              );
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Chỉnh sửa hạn mức'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isOver
                ? 'Gợi ý: xem lại các giao dịch thuộc danh mục ${category.name}.'
                : 'Cảnh báo sẽ xuất hiện khi chi tiêu đạt 80% hạn mức.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
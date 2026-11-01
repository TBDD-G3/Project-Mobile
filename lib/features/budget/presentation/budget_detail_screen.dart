import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/firestore/models/budget.dart';
import '../../../data/firestore/models/category.dart';
import '../../category/providers/category_providers.dart';
import '../../transaction/providers/transaction_providers.dart';
import '../data/budget_progress.dart';
import '../providers/budget_providers.dart';
import 'budget_editor_screen.dart';

/// Màn con xem chi tiết một hạn mức, có sửa và xoá.
class BudgetDetailScreen extends ConsumerWidget {
  const BudgetDetailScreen({super.key, required this.budget});

  final Budget budget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arg = (month: budget.month, year: budget.year);
    final budgets = ref.watch(budgetsByMonthProvider(arg)).value;
    final spending = ref.watch(transactionsByCategoryProvider(arg)).value;
    final categories = ref.watch(categoriesStreamProvider).value;

    Budget current = budget;
    for (final item in budgets ?? const <Budget>[]) {
      if (item.id == budget.id) {
        current = item;
        break;
      }
    }
    Category? category;
    for (final item in categories ?? const <Category>[]) {
      if (item.id == current.categoryId) {
        category = item;
        break;
      }
    }

    final progress = BudgetProgress(
      budget: current,
      spent: spending?[current.categoryId] ?? 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Chi tiết ngân sách',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              category?.name ?? 'Danh mục',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tháng ${Formatters.formatMonthYear(current.month, current.year)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _DetailCard(progress: progress),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Sửa hạn mức',
              onPressed: () => showBudgetEditorSheet(
                context,
                ref,
                month: DateTime(current.year, current.month),
                categories: ref.watch(expenseCategoriesProvider).value ??
                    const <Category>[],
                existing: current,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _confirmDelete(context, ref),
                child: const Text(
                  'Xoá hạn mức',
                  style: TextStyle(
                    color: AppColors.expense,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa hạn mức này? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(budgetRepositoryProvider).deleteBudget(budget.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không xoá được hạn mức: $error')),
        );
      }
    }
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final over = progress.isOver;
    const to = TextStyle(fontSize: 13, color: Colors.grey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HẠN MỨC THÁNG',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            Formatters.formatCurrency(progress.limit),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.barValue,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(
                over ? AppColors.expense : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Đã chi ${Formatters.formatCurrency(progress.spent)}',
                  style: to,
                ),
              ),
              Text(
                '${(progress.ratio * 100).round()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: over ? AppColors.expense : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          if (over) ...[
            const SizedBox(height: 12),
            Text(
              'Đã vượt ${Formatters.formatCurrency(-progress.remaining)} so với hạn mức',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.expense,
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              'Còn ${Formatters.formatCurrency(progress.remaining)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

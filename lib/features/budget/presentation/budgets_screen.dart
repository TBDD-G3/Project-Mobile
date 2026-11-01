import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/firestore/models/category.dart';
import '../data/budget_progress.dart';
import '../providers/budget_providers.dart';
import 'budget_detail_screen.dart';
import 'budget_editor_screen.dart';

/// Tab 3 — Ngân sách theo tháng (Câu 6, US13 – US14).
///
/// Shell đã bọc SafeArea + bottom nav; màn này chỉ trả nội dung, không tự
/// dựng Scaffold/AppBar.
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(budgetMonthProvider);
    final arg = (month: month.month, year: month.year);
    final progress = ref.watch(budgetProgressProvider(arg));
    final categories = ref.watch(expenseCategoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Ngân sách',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hạn mức chi tiêu theo tháng',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _MonthSelector(month: month),
          const SizedBox(height: 20),
          progress.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => _ErrorBox(
              message: 'Không tải được ngân sách: $error',
              onRetry: () => ref.invalidate(budgetsByMonthProvider(arg)),
            ),
            data: (list) => _BudgetContent(
              month: month,
              items: list,
              categories: categories,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void shift(int delta) {
      ref.read(budgetMonthProvider.notifier).state = DateTime(
        month.year,
        month.month + delta,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Tháng trước',
          onPressed: () => shift(-1),
          icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
        ),
        Text(
          'Tháng ${Formatters.formatMonthYear(month.month, month.year)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          tooltip: 'Tháng sau',
          onPressed: () => shift(1),
          icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _BudgetContent extends ConsumerWidget {
  const _BudgetContent({
    required this.month,
    required this.items,
    required this.categories,
  });

  final DateTime month;
  final List<BudgetProgress> items;
  final AsyncValue<List<Category>> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = <String, Category>{
      for (final category in categories.value ?? const <Category>[])
        category.id: category,
    };

    final totalLimit = items.fold<double>(0, (sum, item) => sum + item.limit);
    final totalSpent = items.fold<double>(0, (sum, item) => sum + item.spent);
    final over = totalLimit > 0 && totalSpent > totalLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(limit: totalLimit, spent: totalSpent, over: over),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Hạn mức theo danh mục',
          actionLabel: items.isEmpty ? null : 'Đặt thêm',
          onAction: items.isEmpty
              ? null
              : () => showBudgetEditorSheet(
                  context,
                  ref,
                  month: month,
                  categories: byId.values.toList(),
                ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Chưa có ngân sách',
            subtitle:
                'Đặt hạn mức cho một danh mục để theo dõi chi tiêu trong tháng.',
            actionLabel: 'Đặt hạn mức',
            onAction: () => showBudgetEditorSheet(
              context,
              ref,
              month: month,
              categories: byId.values.toList(),
            ),
          )
        else ...[
          for (final item in items)
            _BudgetCard(
              progress: item,
              category: byId[item.budget.categoryId],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BudgetDetailScreen(budget: item.budget),
                ),
              ),
            ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Đặt hạn mức cho danh mục',
            onPressed: () => showBudgetEditorSheet(
              context,
              ref,
              month: month,
              categories: byId.values.toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.limit,
    required this.spent,
    required this.over,
  });

  final double limit;
  final double spent;
  final bool over;

  @override
  Widget build(BuildContext context) {
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
            'TỔNG HẠN MỨC THÁNG NÀY',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            Formatters.formatCurrency(limit),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Đã chi ${Formatters.formatCurrency(spent)}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
              Text(
                over
                    ? 'Vượt ${Formatters.formatCurrency(spent - limit)}'
                    : 'Còn ${Formatters.formatCurrency(limit - spent)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: over ? AppColors.expense : AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.progress,
    required this.category,
    required this.onTap,
  });

  final BudgetProgress progress;
  final Category? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = category?.name ?? 'Danh mục';
    final color = progress.isOver
        ? AppColors.expense
        : (progress.isNear ? const Color(0xFFD97706) : AppColors.primary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppColors.radiusCard),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
          border: Border.all(color: AppColors.surfaceMutedBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  '${(progress.ratio * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.barValue,
                minHeight: 8,
                backgroundColor: AppColors.surfaceMuted,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Đã chi ${Formatters.formatCurrency(progress.spent)}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                Text(
                  progress.isOver
                      ? 'Vượt ${Formatters.formatCurrency(-progress.remaining)}'
                      : 'Còn ${Formatters.formatCurrency(progress.remaining)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: progress.isOver
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: progress.isOver
                        ? AppColors.expense
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.surfaceMutedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.expense),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

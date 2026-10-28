import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/app_database.dart';
import '../providers/budget_providers.dart';
import 'budget_detail_screen.dart';
import 'budget_editor_screen.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final period = (month: _selectedMonth, year: _selectedYear);
    final rowsAsync = ref.watch(budgetRowsProvider(period));
    final summaryAsync = ref.watch(budgetSummaryProvider(period));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Chọn tháng',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: _pickPeriod,
          ),
        ],
      ),
      body: rowsAsync.when(
        data: (rows) {
          final budgetRows = rows.where((row) => row.budgetAmount > 0).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              Text(
                Formatters.formatMonthYear(_selectedMonth, _selectedYear),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              summaryAsync.when(
                data: (summary) {
                  final ratio = summary.totalBudget <= 0
                      ? 0.0
                      : (summary.spentAmount / summary.totalBudget).clamp(0.0, 1.0);
                  final isOverBudget = summary.remainingAmount < 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F3),
                            border: Border.all(color: const Color(0xFFD4D5DA)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ĐÃ CHI / HẠN MỨC',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Text(
                                  Formatters.formatCurrency(summary.spentAmount),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: isOverBudget ? AppColors.expense : AppColors.textPrimary,
                                      ),
                                ),
                                Text(
                                  '/ ${Formatters.formatCurrency(summary.totalBudget)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 8,
                                backgroundColor: AppColors.divider,
                                color: isOverBudget ? AppColors.expense : const Color(0xFF35343A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (budgetRows.any((row) {
                        final spent = summary.categorySpending[row.category.id] ?? 0;
                        return row.budgetAmount > 0 && spent / row.budgetAmount >= 0.8;
                      })) ...[
                        const SizedBox(height: 12),
                        _BudgetAlert(
                          rows: budgetRows,
                          spending: summary.categorySpending,
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => _InlineError(message: 'Không tải được tổng ngân sách: $error'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Theo danh mục',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Text(
                    '${budgetRows.length} hạn mức',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (budgetRows.isEmpty)
                const _EmptyBudgetState()
              else
                ...budgetRows.map((row) {
                  final spentAsync = summaryAsync.valueOrNull;
                  final spent = spentAsync?.categorySpending[row.category.id] ?? 0;
                  final progress = (spent / row.budgetAmount).clamp(0.0, 1.0);
                  final isOver = spent > row.budgetAmount;
                  final isWarning = spent / row.budgetAmount >= 0.8;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _openDetail(
                          category: row.category,
                          amount: row.budgetAmount,
                          spent: spent,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      row.category.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${Formatters.formatCurrency(spent)} / ${Formatters.formatCurrency(row.budgetAmount)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 58,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 7,
                                    backgroundColor: AppColors.divider,
                                    color: isOver
                                        ? AppColors.expense
                                        : isWarning
                                            ? const Color(0xFFD58B17)
                                            : const Color(0xFF35343A),
                                  ),
                                ),
                              ),
                              Icon(
                                isOver ? Icons.warning_amber_rounded : Icons.chevron_right,
                                color: isOver ? AppColors.expense : AppColors.textLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _InlineError(message: 'Không tải được ngân sách: $error'),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: FilledButton.icon(
          onPressed: () => _openEditor(),
          icon: const Icon(Icons.add),
          label: const Text('Tạo hạn mức'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF35343A),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor({String? categoryId, double? amount}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BudgetEditorScreen(
          month: _selectedMonth,
          year: _selectedYear,
          categoryId: categoryId,
          amount: amount,
        ),
      ),
    );
    if (mounted) {
      ref.invalidate(budgetRowsProvider((month: _selectedMonth, year: _selectedYear)));
      ref.invalidate(budgetSummaryProvider((month: _selectedMonth, year: _selectedYear)));
    }
  }

  Future<void> _openDetail({
    required Category category,
    required double amount,
    required double spent,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BudgetDetailScreen(
          category: category,
          month: _selectedMonth,
          year: _selectedYear,
          limitAmount: amount,
          spentAmount: spent,
        ),
      ),
    );
    if (mounted) {
      ref.invalidate(budgetRowsProvider((month: _selectedMonth, year: _selectedYear)));
      ref.invalidate(budgetSummaryProvider((month: _selectedMonth, year: _selectedYear)));
    }
  }

  Future<void> _pickPeriod() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2, 12),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Chọn kỳ ngân sách',
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked.month;
        _selectedYear = picked.year;
      });
    }
  }

}

class _BudgetAlert extends StatelessWidget {
  final List<BudgetRow> rows;
  final Map<String, double> spending;

  const _BudgetAlert({required this.rows, required this.spending});

  @override
  Widget build(BuildContext context) {
    final alerts = rows.where((row) {
      final spent = spending[row.category.id] ?? 0;
      return row.budgetAmount > 0 && spent / row.budgetAmount >= 0.8;
    }).toList();
    final highest = alerts.first;
    final spent = spending[highest.category.id] ?? 0;
    final isOver = spent > highest.budgetAmount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOver ? const Color(0xFFFFF1F0) : const Color(0xFFFFF8E8),
        border: Border.all(color: isOver ? const Color(0xFFFFD1CC) : const Color(0xFFF2D99A)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isOver ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 19,
            color: isOver ? AppColors.expense : const Color(0xFFA66B00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOver
                  ? '${highest.category.name} đã vượt hạn mức ${Formatters.formatCurrency(spent - highest.budgetAmount)}.'
                  : '${highest.category.name} đã sử dụng ${(spent / highest.budgetAmount * 100).round()}% hạn mức.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBudgetState extends StatelessWidget {
  const _EmptyBudgetState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.pie_chart_outline, size: 32, color: AppColors.textLight),
          const SizedBox(height: 10),
          Text(
            'Chưa có hạn mức trong tháng này',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tạo hạn mức để theo dõi chi tiêu theo danh mục.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(message, style: const TextStyle(color: AppColors.expense)),
    );
  }
}
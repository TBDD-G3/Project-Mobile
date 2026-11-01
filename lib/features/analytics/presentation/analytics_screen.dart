import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/firestore/models/category.dart';
import '../../category/providers/category_providers.dart';
import '../../transaction/providers/transaction_providers.dart';
import '../providers/analytics_providers.dart';

/// Các màu dự phòng khi danh mục không khai báo `colorHex`.
const _fallbackColors = <Color>[
  AppColors.primary,
  AppColors.income,
  AppColors.transfer,
  AppColors.expense,
  Color(0xFFD97706),
  Color(0xFF7C3AED),
];

/// Tab 4 — Báo cáo và biểu đồ (Câu 6, US15).
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(analyticsMonthProvider);
    final arg = (month: month.month, year: month.year);
    final totals = ref.watch(monthTotalsProvider(arg));
    final byCategory = ref.watch(transactionsByCategoryProvider(arg));
    final categories = ref.watch(categoriesStreamProvider);
    final sixMonths = ref.watch(sixMonthTotalsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Báo cáo',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thu chi theo tháng',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _MonthSelector(month: month),
          const SizedBox(height: 20),
          totals.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => _ErrorBox(
              message: 'Không tải được báo cáo: $error',
              onRetry: () => ref.invalidate(monthTotalsProvider(arg)),
            ),
            data: (data) => _TotalsCard(totals: data),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Chi tiêu theo danh mục'),
          const SizedBox(height: 12),
          byCategory.when(
            loading: () => const _ChartPlaceholder(),
            error: (error, _) => _ErrorBox(
              message: 'Không tải được dữ liệu: $error',
              onRetry: () => ref.invalidate(transactionsByCategoryProvider(arg)),
            ),
            data: (data) => _CategoryPieCard(
              amounts: data,
              categories: categories.value ?? const <Category>[],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Thu chi 6 tháng'),
          const SizedBox(height: 12),
          sixMonths.when(
            loading: () => const _ChartPlaceholder(),
            error: (error, _) => _ErrorBox(
              message: 'Không tải được dữ liệu: $error',
              onRetry: () => ref.invalidate(sixMonthTotalsProvider),
            ),
            data: (points) => _SixMonthBarCard(points: points),
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
      ref.read(analyticsMonthProvider.notifier).state = DateTime(
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

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totals});

  final MonthTotals totals;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Metric(
            label: 'THU NHẬP',
            value: Formatters.formatCurrency(totals.income),
            color: AppColors.income,
          ),
          _Metric(
            label: 'CHI TIÊU',
            value: Formatters.formatCurrency(totals.expense),
            color: AppColors.expense,
          ),
          _Metric(
            label: 'CHÊNH LỆCH',
            value: Formatters.formatCurrency(totals.balance.abs()),
            color: totals.balance >= 0
                ? AppColors.primaryDark
                : AppColors.expense,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPieCard extends StatelessWidget {
  const _CategoryPieCard({required this.amounts, required this.categories});

  final Map<String, double> amounts;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final entries = amounts.entries.where((entry) => entry.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);

    if (entries.isEmpty || total <= 0) {
      return const EmptyState(
        icon: Icons.pie_chart_outline_rounded,
        title: 'Chưa có chi tiêu',
        subtitle: 'Ghi giao dịch chi trong tháng để xem biểu đồ.',
      );
    }

    final byId = {for (final category in categories) category.id: category};
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      sections.add(
        PieChartSectionData(
          value: entry.value,
          color: _colorOf(byId[entry.key], i),
          radius: 52,
          title: '${(entry.value * 100 / total).round()}%',
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.surfaceMutedBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < entries.length; i++)
            _LegendRow(
              color: _colorOf(byId[entries[i].key], i),
              name: byId[entries[i].key]?.name ?? 'Khác',
              amount: entries[i].value,
            ),
        ],
      ),
    );
  }

  Color _colorOf(Category? category, int index) {
    final hex = category?.colorHex;
    if (hex != null) {
      final parsed = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
      if (parsed != null) return Color(0xFF000000 | parsed);
    }
    return _fallbackColors[index % _fallbackColors.length];
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.name,
    required this.amount,
  });

  final Color color;
  final String name;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _SixMonthBarCard extends StatelessWidget {
  const _SixMonthBarCard({required this.points});

  final List<MonthPoint> points;

  @override
  Widget build(BuildContext context) {
    final hasData = points.any(
      (point) => point.income > 0 || point.expense > 0,
    );
    if (!hasData) {
      return const EmptyState(
        icon: Icons.bar_chart_rounded,
        title: 'Chưa có dữ liệu',
        subtitle: 'Sáu tháng gần nhất chưa có giao dịch nào.',
      );
    }

    var peak = 0.0;
    for (final point in points) {
      if (point.income > peak) peak = point.income;
      if (point.expense > peak) peak = point.expense;
    }
    final maxY = peak <= 0 ? 1.0 : peak * 1.2;
    final interval = maxY / 4;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.surfaceMutedBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Text(
                        _short(value),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'T${points[index].month}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < points.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        BarChartRodData(
                          toY: points[i].income,
                          color: AppColors.income,
                          width: 9,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        BarChartRodData(
                          toY: points[i].expense,
                          color: AppColors.expense,
                          width: 9,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.income, label: 'Thu'),
              SizedBox(width: 16),
              _LegendDot(color: AppColors.expense, label: 'Chi'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
      ),
      child: const CircularProgressIndicator(),
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

String _short(double value) {
  if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}tỷ';
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}tr';
  if (value >= 1000) return '${(value / 1000).round()}k';
  return value.toStringAsFixed(0);
}

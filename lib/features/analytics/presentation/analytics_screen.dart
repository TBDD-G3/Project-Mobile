import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../providers/analytics_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final analyticsAsync = ref.watch(analyticsProvider((month: now.month, year: now.year)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo & Biểu đồ'),
      ),
      body: analyticsAsync.when(
        data: (analytics) {
          final totalSpent = analytics.totalSpent;
          final totalBudget = analytics.totalBudget;
          final chartData = analytics.categoryRows;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Tổng ngân sách',
                      value: Formatters.formatCurrency(totalBudget),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Đã chi',
                      value: Formatters.formatCurrency(totalSpent),
                      color: AppColors.expense,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 220,
                    child: chartData.isEmpty
                        ? const Center(child: Text('Chưa có dữ liệu chi tiêu cho tháng này'))
                        : BarChart(
                            BarChartData(
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: true),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 || index >= chartData.length) {
                                        return const SizedBox();
                                      }
                                      final name = chartData[index].name;
                                      return SideTitleWidget(
                                        meta: meta,
                                        child: Text(name.length > 6 ? '${name.substring(0, 6)}...' : name),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(chartData.length, (index) {
                                final item = chartData[index];
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: item.amount,
                                      color: _colorFromHex(item.colorHex),
                                      width: 18,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: chartData.isEmpty
                      ? const Text('Chưa có dữ liệu biểu đồ tròn.')
                      : SizedBox(
                          height: 240,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 32,
                              sections: List.generate(chartData.length, (index) {
                                final item = chartData[index];
                                return PieChartSectionData(
                                  value: item.amount,
                                  color: _colorFromHex(item.colorHex),
                                  title: item.name,
                                  radius: 70,
                                  titleStyle: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Color _colorFromHex(String value) {
    final hex = value.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return AppColors.primary;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

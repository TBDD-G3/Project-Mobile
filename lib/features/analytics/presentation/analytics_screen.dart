import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/app_database.dart';
import '../providers/analytics_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late DateTime _start;
  late DateTime _endExclusive;
  String? _walletId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month);
    _endExclusive = DateTime(now.year, now.month, now.day + 1);
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(
      analyticsProvider((start: _start, endExclusive: _endExclusive, walletId: _walletId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Lọc báo cáo',
            onPressed: _openFilters,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (report) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              _periodLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openFilters,
              icon: const Icon(Icons.calendar_today_outlined, size: 17),
              label: Text(_filterLabel),
              iconAlignment: IconAlignment.end,
              style: OutlinedButton.styleFrom(
                alignment: Alignment.center,
                foregroundColor: AppColors.textPrimary,
                backgroundColor: Colors.white,
                minimumSize: const Size.fromHeight(42),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    title: 'TỔNG THU',
                    amount: report.totalIncome,
                    color: const Color(0xFF17856B),
                    icon: Icons.south_west,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryTile(
                    title: 'TỔNG CHI',
                    amount: report.totalSpent,
                    color: const Color(0xFFCC514C),
                    icon: Icons.north_east,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeading(title: 'Thu / chi'),
            const SizedBox(height: 10),
            _CashFlowChart(rows: report.cashFlowRows),
            const SizedBox(height: 24),
            const _SectionHeading(title: 'Phân loại chi tiêu'),
            const SizedBox(height: 10),
            _CategoryBreakdown(rows: report.categoryRows),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Không tải được báo cáo: $error', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  String get _periodLabel {
    if (_start.year == _endExclusive.subtract(const Duration(days: 1)).year &&
        _start.month == _endExclusive.subtract(const Duration(days: 1)).month) {
      return Formatters.formatMonthYear(_start.month, _start.year);
    }
    final end = _endExclusive.subtract(const Duration(days: 1));
    return '${Formatters.formatDate(_start)} - ${Formatters.formatDate(end)}';
  }

  String get _filterLabel {
    final now = DateTime.now();
    final isCurrentMonth = _start.year == now.year &&
        _start.month == now.month &&
        _start.day == 1 &&
        _endExclusive == DateTime(now.year, now.month, now.day + 1);
    final period = isCurrentMonth ? 'Tháng này' : 'Tùy chỉnh';
    final wallet = _walletId == null ? 'Tất cả ví' : 'Đã lọc ví';
    return '$period  ·  $wallet';
  }

  Future<void> _openFilters() async {
    final wallets = await ref.read(analyticsWalletsProvider.future);
    if (!mounted) return;
    final result = await showModalBottomSheet<_AnalyticsFilterResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AnalyticsFilterSheet(
        start: _start,
        endExclusive: _endExclusive,
        walletId: _walletId,
        wallets: wallets,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _start = result.start;
        _endExclusive = result.endExclusive;
        _walletId = result.walletId;
      });
    }
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.formatCurrency(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _CashFlowChart extends StatelessWidget {
  final List<CashFlowRow> rows;

  const _CashFlowChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.every((row) => row.income == 0 && row.expense == 0)) {
      return const _ChartFrame(
        height: 190,
        child: Center(child: Text('Chưa có giao dịch trong khoảng thời gian này')),
      );
    }

    final maxValue = rows.fold<double>(
      0,
      (maximum, row) => [maximum, row.income, row.expense].reduce((a, b) => a > b ? a : b),
    );
    final interval = maxValue <= 0 ? 1.0 : maxValue / 4;

    return _ChartFrame(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxValue <= 0 ? 1 : maxValue * 1.18,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                groupsSpace: 12,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE9EAED),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= rows.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            rows[index].label,
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(rows.length, (index) {
                  final row = rows[index];
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY: row.expense,
                        color: const Color(0xFF35343A),
                        width: 10,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      BarChartRodData(
                        toY: row.income,
                        color: const Color(0xFFB9BBC1),
                        width: 10,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(color: Color(0xFF35343A), label: 'Chi'),
              SizedBox(width: 20),
              _ChartLegend(color: Color(0xFFB9BBC1), label: 'Thu'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<CategorySpendRow> rows;

  const _CategoryBreakdown({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const _ChartFrame(
        height: 130,
        child: Center(child: Text('Chưa có dữ liệu chi tiêu theo danh mục')),
      );
    }

    final total = rows.fold<double>(0, (sum, row) => sum + row.amount);
    final colors = rows.map((row) => _colorFromHex(row.colorHex)).toList();

    return _ChartFrame(
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: List.generate(rows.length, (index) {
                        final item = rows[index];
                        return PieChartSectionData(
                          value: item.amount,
                          color: colors[index],
                          title: '',
                          radius: 34,
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Formatters.formatCurrency(total),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Tổng chi', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          ...List.generate(rows.length, (index) {
            final item = rows[index];
            final percent = total == 0 ? 0 : item.amount / total * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: colors[index], shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${percent.round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  Text(
                    Formatters.formatCurrency(item.amount),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChartFrame extends StatelessWidget {
  final Widget child;
  final double? height;

  const _ChartFrame({required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _AnalyticsFilterResult {
  final DateTime start;
  final DateTime endExclusive;
  final String? walletId;

  const _AnalyticsFilterResult({
    required this.start,
    required this.endExclusive,
    required this.walletId,
  });
}

class _AnalyticsFilterSheet extends StatefulWidget {
  final DateTime start;
  final DateTime endExclusive;
  final String? walletId;
  final List<Wallet> wallets;

  const _AnalyticsFilterSheet({
    required this.start,
    required this.endExclusive,
    required this.walletId,
    required this.wallets,
  });

  @override
  State<_AnalyticsFilterSheet> createState() => _AnalyticsFilterSheetState();
}

class _AnalyticsFilterSheetState extends State<_AnalyticsFilterSheet> {
  late DateTime _start;
  late DateTime _endExclusive;
  String? _walletId;

  @override
  void initState() {
    super.initState();
    _start = widget.start;
    _endExclusive = widget.endExclusive;
    _walletId = widget.walletId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Bộ lọc báo cáo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Chọn khoảng thời gian và ví cần xem.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          const _SectionHeading(title: 'Khoảng thời gian'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PresetChip(label: 'Tháng này', selected: _isCurrentMonth, onTap: _selectCurrentMonth),
              _PresetChip(label: 'Tháng trước', selected: false, onTap: _selectPreviousMonth),
              _PresetChip(label: '7 ngày', selected: false, onTap: _selectLastWeek),
              _PresetChip(label: 'Tùy chỉnh', selected: !_isCurrentMonth, onTap: _pickCustomRange),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _DateField(label: 'Từ ngày', date: _start, onTap: () => _pickDate(isStart: true))),
              const SizedBox(width: 10),
              Expanded(
                child: _DateField(
                  label: 'Đến ngày',
                  date: _endExclusive.subtract(const Duration(days: 1)),
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _SectionHeading(title: 'Ví'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            initialValue: _walletId,
            decoration: const InputDecoration(),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Tất cả ví')),
              ...widget.wallets.map(
                (wallet) => DropdownMenuItem<String?>(value: wallet.id, child: Text(wallet.name)),
              ),
            ],
            onChanged: (value) => setState(() => _walletId = value),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _apply,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF35343A),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Áp dụng'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _reset,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: const BorderSide(color: AppColors.textSecondary),
            ),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _start.year == now.year && _start.month == now.month &&
        _endExclusive.year == now.year && _endExclusive.month == now.month && _endExclusive.day == now.day + 1;
  }

  void _selectCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _start = DateTime(now.year, now.month);
      _endExclusive = DateTime(now.year, now.month, now.day + 1);
    });
  }

  void _selectPreviousMonth() {
    final now = DateTime.now();
    setState(() {
      _start = DateTime(now.year, now.month - 1);
      _endExclusive = DateTime(now.year, now.month);
    });
  }

  void _selectLastWeek() {
    final today = DateTime.now();
    setState(() {
      _endExclusive = DateTime(today.year, today.month, today.day + 1);
      _start = _endExclusive.subtract(const Duration(days: 7));
    });
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: _start,
        end: _endExclusive.subtract(const Duration(days: 1)).isBefore(_start)
            ? _start
            : _endExclusive.subtract(const Duration(days: 1)),
      ),
    );
    if (range != null) {
      setState(() {
        _start = range.start;
        _endExclusive = range.end.add(const Duration(days: 1));
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final selected = isStart ? _start : _endExclusive.subtract(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
    );
    if (date == null) return;
    setState(() {
      if (isStart) {
        _start = date;
        if (!_endExclusive.isAfter(_start)) _endExclusive = _start.add(const Duration(days: 1));
      } else {
        _endExclusive = date.add(const Duration(days: 1));
        if (_endExclusive.isBefore(_start)) _start = date;
      }
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      _AnalyticsFilterResult(start: _start, endExclusive: _endExclusive, walletId: _walletId),
    );
  }

  void _reset() {
    _selectCurrentMonth();
    setState(() => _walletId = null);
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(Formatters.formatDate(date)),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFE9E9EB),
      side: BorderSide(color: selected ? const Color(0xFF35343A) : AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

Color _colorFromHex(String value) {
  final hex = value.replaceAll('#', '');
  if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
  return AppColors.primary;
}
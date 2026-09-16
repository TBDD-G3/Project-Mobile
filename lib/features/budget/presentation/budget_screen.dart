import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../providers/budget_providers.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final rowsAsync = ref.watch(budgetRowsProvider((month: _selectedMonth, year: _selectedYear)));
    final summaryAsync = ref.watch(budgetSummaryProvider((month: _selectedMonth, year: _selectedYear)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách theo tháng'),
      ),
      body: rowsAsync.when(
        data: (rows) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn thời gian',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedMonth,
                              items: List.generate(12, (index) => index + 1)
                                  .map((month) => DropdownMenuItem(value: month, child: Text('Tháng $month')))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedMonth = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedYear,
                              items: List.generate(4, (index) => DateTime.now().year - index)
                                  .map((year) => DropdownMenuItem(value: year, child: Text('$year')))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedYear = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              summaryAsync.when(
                data: (summary) => Card(
                  color: AppColors.primary.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tổng ngân sách'),
                            Text(
                              Formatters.formatCurrency(summary.totalBudget),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Còn lại'),
                            Text(
                              Formatters.formatCurrency(summary.remainingAmount),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: summary.remainingAmount >= 0 ? AppColors.primaryDark : AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (err, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hạn mức theo danh mục',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...rows.map((row) {
                final category = row.category;
                final controller = _controllers.putIfAbsent(
                  category.id,
                  () => TextEditingController(text: row.budgetAmount.toStringAsFixed(0)),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _colorFromHex(category.colorHex ?? '#64748B').withOpacity(0.15),
                          child: Icon(
                            IconData(category.iconCode ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
                            color: _colorFromHex(category.colorHex ?? '#64748B'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: controller,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  hintText: 'Nhập hạn mức',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  final parsed = double.tryParse(value) ?? 0;
                                  row.amount = parsed;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final repo = ref.read(budgetRepositoryProvider);
          final rows = await ref.read(budgetRowsProvider((month: _selectedMonth, year: _selectedYear)).future);

          for (final row in rows) {
            final value = double.tryParse(_controllers[row.category.id]?.text ?? '0') ?? 0;
            await repo.upsertBudget(
              categoryId: row.category.id,
              month: _selectedMonth,
              year: _selectedYear,
              limitAmount: value,
            );
          }

          ref.invalidate(budgetRowsProvider((month: _selectedMonth, year: _selectedYear)));
          ref.invalidate(budgetSummaryProvider((month: _selectedMonth, year: _selectedYear)));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã lưu hạn mức ngân sách.')),
            );
          }
        },
        icon: const Icon(Icons.save),
        label: const Text('Lưu ngân sách'),
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

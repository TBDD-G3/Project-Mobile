import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/budget_providers.dart';

class BudgetEditorScreen extends ConsumerStatefulWidget {
  final int month;
  final int year;
  final String? categoryId;
  final double? amount;

  const BudgetEditorScreen({
    super.key,
    required this.month,
    required this.year,
    this.categoryId,
    this.amount,
  });

  @override
  ConsumerState<BudgetEditorScreen> createState() => _BudgetEditorScreenState();
}

class _BudgetEditorScreenState extends ConsumerState<BudgetEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late int _month;
  late int _year;
  String? _categoryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _month = widget.month;
    _year = widget.year;
    _categoryId = widget.categoryId;
    _amountController = TextEditingController(
      text: widget.amount == null ? '' : widget.amount!.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rowsAsync = ref.watch(budgetRowsProvider((month: _month, year: _year)));

    return Scaffold(
      appBar: AppBar(title: const Text('Hạn mức')),
      body: rowsAsync.when(
        data: (rows) {
          final categories = rows.map((row) => row.category).toList();
          final selectedCategory = categories.any((category) => category.id == _categoryId)
              ? _categoryId
              : categories.firstOrNull?.id;
          _categoryId = selectedCategory;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  widget.categoryId == null ? 'Tạo ngân sách danh mục' : 'Chỉnh sửa hạn mức',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Theo dõi chi tiêu và nhận cảnh báo khi gần chạm hạn mức.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                _FieldLabel('Danh mục'),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(hintText: 'Chọn danh mục'),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  validator: (value) => value == null ? 'Chọn một danh mục chi tiêu.' : null,
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: 18),
                _FieldLabel('Hạn mức tháng'),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: 3000000',
                    suffixText: 'VND',
                  ),
                  validator: (value) {
                    final amount = double.tryParse((value ?? '').trim());
                    if (amount == null || amount <= 0) return 'Hạn mức phải lớn hơn 0.';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _FieldLabel('Tháng áp dụng'),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _month,
                        decoration: const InputDecoration(),
                        items: List.generate(12, (index) => index + 1)
                            .map((month) => DropdownMenuItem(value: month, child: Text('Tháng $month')))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _month = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _year,
                        decoration: const InputDecoration(),
                        items: List.generate(7, (index) => DateTime.now().year - 3 + index)
                            .map((year) => DropdownMenuItem(value: year, child: Text('$year')))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _year = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F1F3),
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cảnh báo khi chi tiêu đạt 80% hạn mức.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: categories.isEmpty || _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF35343A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Lưu hạn mức'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: const BorderSide(color: AppColors.textSecondary),
                  ),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Không tải được danh mục: $error')),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text.trim());
      await ref.read(budgetRepositoryProvider).upsertBudget(
            categoryId: _categoryId!,
            month: _month,
            year: _year,
            limitAmount: amount,
          );
      ref.invalidate(budgetRowsProvider((month: _month, year: _year)));
      ref.invalidate(budgetSummaryProvider((month: _month, year: _year)));
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không lưu được hạn mức: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
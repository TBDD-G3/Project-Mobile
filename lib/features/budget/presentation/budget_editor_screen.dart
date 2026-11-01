import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/firestore/models/budget.dart';
import '../../../data/firestore/models/category.dart';
import '../providers/budget_providers.dart';

/// Mở form đặt/sửa hạn mức trong bottom sheet bo góc 16 (mục 4.6d).
Future<void> showBudgetEditorSheet(
  BuildContext context,
  WidgetRef ref, {
  required DateTime month,
  required List<Category> categories,
  Budget? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppColors.radiusSheet),
      ),
    ),
    builder: (_) => _BudgetEditorSheet(
      month: month,
      categories: categories,
      existing: existing,
    ),
  );
}

class _BudgetEditorSheet extends ConsumerStatefulWidget {
  const _BudgetEditorSheet({
    required this.month,
    required this.categories,
    this.existing,
  });

  final DateTime month;
  final List<Category> categories;
  final Budget? existing;

  @override
  ConsumerState<_BudgetEditorSheet> createState() => _BudgetEditorSheetState();
}

class _BudgetEditorSheetState extends ConsumerState<_BudgetEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  String? _categoryId;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.existing?.categoryId ??
        (widget.categories.length == 1 ? widget.categories.first.id : null);
    final limit = widget.existing?.limitAmount;
    _amountController = TextEditingController(
      text: limit == null ? '' : limit.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      _showMessage('Vui lòng chọn danh mục');
      return;
    }

    final amount = double.parse(_amountController.text.replaceAll('.', ''));
    final repository = ref.read(budgetRepositoryProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    setState(() => _saving = true);

    final existing = widget.existing;
    final budget = existing == null
        ? Budget(
            id: const Uuid().v4(),
            userId: uid,
            categoryId: _categoryId!,
            month: widget.month.month,
            year: widget.month.year,
            limitAmount: amount,
          )
        : existing.copyWith(limitAmount: amount);

    try {
      if (existing == null) {
        await repository.insertBudget(budget);
      } else {
        await repository.updateBudget(budget);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Không lưu được ngân sách: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
                Expanded(
                  child: Text(
                    _editing ? 'Sửa hạn mức' : 'Đặt hạn mức',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tháng ${Formatters.formatMonthYear(widget.month.month, widget.month.year)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Danh mục chi',
                border: OutlineInputBorder(),
              ),
              child: widget.categories.isEmpty
                  ? const Text(
                      'Chưa có danh mục chi',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _categoryId,
                        hint: const Text('Chọn danh mục'),
                        items: [
                          for (final category in widget.categories)
                            DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ),
                        ],
                        onChanged: _editing
                            ? null
                            : (value) => setState(() => _categoryId = value),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Hạn mức trong tháng',
                suffixText: 'đ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final parsed = double.tryParse(
                  (value ?? '').trim().replaceAll('.', ''),
                );
                if (parsed == null) return 'Nhập số tiền hợp lệ';
                if (parsed <= 0) return 'Hạn mức phải lớn hơn 0';
                return null;
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _editing ? 'Lưu thay đổi' : 'Lưu hạn mức',
              loading: _saving,
              onPressed: widget.categories.isEmpty ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

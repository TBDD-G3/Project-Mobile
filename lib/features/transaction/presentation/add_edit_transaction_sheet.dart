import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/firestore/models/transaction.dart';
import '../../auth/providers/auth_providers.dart';
import '../../category/providers/category_providers.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../providers/transaction_providers.dart';
import 'transaction_actions.dart';

/// Mở bottom sheet thêm hoặc sửa giao dịch.
Future<void> showAddEditTransactionSheet(
  BuildContext context, {
  Transaction? transaction,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppColors.radiusSheet),
      ),
    ),
    builder: (_) => AddEditTransactionSheet(transaction: transaction),
  );
}

/// Bottom sheet thêm/sửa giao dịch: loại (chi/thu/chuyển), số tiền,
/// danh mục, ví, ngày, ghi chú. Số dư ví tự cập nhật trong repository.
class AddEditTransactionSheet extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionSheet({super.key, this.transaction});

  @override
  ConsumerState<AddEditTransactionSheet> createState() =>
      _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState
    extends ConsumerState<AddEditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _type;
  late DateTime _date;
  String? _walletId;
  String? _toWalletId;
  String? _categoryId;
  bool _saving = false;

  bool get _isTransfer => _type == 'transfer';

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountController = TextEditingController(
      text: tx == null ? '' : tx.amount.toStringAsFixed(0),
    );
    _noteController = TextEditingController(text: tx?.note ?? '');
    _type = tx?.type ?? 'expense';
    _date = tx?.date ?? DateTime.now();
    _walletId = tx?.walletId;
    _toWalletId = tx?.toWalletId;
    _categoryId = tx?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final wallets = ref.watch(walletsStreamProvider).value ?? const [];
    final categories = (ref.watch(categoriesStreamProvider).value ?? const [])
        .where((c) => c.type == _type)
        .toList();

    String? validOrNull(String? id, Iterable<String> ids) =>
        id != null && ids.contains(id) ? id : null;

    final walletIds = wallets.map((w) => w.id).toList();
    final categoryIds = categories.map((c) => c.id).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    isEditing ? 'Sửa giao dịch' : 'Giao dịch mới',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      _typeChip('expense', 'Chi tiêu'),
                      _typeChip('income', 'Thu nhập'),
                      _typeChip('transfer', 'Chuyển khoản'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Số tiền (VNĐ)',
                      hintText: '0',
                    ),
                    validator: _validateAmount,
                  ),
                  const SizedBox(height: 16),
                  if (!_isTransfer) ...[
                    DropdownButtonFormField<String>(
                      key: ValueKey('category-$_type-${categoryIds.length}'),
                      initialValue: validOrNull(_categoryId, categoryIds),
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Danh mục'),
                      items: [
                        for (final c in categories)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (v) => setState(() => _categoryId = v),
                      validator: (v) =>
                          v == null ? 'Vui lòng chọn danh mục' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<String>(
                    key: ValueKey('wallet-${walletIds.length}'),
                    initialValue: validOrNull(_walletId, walletIds),
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: _isTransfer ? 'Từ ví' : 'Ví',
                    ),
                    items: [
                      for (final w in wallets)
                        DropdownMenuItem(value: w.id, child: Text(w.name)),
                    ],
                    onChanged: (v) => setState(() => _walletId = v),
                    validator: (v) => v == null ? 'Vui lòng chọn ví' : null,
                  ),
                  if (_isTransfer) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: ValueKey('to-wallet-${walletIds.length}'),
                      initialValue: validOrNull(_toWalletId, walletIds),
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Đến ví'),
                      items: [
                        for (final w in wallets)
                          DropdownMenuItem(value: w.id, child: Text(w.name)),
                      ],
                      onChanged: (v) => setState(() => _toWalletId = v),
                      validator: (v) {
                        if (v == null) return 'Vui lòng chọn ví nhận';
                        if (v == _walletId) {
                          return 'Ví nhận phải khác ví nguồn';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppColors.radiusButton),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(Formatters.formatDate(_date)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      hintText: 'Không bắt buộc',
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Lưu',
                    loading: _saving,
                    onPressed: _save,
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _saving ? null : _delete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.expense,
                        ),
                        label: const Text(
                          'Xóa giao dịch',
                          style: TextStyle(color: AppColors.expense),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String type, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _type == type,
      onSelected: (_) => setState(() {
        if (_type == type) return;
        _type = type;
        // Danh mục chỉ hợp lệ trong đúng loại thu/chi của nó.
        _categoryId = null;
      }),
    );
  }

  String? _validateAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập số tiền';
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) return 'Số tiền phải lớn hơn 0';
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final repo = ref.read(transactionRepositoryProvider);
    final existing = widget.transaction;
    final userId =
        ref.read(currentUserProvider).value?.id ??
        existing?.userId ??
        'default-user';
    final note = _noteController.text.trim();

    final tx = Transaction(
      id: existing?.id ?? const Uuid().v4(),
      userId: userId,
      walletId: _walletId!,
      categoryId: _isTransfer ? null : _categoryId,
      type: _type,
      amount: double.parse(_amountController.text.trim()),
      date: _date,
      note: note.isEmpty ? null : note,
      toWalletId: _isTransfer ? _toWalletId : null,
    );

    try {
      if (existing == null) {
        await repo.insertTransaction(tx);
      } else {
        await repo.updateTransaction(tx);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không lưu được giao dịch: $e')));
      }
    }
  }

  Future<void> _delete() async {
    final existing = widget.transaction;
    if (existing == null) return;
    final deleted = await confirmAndDeleteTransaction(context, ref, existing);
    if (deleted && mounted) Navigator.pop(context);
  }
}

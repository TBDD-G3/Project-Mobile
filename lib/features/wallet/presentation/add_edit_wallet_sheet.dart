import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/firestore/models/wallet.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/wallet_providers.dart';

/// Bottom sheet thêm/sửa ví: tên ví, loại ví, số dư ban đầu, chọn màu.
/// Có nút X thay cho nút back, nút Lưu full-width ở dưới.
class AddEditWalletSheet extends ConsumerStatefulWidget {
  final Wallet? wallet;

  const AddEditWalletSheet({super.key, this.wallet});

  @override
  ConsumerState<AddEditWalletSheet> createState() => _AddEditWalletSheetState();
}

class _AddEditWalletSheetState extends ConsumerState<AddEditWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late String _selectedType;
  late String _selectedColorHex;
  late int _selectedIconCode;

  final List<Map<String, dynamic>> _walletTypes = [
    {'type': 'cash', 'label': 'Tiền mặt', 'icon': Icons.money},
    {'type': 'bank', 'label': 'Ngân hàng', 'icon': Icons.account_balance},
    {'type': 'ewallet', 'label': 'Ví điện tử', 'icon': Icons.account_balance_wallet},
  ];

  final List<String> _colors = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#9C27B0', // Purple
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#00BCD4', // Cyan
  ];

  @override
  void initState() {
    super.initState();
    final w = widget.wallet;
    _nameController = TextEditingController(text: w?.name ?? '');
    _balanceController = TextEditingController(
      text: w != null ? w.balance.toStringAsFixed(0) : '0',
    );
    _selectedType = w?.type ?? 'cash';
    _selectedColorHex = w?.colorHex ?? '#4CAF50';
    _selectedIconCode = w?.iconCode ?? Icons.account_balance_wallet.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.wallet != null;

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
            // Tay cầm kéo sheet
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
                    isEditing ? 'Sửa thông tin ví' : 'Thêm ví mới',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Đối trọng để title canh giữa
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên ví',
                      hintText: 'Vd: Tiền mặt, Techcombank, MoMo',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Vui lòng nhập tên ví'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  if (!isEditing) ...[
                    TextFormField(
                      controller: _balanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số dư ban đầu (VNĐ)',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return null;
                        final n = double.tryParse(val.replaceAll(',', ''));
                        if (n == null || n < 0) return 'Số dư không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text('Loại ví:',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _walletTypes.map((item) {
                      final isSelected = _selectedType == item['type'];
                      return ChoiceChip(
                        label: Text(item['label']),
                        avatar: Icon(item['icon'] as IconData, size: 18),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedType = item['type'] as String;
                              _selectedIconCode =
                                  (item['icon'] as IconData).codePoint;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  const Text('Màu sắc:',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: _colors.map((hex) {
                      final color = _parseColor(hex);
                      final isSelected = _selectedColorHex == hex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColorHex = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2.5)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  size: 18, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: isEditing ? 'Lưu thay đổi' : 'Tạo ví',
                    onPressed: _saveWallet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Future<void> _saveWallet() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final repo = ref.read(walletRepositoryProvider);
    final userAsync = ref.read(currentUserProvider);
    final userId = userAsync.value?.id ?? 'default-user';

    try {
      if (widget.wallet == null) {
        final initialBalance = double.tryParse(
                _balanceController.text.trim().replaceAll(',', '')) ??
            0.0;
        await repo.insertWallet(
          Wallet(
            id: const Uuid().v4(),
            userId: userId,
            name: name,
            type: _selectedType,
            balance: initialBalance,
            iconCode: _selectedIconCode,
            colorHex: _selectedColorHex,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        await repo.updateWallet(
          widget.wallet!.copyWith(
            name: name,
            type: _selectedType,
            iconCode: _selectedIconCode,
            colorHex: _selectedColorHex,
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu ví: $e')),
        );
      }
    }
  }
}

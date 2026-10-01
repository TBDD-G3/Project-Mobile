import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/wallet_providers.dart';

class AddEditWalletDialog extends ConsumerStatefulWidget {
  final Wallet? wallet;

  const AddEditWalletDialog({super.key, this.wallet});

  @override
  ConsumerState<AddEditWalletDialog> createState() => _AddEditWalletDialogState();
}

class _AddEditWalletDialogState extends ConsumerState<AddEditWalletDialog> {
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

    return AlertDialog(
      title: Text(
        isEditing ? 'Sửa thông tin ví' : 'Thêm ví mới',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên ví
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên ví',
                  hintText: 'Vd: Tiền mặt, Techcombank, MoMo',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Vui lòng nhập tên ví' : null,
              ),
              const SizedBox(height: 16),

              // Số dư ban đầu (chỉ khi tạo mới — số dư cập nhật qua Transaction)
              if (!isEditing) ...[
                TextFormField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số dư ban đầu (VNĐ)',
                    border: OutlineInputBorder(),
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

              // Loại ví
              const Text('Loại ví:', style: TextStyle(fontWeight: FontWeight.w600)),
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
                          _selectedIconCode = (item['icon'] as IconData).codePoint;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Chọn màu
              const Text('Màu sắc:', style: TextStyle(fontWeight: FontWeight.w600)),
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
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _saveWallet,
          child: Text(isEditing ? 'Lưu' : 'Tạo ví'),
        ),
      ],
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

    if (widget.wallet == null) {
      final initialBalance =
          double.tryParse(_balanceController.text.trim().replaceAll(',', '')) ??
              0.0;
      await repo.insertWallet(
        WalletsCompanion.insert(
          id: const Uuid().v4(),
          userId: userId,
          name: name,
          type: _selectedType,
          balance: drift.Value(initialBalance),
          iconCode: drift.Value(_selectedIconCode),
          colorHex: drift.Value(_selectedColorHex),
        ),
      );
    } else {
      await repo.updateWallet(
        WalletsCompanion(
          id: drift.Value(widget.wallet!.id),
          name: drift.Value(name),
          type: drift.Value(_selectedType),
          iconCode: drift.Value(_selectedIconCode),
          colorHex: drift.Value(_selectedColorHex),
        ),
      );
    }

    if (mounted) Navigator.pop(context);
  }
}

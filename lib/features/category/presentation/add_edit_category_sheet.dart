import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/firestore/models/category.dart';
import '../providers/category_providers.dart';
import 'category_visuals.dart';

/// Mở bottom sheet thêm hoặc sửa danh mục.
Future<void> showAddEditCategorySheet(
  BuildContext context, {
  Category? category,
  String initialType = 'expense',
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
    builder: (_) =>
        AddEditCategorySheet(category: category, initialType: initialType),
  );
}

/// Bottom sheet thêm/sửa danh mục: tên, loại thu/chi, icon, màu.
/// Loại danh mục không đổi được sau khi tạo.
class AddEditCategorySheet extends ConsumerStatefulWidget {
  final Category? category;
  final String initialType;

  const AddEditCategorySheet({
    super.key,
    this.category,
    this.initialType = 'expense',
  });

  @override
  ConsumerState<AddEditCategorySheet> createState() =>
      _AddEditCategorySheetState();
}

class _AddEditCategorySheetState extends ConsumerState<AddEditCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _type;
  late int _iconCode;
  late String _colorHex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _type = c?.type ?? widget.initialType;
    _iconCode = c?.iconCode ?? kCategoryIcons.first.codePoint;
    _colorHex = c?.colorHex ?? kCategoryColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

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
                    isEditing ? 'Sửa danh mục' : 'Thêm danh mục mới',
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên danh mục',
                      hintText: 'Vd: Cà phê, Học phí',
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loại:',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Chi tiêu'),
                        selectedColor: AppColors.primarySoft,
                        selected: _type == 'expense',
                        onSelected: isEditing
                            ? null
                            : (_) => setState(() => _type = 'expense'),
                      ),
                      ChoiceChip(
                        label: const Text('Thu nhập'),
                        selectedColor: AppColors.primarySoft,
                        selected: _type == 'income',
                        onSelected: isEditing
                            ? null
                            : (_) => setState(() => _type = 'income'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Biểu tượng:',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kCategoryIcons.map((icon) {
                      final selected = icon.codePoint == _iconCode;
                      return InkWell(
                        borderRadius: BorderRadius.circular(
                          AppColors.radiusButton,
                        ),
                        onTap: () => setState(() => _iconCode = icon.codePoint),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppColors.radiusButton,
                            ),
                            color: selected
                                ? AppColors.primarySoft
                                : AppColors.surfaceMuted,
                            border: selected
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          child: Icon(icon, color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Màu sắc:',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: kCategoryColors.map((hex) {
                      final selected = hex == _colorHex;
                      return GestureDetector(
                        onTap: () => setState(() => _colorHex = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colorFromHex(hex),
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(color: Colors.black, width: 2.5)
                                : null,
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Lưu',
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Vui lòng nhập tên danh mục';

    final existing = ref.read(categoriesStreamProvider).value ?? const [];
    final duplicated = existing.any(
      (c) =>
          c.id != widget.category?.id &&
          c.type == _type &&
          c.name.trim().toLowerCase() == name.toLowerCase(),
    );
    return duplicated ? 'Đã có danh mục này' : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final repo = ref.read(categoryRepositoryProvider);
    final name = _nameController.text.trim();

    try {
      final current = widget.category;
      if (current == null) {
        await repo.insertCategory(
          Category(
            id: const Uuid().v4(),
            name: name,
            type: _type,
            iconCode: _iconCode,
            colorHex: _colorHex,
          ),
        );
      } else {
        await repo.updateCategory(
          current.copyWith(
            name: name,
            iconCode: _iconCode,
            colorHex: _colorHex,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không lưu được danh mục: $e')));
      }
    }
  }
}

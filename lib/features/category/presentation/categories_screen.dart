import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/firestore/models/category.dart';
import '../providers/category_providers.dart';
import 'add_edit_category_sheet.dart';
import 'category_visuals.dart';

/// Màn quản lý danh mục, tách 2 tab Chi tiêu / Thu nhập.
/// Mở từ màn Giao dịch (màn con nên có nút back mặc định).
/// Danh mục mặc định bị khóa vì seeder ghi đè lại mỗi lần khởi động app.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Danh mục',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chi tiêu'),
              Tab(text: 'Thu nhập'),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (innerContext) => FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            icon: const Icon(Icons.add),
            label: const Text(
              'Thêm danh mục',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            onPressed: () {
              final index = DefaultTabController.of(innerContext).index;
              showAddEditCategorySheet(
                innerContext,
                initialType: index == 0 ? 'expense' : 'income',
              );
            },
          ),
        ),
        body: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Không tải được danh mục: $err',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(categoriesStreamProvider),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
          data: (categories) => TabBarView(
            children: [
              _CategoryList(
                type: 'expense',
                categories: categories.where((c) => c.isExpense).toList(),
              ),
              _CategoryList(
                type: 'income',
                categories: categories.where((c) => c.isIncome).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final String type;
  final List<Category> categories;

  const _CategoryList({required this.type, required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        title: type == 'expense'
            ? 'Chưa có danh mục chi tiêu'
            : 'Chưa có danh mục thu nhập',
        subtitle: 'Tạo danh mục để phân loại giao dịch của bạn.',
        actionLabel: 'Thêm danh mục',
        onAction: () => showAddEditCategorySheet(context, initialType: type),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryTile(
          category: category,
          onTap: category.isDefault
              ? null
              : () => showAddEditCategorySheet(context, category: category),
          onDelete: category.isDefault
              ? null
              : () => _confirmDelete(context, ref, category),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(categoryRepositoryProvider).deleteCategory(category.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không xóa được danh mục: $e')));
      }
    }
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _CategoryTile({required this.category, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(category.colorHex);

    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppColors.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppColors.radiusCard),
            border: Border.all(color: AppColors.surfaceMutedBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconForCode(category.iconCode), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (category.isDefault)
                      const Text(
                        'Mặc định',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              if (category.isDefault)
                const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: AppColors.textLight,
                )
              else
                IconButton(
                  tooltip: 'Xóa danh mục',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.expense,
                  ),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

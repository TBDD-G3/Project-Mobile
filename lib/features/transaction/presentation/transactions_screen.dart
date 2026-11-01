import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/firestore/models/category.dart';
import '../../../data/firestore/models/transaction.dart';
import '../../../data/firestore/models/wallet.dart';
import '../../category/presentation/categories_screen.dart';
import '../../category/presentation/category_visuals.dart';
import '../../category/providers/category_providers.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../providers/transaction_filter.dart';
import '../providers/transaction_providers.dart';
import 'add_edit_transaction_sheet.dart';
import 'transaction_actions.dart';

/// Màn giao dịch thu/chi/chuyển khoản (tab 2 của shell).
/// Shell đã bọc SafeArea + bottom nav nên màn này chỉ trả nội dung.
/// Danh sách theo tháng, gom theo ngày, lọc theo loại/ví/danh mục.
/// Thêm/sửa bằng bottom sheet, xóa có hộp thoại xác nhận.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final wallets = ref.watch(walletsStreamProvider).value ?? const <Wallet>[];
    final categories =
        ref.watch(categoriesStreamProvider).value ?? const <Category>[];

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Giao dịch',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Thu · Chi · Chuyển khoản',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Bộ lọc',
                actionLabel: 'Quản lý danh mục',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const CategoriesScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _MonthSwitcher(filter: filter),
              const SizedBox(height: 8),
              _FilterBar(
                filter: filter,
                wallets: wallets,
                categories: categories,
              ),
              const SizedBox(height: 16),
              transactionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => _ErrorView(
                  message: 'Không tải được giao dịch: $err',
                  onRetry: () => ref.invalidate(
                    transactionsByMonthProvider((
                      month: filter.month,
                      year: filter.year,
                    )),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return filter.hasActiveFilters
                        ? EmptyState(
                            icon: Icons.filter_alt_off_outlined,
                            title: 'Không có giao dịch phù hợp',
                            subtitle:
                                'Thử bỏ bớt bộ lọc để xem thêm giao dịch.',
                            actionLabel: 'Xóa bộ lọc',
                            onAction: () =>
                                ref
                                    .read(transactionFilterProvider.notifier)
                                    .state = filter
                                    .cleared(),
                          )
                        : EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'Chưa có giao dịch trong tháng này',
                            subtitle: 'Ghi lại khoản thu chi đầu tiên của bạn.',
                            actionLabel: 'Thêm giao dịch',
                            onAction: () =>
                                showAddEditTransactionSheet(context),
                          );
                  }
                  return _TransactionList(
                    items: items,
                    wallets: wallets,
                    categories: categories,
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            // Tab nào cũng có FAB, bỏ hero tag để khỏi đụng nhau khi chuyển màn.
            heroTag: null,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            icon: const Icon(Icons.add),
            label: const Text(
              'Thêm giao dịch',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            onPressed: () => showAddEditTransactionSheet(context),
          ),
        ),
      ],
    );
  }
}

class _MonthSwitcher extends ConsumerWidget {
  final TransactionFilter filter;

  const _MonthSwitcher({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void shift(int delta) {
      ref.read(transactionFilterProvider.notifier).state = filter.shiftMonth(
        delta,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Tháng trước',
          icon: const Icon(Icons.chevron_left),
          onPressed: () => shift(-1),
        ),
        Text(
          'Tháng ${filter.month}/${filter.year}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        IconButton(
          tooltip: 'Tháng sau',
          icon: const Icon(Icons.chevron_right),
          onPressed: () => shift(1),
        ),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final TransactionFilter filter;
  final List<Wallet> wallets;
  final List<Category> categories;

  const _FilterBar({
    required this.filter,
    required this.wallets,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionFilterProvider.notifier);

    Widget typeChip(String? type, String label) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: filter.type == type,
          selectedColor: AppColors.primarySoft,
          checkmarkColor: AppColors.primaryDark,
          onSelected: (_) => notifier.state = type == null
              ? filter.copyWith(clearType: true)
              : filter.copyWith(type: type),
        ),
      );
    }

    final walletValue = wallets.any((w) => w.id == filter.walletId)
        ? filter.walletId
        : null;
    final categoryValue = categories.any((c) => c.id == filter.categoryId)
        ? filter.categoryId
        : null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          typeChip(null, 'Tất cả'),
          typeChip('income', 'Thu'),
          typeChip('expense', 'Chi'),
          typeChip('transfer', 'Chuyển'),
          _FilterDropdown(
            value: walletValue,
            hint: 'Tất cả ví',
            items: {for (final w in wallets) w.id: w.name},
            onChanged: (id) => notifier.state = id == null
                ? filter.copyWith(clearWallet: true)
                : filter.copyWith(walletId: id),
          ),
          const SizedBox(width: 8),
          _FilterDropdown(
            value: categoryValue,
            hint: 'Tất cả danh mục',
            items: {for (final c in categories) c.id: c.name},
            onChanged: (id) => notifier.state = id == null
                ? filter.copyWith(clearCategory: true)
                : filter.copyWith(categoryId: id),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.radiusButton),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isDense: true,
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(hint)),
            for (final entry in items.entries)
              DropdownMenuItem<String?>(
                value: entry.key,
                child: Text(entry.value),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  final List<Transaction> items;
  final List<Wallet> wallets;
  final List<Category> categories;

  const _TransactionList({
    required this.items,
    required this.wallets,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = groupTransactionsByDay(items);
    final totals = summarize(items);
    final walletNames = {for (final w in wallets) w.id: w.name};
    final categoryById = {for (final c in categories) c.id: c};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(income: totals.income, expense: totals.expense),
        for (final group in groups) ...[
          const SizedBox(height: 24),
          _DayHeader(group: group),
          const SizedBox(height: 12),
          for (final tx in group.items)
            _TransactionCard(
              key: ValueKey('tx-${tx.id}'),
              transaction: tx,
              category: categoryById[tx.categoryId],
              walletName: walletNames[tx.walletId],
              toWalletName: walletNames[tx.toWalletId],
              onEdit: () =>
                  showAddEditTransactionSheet(context, transaction: tx),
              onDelete: () => confirmAndDeleteTransaction(context, ref, tx),
            ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double income;
  final double expense;

  const _SummaryCard({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, Widget value) {
      return Expanded(
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            value,
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.surfaceMutedBorder),
      ),
      child: Row(
        children: [
          cell('Thu', AmountText(amount: income, kind: AmountKind.income)),
          cell('Chi', AmountText(amount: expense, kind: AmountKind.expense)),
          cell(
            'Chênh lệch',
            Text(
              Formatters.formatCurrency(income - expense),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final TransactionDayGroup group;

  const _DayHeader({required this.group});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(group.day).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return Formatters.formatDate(group.day);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _label(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          Formatters.formatCurrency(group.net),
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}

/// Một dòng giao dịch: icon danh mục, tên, ví · ghi chú, số tiền, menu sửa/xóa.
class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final String? walletName;
  final String? toWalletName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    required this.walletName,
    required this.toWalletName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    final (String title, IconData icon, AmountKind kind) = tx.isTransfer
        ? ('Chuyển khoản', Icons.swap_horiz_rounded, AmountKind.transfer)
        : (
            category?.name ?? 'Chưa phân loại',
            iconForCode(category?.iconCode),
            tx.isIncome ? AmountKind.income : AmountKind.expense,
          );

    final walletLine = tx.isTransfer
        ? '${walletName ?? '?'} → ${toWalletName ?? '?'}'
        : (walletName ?? 'Ví đã xóa');
    final note = tx.note;
    final subtitle = (note == null || note.isEmpty)
        ? walletLine
        : '$walletLine · $note';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        child: InkWell(
          onTap: onEdit,
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
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AmountText(amount: tx.amount, kind: kind),
                PopupMenuButton<String>(
                  tooltip: 'Tùy chọn',
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else {
                      onDelete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Sửa')),
                    PopupMenuItem(value: 'delete', child: Text('Xóa')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

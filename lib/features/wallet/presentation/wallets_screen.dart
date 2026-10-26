import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/insight_card.dart';
import '../../../core/widgets/pastel_tile.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/firestore/models/wallet.dart';
import '../../generics_demo/generic_demo_screen.dart';
import '../providers/wallet_providers.dart';
import 'add_edit_wallet_sheet.dart';

/// Màn hình Ví tiền — restyle theo ngôn ngữ thiết kế Agoda:
/// card tổng số dư lớn, lưới hero pastel 2 lớn + 3 nhỏ, rail danh mục,
/// card insight, danh sách ví dạng card hairline, giao dịch hôm nay.
class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsStreamProvider);
    final totalBalanceAsync = ref.watch(totalBalanceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text(
          'Thêm ví',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        onPressed: () => _showAddWalletSheet(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TotalBalanceCard(totalBalanceAsync: totalBalanceAsync),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Tính năng nhanh'),
            const SizedBox(height: 12),
            _buildHeroGrid(),
            const SizedBox(height: 12),
            _buildCategoryRail(),
            const SizedBox(height: 20),
            const InsightCard(
              message:
                  'Bạn đã chi nhiều hơn 18% so với tháng trước. Hãy kiểm tra ngân sách các danh mục.',
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Ví của bạn',
              actionLabel: 'Thêm mới',
              onAction: () => _showAddWalletSheet(context),
            ),
            const SizedBox(height: 12),
            walletsAsync.when(
              data: (wallets) => wallets.isEmpty
                  ? EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Chưa có ví',
                      subtitle: 'Tạo ví đầu tiên để bắt đầu quản lý chi tiêu.',
                      actionLabel: 'Thêm ví',
                      onAction: () => _showAddWalletSheet(context),
                    )
                  : _WalletList(wallets: wallets),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Lỗi tải danh sách ví: $err')),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Giao dịch hôm nay'),
            const SizedBox(height: 12),
            const EmptyState(
              icon: Icons.receipt_long,
              title: 'Chưa có giao dịch hôm nay',
              subtitle:
                  'Tính năng Giao dịch đang được Member 2 phát triển (sẽ hiển thị ở đây).',
            ),
            const SizedBox(height: 24),
            Center(
              child: ActionChip(
                avatar: const Icon(Icons.data_object, size: 18, color: Colors.teal),
                label: const Text(
                  'Generics Demo',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),
                ),
                side: BorderSide(color: Colors.teal.shade200),
                backgroundColor: Colors.teal.shade50,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GenericDemoScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletSheet(BuildContext context, {Wallet? wallet}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppColors.radiusSheet),
        ),
      ),
      builder: (_) => AddEditWalletSheet(wallet: wallet),
    );
  }

  /// Lưới hero kiểu Agoda: 2 card lớn (Thu nhập / Chi tiêu) + 3 card nhỏ.
  Widget _buildHeroGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PastelTile(
                label: 'Thu nhập',
                icon: Icons.trending_up,
                background: AppColors.pastelIncome,
                iconColor: const Color(0xFF7A9A2E),
                size: const Size(double.infinity, 110),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PastelTile(
                label: 'Chi tiêu',
                icon: Icons.trending_down,
                background: AppColors.pastelExpense,
                iconColor: const Color(0xFFC25B5B),
                size: const Size(double.infinity, 110),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PastelTile(
                label: 'Chuyển tiền',
                icon: Icons.swap_horiz,
                background: AppColors.pastelTransfer,
                iconColor: const Color(0xFF8E5BBF),
                size: const Size(double.infinity, 90),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PastelTile(
                label: 'Ngân sách',
                icon: Icons.pie_chart,
                background: AppColors.pastelBudget,
                iconColor: const Color(0xFF3E8EA8),
                size: const Size(double.infinity, 90),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PastelTile(
                label: 'Tiết kiệm',
                icon: Icons.savings,
                background: AppColors.pastelSaving,
                iconColor: const Color(0xFFC29A2E),
                size: const Size(double.infinity, 90),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Rail danh mục thường dùng (tương ứng rail dịch vụ của Agoda).
  Widget _buildCategoryRail() {
    final categories = [
      (Icons.restaurant, 'Ăn uống', AppColors.pastelExpense, const Color(0xFFC25B5B)),
      (Icons.directions_car, 'Đi lại', AppColors.pastelBudget, const Color(0xFF3E8EA8)),
      (Icons.receipt_long, 'Hóa đơn', AppColors.pastelSaving, const Color(0xFFC29A2E)),
      (Icons.shopping_bag, 'Mua sắm', AppColors.pastelTransfer, const Color(0xFF8E5BBF)),
      (Icons.more_horiz, 'Khác', const Color(0xFFF1F5F9), const Color(0xFF64748B)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final (icon, label, bg, fg) in categories)
            Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 22, color: fg),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Card tổng số dư lớn — trung tâm của màn hình Ví tiền.
class _TotalBalanceCard extends StatelessWidget {
  final AsyncValue<double> totalBalanceAsync;

  const _TotalBalanceCard({required this.totalBalanceAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG SỐ DƯ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          totalBalanceAsync.when(
            data: (balance) => Text(
              Formatters.formatCurrency(balance),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            loading: () => const SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, _) => const Text(
              '—',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Số liệu demo tháng này — sẽ nối dữ liệu thật khi Member 2 xong Transaction.
          const Row(
            children: [
              AmountText(amount: 5000000, kind: AmountKind.income, fontSize: 13),
              SizedBox(width: 4),
              Text(
                'thu tháng này',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              SizedBox(width: 16),
              AmountText(amount: 3200000, kind: AmountKind.expense, fontSize: 13),
              SizedBox(width: 4),
              Text(
                'chi tháng này',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletList extends StatelessWidget {
  final List<Wallet> wallets;

  const _WalletList({required this.wallets});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: wallets.map((wallet) => _WalletCard(wallet: wallet)).toList(),
    );
  }
}

class _WalletCard extends ConsumerWidget {
  final Wallet wallet;

  const _WalletCard({required this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _parseColor(wallet.colorHex ?? '#4CAF50');

    final String typeName;
    final IconData iconData;
    switch (wallet.type) {
      case 'bank':
        typeName = 'Ngân hàng';
        iconData = Icons.account_balance;
        break;
      case 'ewallet':
        typeName = 'Ví điện tử';
        iconData = Icons.account_balance_wallet;
        break;
      default:
        typeName = 'Tiền mặt';
        iconData = Icons.money;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  typeName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(wallet.balance),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textLight),
            onSelected: (action) {
              if (action == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppColors.radiusSheet),
                    ),
                  ),
                  builder: (_) => AddEditWalletSheet(wallet: wallet),
                );
              } else if (action == 'delete') {
                _confirmDeleteWallet(context, ref);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Sửa'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteWallet(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa ví'),
        content: Text(
            'Bạn có chắc chắn muốn xóa ví "${wallet.name}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final repo = ref.read(walletRepositoryProvider);
              try {
                await repo.deleteWallet(wallet.id);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa ví: $e')),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}

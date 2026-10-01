import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/app_database.dart';
import '../providers/wallet_providers.dart';
import 'add_edit_wallet_dialog.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsStreamProvider);
    final totalBalanceAsync = ref.watch(totalBalanceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm ví'),
        onPressed: () => _showAddWalletDialog(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Ví tiền',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tổng quan tài sản',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _TotalBalanceBanner(totalBalanceAsync: totalBalanceAsync),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách ví của bạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddWalletDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm mới'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            walletsAsync.when(
              data: (wallets) => wallets.isEmpty
                  ? const _EmptyWalletState()
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
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddEditWalletDialog(),
    );
  }
}

class _TotalBalanceBanner extends StatelessWidget {
  final AsyncValue<double> totalBalanceAsync;

  const _TotalBalanceBanner({required this.totalBalanceAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG SỐ DƯ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          totalBalanceAsync.when(
            data: (balance) => Text(
              Formatters.formatCurrency(balance),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            loading: () => const SizedBox(
              height: 38,
              width: 38,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            error: (err, _) => const Text(
              '—',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWalletState extends StatelessWidget {
  const _EmptyWalletState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 30,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có ví',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo ví đầu tiên để bắt đầu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  typeName,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(wallet.balance),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (action) {
              if (action == 'edit') {
                showDialog(
                  context: context,
                  builder: (_) => AddEditWalletDialog(wallet: wallet),
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
              await repo.deleteWallet(wallet.id);
              if (ctx.mounted) Navigator.pop(ctx);
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

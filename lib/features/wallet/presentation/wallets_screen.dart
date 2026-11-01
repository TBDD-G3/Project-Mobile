import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/firestore/models/wallet.dart';
import '../providers/wallet_providers.dart';
import 'add_edit_wallet_sheet.dart';

/// Màn ví tiền: tổng số dư, danh sách ví và nút tạo ví mới.
class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsStreamProvider);
    final totalBalanceAsync = ref.watch(totalBalanceProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
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
              _TotalBalanceCard(totalBalanceAsync: totalBalanceAsync),
              const SizedBox(height: 36),
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
                error: (err, _) {
                  debugPrint('WALLETS STREAM ERROR: $err');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 36,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Không tải được danh sách ví',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () =>
                              ref.invalidate(walletsStreamProvider),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            heroTag: 'add-wallet',
            onPressed: () => _showAddWalletSheet(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ],
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
}

class _TotalBalanceCard extends StatelessWidget {
  final AsyncValue<double> totalBalanceAsync;

  const _TotalBalanceCard({required this.totalBalanceAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
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
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          totalBalanceAsync.when(
            data: (balance) => Text(
              Formatters.formatCurrency(balance),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            loading: () => const SizedBox(
              height: 38,
              width: 38,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, _) => const Text(
              '—',
              style: TextStyle(
                fontSize: 32,
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
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
          border: Border.all(color: AppColors.surfaceMutedBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 30,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có ví',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo ví đầu tiên để bắt đầu quản lý chi tiêu.',
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
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.surfaceMutedBorder),
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
          'Bạn có chắc chắn muốn xóa ví "${wallet.name}" không? Hành động này không thể hoàn tác.',
        ),
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
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa ví: $e')));
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

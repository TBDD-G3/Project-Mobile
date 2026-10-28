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
      appBar: AppBar(
        title: const Text(
          'Ví & Tài Khoản',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm ví'),
        onPressed: () => _showAddWalletDialog(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Tổng tài sản
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tài sản hiện có',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.visibility,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'VND',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    totalBalanceAsync.when(
                      data: (balance) => Text(
                        Formatters.formatCurrency(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      error: (err, _) => Text(
                        'Lỗi: $err',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tiêu đề danh sách
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

            // Danh sách các ví
            walletsAsync.when(
              data: (wallets) {
                if (wallets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          const Text(
                            'Chưa có ví nào được tạo',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wallets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    return _buildWalletCard(context, ref, wallet);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Lỗi tải danh sách ví: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, WidgetRef ref, Wallet wallet) {
    final color = _parseColor(wallet.colorHex ?? '#4CAF50');
    // ignore: non_const_argument_for_const_parameter
    final iconData = wallet.iconCode != null
        // ignore: non_const_argument_for_const_parameter
        ? IconData(wallet.iconCode!, fontFamily: 'MaterialIcons')
        : Icons.account_balance_wallet;

    String typeName;
    switch (wallet.type) {
      case 'bank':
        typeName = 'Ngân hàng';
        break;
      case 'ewallet':
        typeName = 'Ví điện tử';
        break;
      default:
        typeName = 'Tiền mặt';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(iconData, color: color, size: 26),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                wallet.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeName,
                style: TextStyle(color: Colors.grey[700], fontSize: 11),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            Formatters.formatCurrency(wallet.balance),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: wallet.balance >= 0
                  ? AppColors.primaryDark
                  : AppColors.expense,
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'edit') {
              showDialog(
                context: context,
                builder: (_) => AddEditWalletDialog(wallet: wallet),
              );
            } else if (action == 'delete') {
              _confirmDeleteWallet(context, ref, wallet);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
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
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddEditWalletDialog(),
    );
  }

  void _confirmDeleteWallet(BuildContext context, WidgetRef ref, Wallet wallet) {
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/firestore/models/user.dart';
import '../providers/auth_providers.dart';

/// Màn Tài khoản: hồ sơ người đang đăng nhập và nút đăng xuất.
/// Mở từ avatar ở header của shell (không phải tab dưới bottom nav).
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _profileCard(userAsync),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Phiên đăng nhập'),
            const SizedBox(height: 12),
            _logoutCard(),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Expense Tracker · 2026',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(AsyncValue<AppUser?> userAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.surfaceMutedBorder),
      ),
      child: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Text(
              'Chưa đăng nhập',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            );
          }

          final displayName = user.displayName.trim();
          final name = displayName.isEmpty ? user.email : displayName;
          final initial = name.trim().isEmpty
              ? '?'
              : name.trim().characters.first.toUpperCase();
          final shortId = user.id.length > 12
              ? '${user.id.substring(0, 12)}…'
              : user.id;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              _InfoLine(label: 'Đơn vị tiền tệ', value: user.currencyCode),
              const SizedBox(height: 8),
              _InfoLine(
                label: 'Ngày tạo tài khoản',
                value: Formatters.formatDate(user.createdAt),
              ),
              const SizedBox(height: 8),
              _InfoLine(label: 'Mã người dùng', value: shortId),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Text(
          'Không tải được hồ sơ: $err',
          style: const TextStyle(fontSize: 14, color: AppColors.expense),
        ),
      ),
    );
  }

  Widget _logoutCard() {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        side: const BorderSide(color: AppColors.surfaceMutedBorder),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
        ),
        leading: const Icon(Icons.logout, color: AppColors.expense),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.expense,
          ),
        ),
        subtitle: const Text(
          'Thoát khỏi tài khoản trên thiết bị này',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: _signingOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right, color: AppColors.navLabel),
        onTap: _signingOut ? null : _confirmSignOut,
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text(
          'Bạn sẽ cần đăng nhập lại để xem dữ liệu chi tiêu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _signingOut = true);
    try {
      await ref.read(authServiceProvider).signOut();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        setState(() => _signingOut = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Đăng xuất thất bại: $e')));
      }
    }
  }
}

/// Một dòng nhãn — giá trị trong thẻ hồ sơ.
class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

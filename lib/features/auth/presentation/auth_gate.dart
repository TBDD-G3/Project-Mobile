import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../budget/providers/budget_providers.dart';
import '../../category/providers/category_providers.dart';
import '../../main_nav/presentation/main_nav_screen.dart';
import '../../transaction/providers/transaction_providers.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../providers/auth_providers.dart';
import 'login_screen.dart';

/// Chưa đăng nhập thì hiện màn Đăng nhập, đăng nhập rồi thì vào màn chính.
/// Nghe trạng thái realtime nên không phải tự điều hướng.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Đổi tài khoản (đăng xuất / đăng nhập) thì bỏ cache mọi provider gắn với
    // user. Nếu giữ lại, stream Firestore mở bằng uid cũ đã nhận
    // `permission-denied` lúc đăng xuất sẽ nằm mãi ở trạng thái lỗi, và lần
    // đăng nhập sau sẽ thấy "Không tải được danh sách ví" dù dữ liệu vẫn còn.
    ref.listen(currentUserUidProvider, (previous, next) {
      if (previous == next) return;
      ref.invalidate(walletsStreamProvider);
      ref.invalidate(transactionRepositoryProvider);
      ref.invalidate(categoryRepositoryProvider);
      ref.invalidate(budgetRepositoryProvider);
    });

    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) =>
          user == null ? const LoginScreen() : const MainNavScreen(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const LoginScreen(),
    );
  }
}

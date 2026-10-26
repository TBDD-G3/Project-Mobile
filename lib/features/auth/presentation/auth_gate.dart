import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main_nav/presentation/main_nav_screen.dart';
import '../providers/auth_providers.dart';
import 'login_screen.dart';

/// Chưa đăng nhập thì hiện màn Đăng nhập, đăng nhập rồi thì vào màn chính.
/// Nghe trạng thái realtime nên không phải tự điều hướng.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) =>
          user == null ? const LoginScreen() : const MainNavScreen(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const LoginScreen(),
    );
  }
}

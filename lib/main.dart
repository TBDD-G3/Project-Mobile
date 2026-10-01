import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'features/main_nav/presentation/main_nav_screen.dart';
import 'features/wallet/data/repositories/mock_wallet_repository.dart';
import 'features/wallet/providers/wallet_providers.dart';

// Bật để chạy UI Ví tiền bằng dữ liệu giả lập, không cần DB.
const bool kUseMockData = true;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: kUseMockData
          ? [
              walletRepositoryProvider.overrideWithValue(
                MockWalletRepository.seeded(),
              ),
              databaseInitProvider.overrideWith((ref) async {}),
            ]
          : const [],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavScreen(),
    );
  }
}

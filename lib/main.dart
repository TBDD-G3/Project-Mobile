import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/firebase/firebase_providers.dart';
import 'core/theme/app_theme.dart';
import 'data/firestore/models/user.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/wallet/data/repositories/mock_wallet_repository.dart';
import 'features/wallet/providers/wallet_providers.dart';
import 'firebase_options.dart';

/// Bật để chạy UI bằng dữ liệu giả lập, không cần Firebase.
///
/// Sau khi nhóm tạo Firebase project và chạy `flutterfire configure`,
/// đổi thành `false` để app dùng Firestore + Firebase Auth thật (Câu 7 đề bài).
const bool kUseMockData = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kUseMockData) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    ProviderScope(
      overrides: kUseMockData ? _mockOverrides() : const [],
      child: const MyApp(),
    ),
  );
}

/// Override chế độ mock: ví giả + user giả, không gọi Firebase.
List<Override> _mockOverrides() {
  return [
    walletRepositoryProvider.overrideWithValue(MockWalletRepository.seeded()),
    currentUserProvider.overrideWith(
      (ref) => Stream.value(
        AppUser(
          id: 'mock-user',
          email: 'user@projectmobile.local',
          displayName: 'Người dùng',
          currencyCode: 'VND',
          createdAt: DateTime(2024, 1, 1),
        ),
      ),
    ),
    firebaseSeedProvider.overrideWith((ref) async {}),
  ];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

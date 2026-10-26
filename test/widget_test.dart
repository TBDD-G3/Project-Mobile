import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/core/firebase/firebase_providers.dart';
import 'package:project_mobile/data/firestore/models/user.dart';
import 'package:project_mobile/features/auth/providers/auth_providers.dart';
import 'package:project_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:project_mobile/features/wallet/providers/wallet_providers.dart';
import 'package:project_mobile/main.dart';

void main() {
  testWidgets('App smoke test — chế độ mock hiển thị danh sách ví', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ví tiền'), findsWidgets);
    expect(find.text('TỔNG SỐ DƯ'), findsOneWidget);
    expect(find.text('Tiền mặt'), findsWidgets);
    expect(find.text('Vietcombank'), findsOneWidget);
    expect(find.text('MoMo'), findsOneWidget);
    expect(find.text('Giao dịch'), findsWidgets);
    expect(find.text('Ngân sách'), findsWidgets);
    expect(find.text('Báo cáo'), findsWidgets);
  });
}

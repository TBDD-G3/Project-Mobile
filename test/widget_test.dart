import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/database/app_database.dart';
import 'package:project_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(testDb),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quản Lý Tài Chính'), findsOneWidget);
    expect(find.text('Tổng số dư'), findsOneWidget);

    await testDb.close();
  });
}

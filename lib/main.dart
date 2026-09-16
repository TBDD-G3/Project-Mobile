import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/main_nav/presentation/main_nav_screen.dart';
import 'features/budget/budget.dart' show Budget;
import 'features/analytics/analytics.dart' show Analytics;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ----- Member 3: Hạn mức ngân sách -----
  final myBudget = Budget(
    period: '12/2024',
    categoryName: 'Đi lại',
    limitAmount: 1000000,
    spentAmount: 300000,
  );
  debugPrint(myBudget.getBudget());

  // ----- Member 3: Báo cáo & Biểu đồ -----
  final myAnalytics = Analytics(
    period: '12/2024',
    reportName: 'Báo cáo tháng 12',
    totalIncome: 12000000,
    totalExpense: 8000000,
  );
  debugPrint(myAnalytics.getAnalytics());

  runApp(
    const ProviderScope(
      child: MyApp(),
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
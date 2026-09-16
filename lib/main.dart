import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/main_nav/presentation/main_nav_screen.dart';
import 'expense.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      //home: const MainNavScreen(),
      home: const ExpenseTestScreen(),
    );
  }
}

class ExpenseTestScreen extends StatefulWidget {
  const ExpenseTestScreen({super.key});

  @override
  State<ExpenseTestScreen> createState() => _ExpenseTestScreenState();
}

class _ExpenseTestScreenState extends State<ExpenseTestScreen> {
  final Expense _item = Expense(
    title: 'Mua giáo trình môn học',
    amount: 120000,
    category: 'Học tập',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực hành: Lớp Expense'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _item.getExpenseDetails(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thời gian: ${_item.date.toString().substring(0, 16)}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _item.updateAmount(_item.amount + 20000);
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Thử nghiệm gọi updateAmount (+20.000 đ)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

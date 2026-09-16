import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/main_nav/presentation/main_nav_screen.dart';
import 'my_profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final profile = MyProfile(
    date: '24/12/2024',
    workOfPlace: 'Đại học Phenikaa',
    jobTitle: 'Giảng viên',
  );

  print(profile.getProfileSummary());

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

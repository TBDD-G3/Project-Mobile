import 'package:flutter/material.dart';

import '../../entities/Genericclass.dart';
import '../../entities/project_models.dart';
import '../../expense.dart';

/// Màn hình minh họa kết quả Generics Output (tương tự bài học DART: Class - Interface - Inheritance)
class GenericDemoScreen extends StatefulWidget {
  const GenericDemoScreen({super.key});

  @override
  State<GenericDemoScreen> createState() => _GenericDemoScreenState();
}

class _GenericDemoScreenState extends State<GenericDemoScreen> {
  // Khởi tạo các đối tượng kế thừa từ Genericclass<Object>
  late final Expense expenseItem;
  late final WalletModel walletItem;

  // Sử dụng GenericEntityManager để quản lý danh sách tổng quát hóa
  final GenericEntityManager<Genericclass<Object>> manager =
      GenericEntityManager<Genericclass<Object>>();

  @override
  void initState() {
    super.initState();

    // 1. Đối tượng Expense từ bài tập thực hành
    expenseItem = Expense(
      id: 101,
      title: 'Mua giáo trình Flutter & Dart',
      description: 'Chi phí mua tài liệu học tập Phenikaa',
      amount: 150000,
      category: 'Học tập',
    );

    // 2. Đối tượng WalletModel của bài tập lớn (Leader)
    walletItem = WalletModel(
      id: 'W-01',
      name: 'Ví tiền mặt chính',
      description: 'Tiền mặt chi tiêu hàng ngày',
      balance: 2500000,
      walletType: 'Tiền mặt',
      isDefault: true,
    );
    // Thêm tất cả vào Generic Manager để chứng minh tính tổng quát hóa
    manager.addAll([expenseItem, walletItem]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generics & Inheritance Demo'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner giới thiệu
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Text(
                'Mô hình hóa với Genericclass<T> và kế thừa Genericclass<Object>.\n'
                'Áp dụng Class class & Object class để tổng quát hóa mã nguồn.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: Expense (Bài tập thực hành)
            _buildSectionCard(
              title: '1. Expense (Bài tập thực hành)',
              color: Colors.indigo,
              icon: Icons.receipt_long,
              contentLines: [
                'Expense ID: ${expenseItem.getId()}',
                'Expense Name: ${expenseItem.getName()}',
                'Description: ${expenseItem.getDescription()}',
                'Amount: ${expenseItem.getFormattedAmount()}',
                'Category: ${expenseItem.category}',
              ],
            ),
            const SizedBox(height: 12),

            // Card 2: WalletModel (Bài tập lớn - Leader)
            _buildSectionCard(
              title: '2. WalletModel (Bài tập lớn - Leader)',
              color: Colors.green,
              icon: Icons.account_balance_wallet,
              contentLines: [
                'Wallet ID: ${walletItem.getId()}',
                'Wallet Name: ${walletItem.getName()}',
                'Description: ${walletItem.getDescription()}',
                'Số dư: ${walletItem.getFormattedBalance()}',
                'Loại ví: ${walletItem.walletType}',
              ],
            ),
            const SizedBox(height: 16),

            // Card 3: Duyệt danh sách qua Generic Manager (Expense & WalletModel)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.hub, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Tổng quát hóa qua GenericEntityManager',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    ...manager.summarizeAll().map(
                      (text) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          '• $text',
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color color,
    required IconData icon,
    required List<String> contentLines,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            ...contentLines.map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(line, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

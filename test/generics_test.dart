import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/entities/Genericclass.dart';
import 'package:project_mobile/entities/project_models.dart';
import 'package:project_mobile/expense.dart';

void main() {
  group('Generics & Inheritance Tests (Phenikaa Mobile Project)', () {
    test('Genericclass<T> getter and setter work as expected', () {
      final item = Genericclass<String>(
        id: 'G01',
        name: 'Item chung',
        description: 'Mô tả chung',
      );

      expect(item.getId(), 'G01');
      expect(item.getName(), 'Item chung');
      expect(item.getDescription(), 'Mô tả chung');

      item.setId('G02');
      item.setName('Item mới');
      item.setDescription('Mô tả mới');

      expect(item.getId(), 'G02');
      expect(item.getName(), 'Item mới');
      expect(item.getDescription(), 'Mô tả mới');
    });

    test('Expense extends Genericclass<Object> correctly', () {
      final expense = Expense(
        id: 1,
        title: 'Mua sách Flutter',
        description: 'Sách học kỳ 1',
        amount: 150000,
        category: 'Học tập',
      );

      expect(expense.getId(), 1);
      expect(expense.getName(), 'Mua sách Flutter');
      expect(expense.title, 'Mua sách Flutter');
      expect(expense.getDescription(), 'Sách học kỳ 1');
      expect(expense.getFormattedAmount(), '150000 đ');

      expense.updateAmount(180000);
      expect(expense.amount, 180000);
    });

    test('WalletModel, CategoryModel and BudgetModel inherit from Genericclass<Object>', () {
      final wallet = WalletModel(
        id: 'W01',
        name: 'Ví tiền mặt',
        description: 'Tiêu vặt',
        balance: 500000,
      );
      final category = CategoryModel(
        id: 'C01',
        name: 'Ăn uống',
        description: 'Tiền ăn hàng ngày',
        type: 'expense',
      );
      final budget = BudgetModel(
        id: 101,
        name: 'Ngân sách tháng 10',
        description: 'Chi tiêu tháng 10',
        limitAmount: 2000000,
        spentAmount: 500000,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
      );

      expect(wallet.getId(), 'W01');
      expect(wallet.getName(), 'Ví tiền mặt');
      expect(wallet.getFormattedBalance(), '500000 đ');

      expect(category.getId(), 'C01');
      expect(category.isExpense, isTrue);

      expect(budget.getId(), 101);
      expect(budget.remainingAmount, 1500000);
      expect(budget.percentageUsed, 25.0);
    });

    test('GenericEntityManager manages polymorphically across all Genericclass<Object>', () {
      final manager = GenericEntityManager<Genericclass<Object>>();

      final expense = Expense(
        id: 1,
        title: 'Khoản chi 1',
        amount: 50000,
      );
      final wallet = WalletModel(
        id: 'W01',
        name: 'Ví Techcombank',
        description: 'Ví online',
        balance: 1000000,
      );

      manager.addAll([expense, wallet]);

      expect(manager.getAll().length, 2);
      expect(manager.findById(1)?.getName(), 'Khoản chi 1');
      expect(manager.findById('W01')?.getName(), 'Ví Techcombank');

      final summary = manager.summarizeAll();
      expect(summary.length, 2);
      expect(summary[0], contains('[Expense]'));
      expect(summary[1], contains('[WalletModel]'));
    });
  });
}

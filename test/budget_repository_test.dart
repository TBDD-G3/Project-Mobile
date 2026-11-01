import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobile/data/firestore/models/budget.dart';
import 'package:project_mobile/features/budget/data/budget_progress.dart';

void main() {
  group('Budget ORM (Document ↔ Model)', () {
    test('toDocument/fromDocument round-trip giữ nguyên mọi trường', () {
      const budget = Budget(
        id: 'budget-1',
        userId: 'user-1',
        categoryId: 'category-1',
        month: 10,
        year: 2026,
        limitAmount: 3000000,
      );

      final restored = Budget.fromDocument('budget-1', budget.toDocument());

      expect(restored.id, 'budget-1');
      expect(restored.userId, 'user-1');
      expect(restored.categoryId, 'category-1');
      expect(restored.month, 10);
      expect(restored.year, 2026);
      expect(restored.limitAmount, 3000000);
    });

    test('fromDocument xử lý document thiếu trường bằng giá trị mặc định', () {
      final budget = Budget.fromDocument('budget-2', const {});

      expect(budget.id, 'budget-2');
      expect(budget.userId, '');
      expect(budget.categoryId, '');
      expect(budget.limitAmount, 0);
      expect(budget.month, inInclusiveRange(1, 12));
    });

    test('copyWith chỉ đổi hạn mức, giữ nguyên phần còn lại', () {
      const budget = Budget(
        id: 'budget-3',
        userId: 'user-1',
        categoryId: 'category-1',
        month: 9,
        year: 2026,
        limitAmount: 1000000,
      );

      final updated = budget.copyWith(limitAmount: 2500000);

      expect(updated.limitAmount, 2500000);
      expect(updated.id, budget.id);
      expect(updated.categoryId, budget.categoryId);
      expect(updated.month, budget.month);
      expect(updated.year, budget.year);
    });
  });

  group('BudgetProgress — tính tiến độ ngân sách', () {
    const budget = Budget(
      id: 'budget-4',
      userId: 'user-1',
      categoryId: 'category-1',
      month: 10,
      year: 2026,
      limitAmount: 3000000,
    );

    test('dưới 80% là mức bình thường', () {
      const progress = BudgetProgress(budget: budget, spent: 1200000);

      expect(progress.ratio, closeTo(0.4, 0.0001));
      expect(progress.barValue, closeTo(0.4, 0.0001));
      expect(progress.isOver, isFalse);
      expect(progress.isNear, isFalse);
      expect(progress.remaining, 1800000);
      expect(progress.level, 'ok');
    });

    test('từ 80% đến 100% là mức sắp chạm hạn mức', () {
      const progress = BudgetProgress(budget: budget, spent: 2700000);

      expect(progress.ratio, closeTo(0.9, 0.0001));
      expect(progress.isNear, isTrue);
      expect(progress.isOver, isFalse);
      expect(progress.level, 'near');
    });

    test('vượt hạn mức: thanh chặn ở 1.0, còn lại là số âm', () {
      const progress = BudgetProgress(budget: budget, spent: 3600000);

      expect(progress.ratio, closeTo(1.2, 0.0001));
      expect(progress.barValue, 1.0);
      expect(progress.isOver, isTrue);
      expect(progress.level, 'over');
      expect(progress.remaining, -600000);
    });

    test('hạn mức 0 không chia cho 0', () {
      const zero = Budget(
        id: 'budget-5',
        categoryId: 'category-1',
        month: 10,
        year: 2026,
        limitAmount: 0,
      );
      const progress = BudgetProgress(budget: zero, spent: 500000);

      expect(progress.ratio, 0);
      expect(progress.barValue, 0);
      expect(progress.isOver, isFalse);
    });

    test('buildBudgetProgress ghép đúng số đã chi theo danh mục', () {
      const budgets = [
        Budget(
          id: 'b1',
          categoryId: 'food',
          month: 10,
          year: 2026,
          limitAmount: 3000000,
        ),
        Budget(
          id: 'b2',
          categoryId: 'travel',
          month: 10,
          year: 2026,
          limitAmount: 1500000,
        ),
      ];

      final result = buildBudgetProgress(budgets, const {'food': 3600000});

      expect(result, hasLength(2));
      expect(result[0].spent, 3600000);
      expect(result[0].isOver, isTrue);
      expect(result[1].spent, 0);
      expect(result[1].isOver, isFalse);
    });
  });
}

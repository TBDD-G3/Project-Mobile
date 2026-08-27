import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';

class InitialSeeder {
  static Future<void> seedDefaultData(AppDatabase db) async {
    const uuid = Uuid();

    // 1. Kiểm tra và tạo User mặc định nếu chưa có
    final users = await db.select(db.users).get();
    late String defaultUserId;
    if (users.isEmpty) {
      defaultUserId = uuid.v4();
      await db.into(db.users).insert(
            UsersCompanion.insert(
              id: defaultUserId,
              email: 'user@projectmobile.local',
              displayName: const Value('Người dùng'),
              currencyCode: const Value('VND'),
            ),
          );
    } else {
      defaultUserId = users.first.id;
    }

    // 2. Kiểm tra và tạo Ví mặc định nếu chưa có
    final wallets = await db.select(db.wallets).get();
    if (wallets.isEmpty) {
      await db.into(db.wallets).insert(
            WalletsCompanion.insert(
              id: uuid.v4(),
              userId: defaultUserId,
              name: 'Tiền mặt',
              type: 'cash',
              balance: const Value(0.0),
              iconCode: Value(Icons.money.codePoint),
              colorHex: const Value('#4CAF50'),
            ),
          );
      await db.into(db.wallets).insert(
            WalletsCompanion.insert(
              id: uuid.v4(),
              userId: defaultUserId,
              name: 'Tài khoản Ngân hàng',
              type: 'bank',
              balance: const Value(0.0),
              iconCode: Value(Icons.account_balance.codePoint),
              colorHex: const Value('#2196F3'),
            ),
          );
    }

    // 3. Kiểm tra và seed các Category mặc định (Chi tiêu & Thu nhập)
    final categories = await db.select(db.categories).get();
    if (categories.isEmpty) {
      // Chi tiêu (Expense)
      final defaultExpenses = [
        {'name': 'Ăn uống', 'icon': Icons.restaurant.codePoint, 'color': '#FF5722'},
        {'name': 'Mua sắm', 'icon': Icons.shopping_bag.codePoint, 'color': '#E91E63'},
        {'name': 'Di chuyển', 'icon': Icons.directions_car.codePoint, 'color': '#3F51B5'},
        {'name': 'Hóa đơn & Tiện ích', 'icon': Icons.receipt_long.codePoint, 'color': '#FF9800'},
        {'name': 'Giải trí', 'icon': Icons.movie.codePoint, 'color': '#9C27B0'},
        {'name': 'Sức khỏe', 'icon': Icons.medical_services.codePoint, 'color': '#00BCD4'},
        {'name': 'Giáo dục', 'icon': Icons.school.codePoint, 'color': '#4CAF50'},
        {'name': 'Khác', 'icon': Icons.more_horiz.codePoint, 'color': '#607D8B'},
      ];

      for (final cat in defaultExpenses) {
        await db.into(db.categories).insert(
              CategoriesCompanion.insert(
                id: uuid.v4(),
                name: cat['name'] as String,
                type: 'expense',
                iconCode: Value(cat['icon'] as int),
                colorHex: Value(cat['color'] as String),
                isDefault: const Value(true),
              ),
            );
      }

      // Thu nhập (Income)
      final defaultIncomes = [
        {'name': 'Tiền lương', 'icon': Icons.payments.codePoint, 'color': '#4CAF50'},
        {'name': 'Thưởng', 'icon': Icons.card_giftcard.codePoint, 'color': '#FFC107'},
        {'name': 'Đầu tư', 'icon': Icons.trending_up.codePoint, 'color': '#009688'},
        {'name': 'Thu nhập phụ', 'icon': Icons.work.codePoint, 'color': '#03A9F4'},
        {'name': 'Khác', 'icon': Icons.more_horiz.codePoint, 'color': '#607D8B'},
      ];

      for (final cat in defaultIncomes) {
        await db.into(db.categories).insert(
              CategoriesCompanion.insert(
                id: uuid.v4(),
                name: cat['name'] as String,
                type: 'income',
                iconCode: Value(cat['icon'] as int),
                colorHex: Value(cat['color'] as String),
                isDefault: const Value(true),
              ),
            );
      }
    }
  }
}

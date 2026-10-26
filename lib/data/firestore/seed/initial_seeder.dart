import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../firestore_collections.dart';
import '../models/category.dart';

/// Seeder dữ liệu mặc định lên Firestore.
///
/// Idempotent: dùng id cố định cho các danh mục mặc định nên gọi nhiều lần
/// không tạo dữ liệu trùng.
class InitialSeeder {
  static Future<void> seedDefaultData(FirebaseFirestore db) async {
    // Danh mục chi tiêu (Expense)
    final defaultExpenses = <Category>[
      Category(
        id: 'cat-exp-an-uong',
        name: 'Ăn uống',
        type: 'expense',
        iconCode: Icons.restaurant.codePoint,
        colorHex: '#FF5722',
        isDefault: true,
      ),
      Category(
        id: 'cat-exp-mua-sam',
        name: 'Mua sắm',
        type: 'expense',
        iconCode: Icons.shopping_bag.codePoint,
        colorHex: '#E91E63',
        isDefault: true,
      ),
      Category(
        id: 'cat-exp-di-chuyen',
        name: 'Di chuyển',
        type: 'expense',
        iconCode: Icons.directions_car.codePoint,
        colorHex: '#3F51B5',
        isDefault: true,
      ),
      Category(
        id: 'cat-exp-hoa-don',
        name: 'Hóa đơn & Tiện ích',
        type: 'expense',
        iconCode: Icons.receipt_long.codePoint,
        colorHex: '#FF9800',
        isDefault: true,
      ),
      Category(
        id: 'cat-exp-giai-tri',
        name: 'Giải trí',
        type: 'expense',
        iconCode: Icons.movie.codePoint,
        colorHex: '#9C27B0',
        isDefault: true,
      ),
      Category(
        id: 'cat-exp-suc-khoe',
        name: 'Sức khỏe',
        type: 'expense',
        iconCode: Icons.medical_services.codePoint,
        colorHex: '#00BCD4',
        isDefault: true,
      ),
      Category(
        id: 'cat-exp-giao-duc',
        name: 'Giáo dục',
        type: 'expense',
        iconCode: Icons.school.codePoint,
        colorHex: '#4CAF50',
        isDefault: true,
      ),
      Category(
        id: 'cat-exp-khac',
        name: 'Khác',
        type: 'expense',
        iconCode: Icons.more_horiz.codePoint,
        colorHex: '#607D8B',
        isDefault: true,
      ),
    ];

    // Danh mục thu nhập (Income)
    final defaultIncomes = <Category>[
      Category(
        id: 'cat-inc-luong',
        name: 'Tiền lương',
        type: 'income',
        iconCode: Icons.payments.codePoint,
        colorHex: '#4CAF50',
        isDefault: true,
      ),
      Category(
        id: 'cat-inc-thuong',
        name: 'Thưởng',
        type: 'income',
        iconCode: Icons.card_giftcard.codePoint,
        colorHex: '#FFC107',
        isDefault: true,
      ),
      Category(
        id: 'cat-inc-dau-tu',
        name: 'Đầu tư',
        type: 'income',
        iconCode: Icons.trending_up.codePoint,
        colorHex: '#009688',
        isDefault: true,
      ),
      Category(
        id: 'cat-inc-phu',
        name: 'Thu nhập phụ',
        type: 'income',
        iconCode: Icons.work.codePoint,
        colorHex: '#03A9F4',
        isDefault: true,
      ),
      Category(
        id: 'cat-inc-khac',
        name: 'Khác',
        type: 'income',
        iconCode: Icons.more_horiz.codePoint,
        colorHex: '#607D8B',
        isDefault: true,
      ),
    ];

    final categories = [...defaultExpenses, ...defaultIncomes];
    final collection = categoriesCollection(db);
    for (final category in categories) {
      await collection.doc(category.id).set(category);
    }
  }
}

import 'package:flutter/material.dart';

/// Bộ icon cho danh mục. Dùng danh sách hằng thay cho `IconData(code)` để
/// build release vẫn tree-shake được font icon. Gồm cả icon của 13 danh mục
/// mặc định do seeder tạo.
const List<IconData> kCategoryIcons = <IconData>[
  Icons.restaurant,
  Icons.shopping_bag,
  Icons.directions_car,
  Icons.receipt_long,
  Icons.movie,
  Icons.medical_services,
  Icons.school,
  Icons.payments,
  Icons.card_giftcard,
  Icons.trending_up,
  Icons.work,
  Icons.more_horiz,
  Icons.home,
  Icons.flight,
  Icons.pets,
  Icons.sports_esports,
  Icons.fitness_center,
  Icons.coffee,
  Icons.local_grocery_store,
  Icons.phone_android,
  Icons.savings,
  Icons.child_care,
  Icons.checkroom,
  Icons.local_gas_station,
];

/// Bảng màu để chọn khi tạo danh mục.
const List<String> kCategoryColors = <String>[
  '#FF5722',
  '#E91E63',
  '#9C27B0',
  '#3F51B5',
  '#2196F3',
  '#00BCD4',
  '#009688',
  '#4CAF50',
  '#FFC107',
  '#607D8B',
];

/// Tìm icon theo codepoint lưu trong Firestore, không thấy thì trả icon mặc định.
IconData iconForCode(int? code) {
  if (code != null) {
    for (final icon in kCategoryIcons) {
      if (icon.codePoint == code) return icon;
    }
  }
  return Icons.category_outlined;
}

/// Đổi `'#RRGGBB'` thành [Color]; sai định dạng hoặc null thì trả màu xám.
Color colorFromHex(String? hex) {
  const fallback = Color(0xFF607D8B);
  if (hex == null) return fallback;
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return fallback;
  final value = int.tryParse('FF$cleaned', radix: 16);
  return value == null ? fallback : Color(value);
}

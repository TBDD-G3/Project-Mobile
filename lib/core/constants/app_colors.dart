import 'package:flutter/material.dart';

/// Bảng màu theo thiết kế Agoda, lấy từ ảnh mẫu của nhóm.
class AppColors {
  AppColors._();

  // Màu thương hiệu
  static const Color primary = Color(0xFF3F82EF); // xanh Agoda
  static const Color primaryDark = Color(0xFF2067DA);
  static const Color primaryLight = Color(0xFFBBD5FA);
  static const Color primaryLink = Color(0xFF2067DA); // link/CTA
  static const Color accent = Color(0xFF00B0FF);

  // Nền & chữ
  static const Color background = Colors.white; // nền trắng tuyệt đối
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF191919); // charcoal
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Màu số tiền (chỉ dùng trên nền trắng cho dễ đọc)
  static const Color income = Color(0xFF10B981); // emerald
  static const Color expense = Color(0xFFEF4444); // red
  static const Color transfer = Color(0xFF3B82F6); // blue

  // Viền & nền phụ
  static const Color hairline = Color(0xFFEDEEEF); // viền card 1px thay shadow
  static const Color border = Color(0xFFEDEEEF);
  static const Color divider = Color(0xFFF1F5F9);

  // Badge & chip
  static const Color badge = Color(0xFFC53829); // badge đỏ
  static const Color mintChip = Color(0xFFE2F2E5); // chip số dư trên appbar
  static const Color mintChipIcon = Color(0xFF00622F);
  static const Color navBubble = Color(0xFFEDEDED); // bong bóng tab active

  // Pastel tiles kiểu Agoda
  static const Color pastelIncome = Color(0xFFEDFBD0); // thu nhập
  static const Color pastelExpense = Color(0xFFFFDFDF); // chi tiêu
  static const Color pastelTransfer = Color(0xFFF1DFFF); // chuyển tiền
  static const Color pastelBudget = Color(0xFFDFF7FF); // ngân sách
  static const Color pastelSaving = Color(0xFFFBF3D5); // tiết kiệm

  // Bo góc
  static const double radiusTile = 24;
  static const double radiusCard = 16;
  static const double radiusChip = 10;
  static const double radiusSheet = 24;
  static const double radiusButton = 12;
}

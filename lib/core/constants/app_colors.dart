import 'package:flutter/material.dart';

/// Bảng màu xanh lá của app — lấy lại từ các commit đầu tiên của nhóm.
class AppColors {
  AppColors._();

  // Màu thương hiệu
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primarySoft = Color(0xFFE8F5E9);
  static const Color accent = Color(0xFF00B0FF);

  // Nền & chữ
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color surfaceMuted = Color(0xFFF0F1F4);
  static const Color surfaceMutedBorder = Color(0xFFD1D5DB);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color navLabel = Color(0xFF9E9E9E);

  // Màu số tiền
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);
  static const Color transfer = Color(0xFF3B82F6);

  // Viền & nền phụ
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Bo góc
  static const double radiusCard = 12;
  static const double radiusSheet = 16;
  static const double radiusButton = 10;
}

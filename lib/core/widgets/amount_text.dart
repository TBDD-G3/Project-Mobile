import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/formatters.dart';

/// Kiểu số tiền, quyết định dấu và màu.
enum AmountKind { income, expense, transfer }

/// Hiện số tiền kèm dấu +/− và màu theo loại.
/// Nhớ đặt trên nền trắng, đừng đặt lên nền pastel.
class AmountText extends StatelessWidget {
  final double amount;
  final AmountKind kind;
  final double fontSize;

  const AmountText({
    super.key,
    required this.amount,
    required this.kind,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final (String sign, Color color) = switch (kind) {
      AmountKind.income => ('+', AppColors.income),
      AmountKind.expense => ('−', AppColors.expense),
      AmountKind.transfer => ('', AppColors.transfer),
    };

    return Text(
      '$sign${Formatters.formatCurrency(amount)}',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}

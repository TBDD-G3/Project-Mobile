import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/formatters.dart';

/// Loại số tiền — quyết định dấu và màu hiển thị.
enum AmountKind { income, expense, transfer }

/// Hiển thị số tiền có dấu +/− và màu theo loại.
///
/// Luôn đặt trên nền trắng/trung tính (không đặt trên nền pastel)
/// để đảm bảo tương phản.
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

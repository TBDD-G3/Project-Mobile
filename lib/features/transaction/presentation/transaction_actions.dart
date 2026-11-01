import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/firestore/models/transaction.dart';
import '../providers/transaction_providers.dart';

/// Hỏi xác nhận rồi xóa giao dịch. Trả về `true` nếu đã xóa xong.
/// Số dư ví được hoàn lại bên trong repository.
Future<bool> confirmAndDeleteTransaction(
  BuildContext context,
  WidgetRef ref,
  Transaction transaction,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Xác nhận xóa'),
      content: const Text(
        'Bạn có chắc chắn muốn xóa? Hành động này không thể hoàn tác.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Xóa', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  try {
    await ref
        .read(transactionRepositoryProvider)
        .deleteTransaction(transaction);
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không xóa được giao dịch: $e')));
    }
    return false;
  }
}

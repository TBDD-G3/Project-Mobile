import 'package:cloud_firestore/cloud_firestore.dart';

/// Giao dịch thu/chi/chuyển khoản — Firestore Document model (Member 2).
class Transaction {
  final String id;
  final String walletId;
  final String? categoryId;

  /// 'income' | 'expense' | 'transfer'
  final String type;

  /// Luôn dương; dấu +/- do [type] quyết định.
  final double amount;
  final DateTime date;
  final String? note;

  /// Chỉ dùng khi `type == 'transfer'`.
  final String? toWalletId;

  const Transaction({
    required this.id,
    required this.walletId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
    this.toWalletId,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
  bool get isTransfer => type == 'transfer';

  factory Transaction.fromDocument(String id, Map<String, dynamic> data) {
    return Transaction(
      id: id,
      walletId: data['walletId'] as String? ?? '',
      categoryId: data['categoryId'] as String?,
      type: data['type'] as String? ?? 'expense',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: data['note'] as String?,
      toWalletId: data['toWalletId'] as String?,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'walletId': walletId,
      'categoryId': categoryId,
      'type': type,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'toWalletId': toWalletId,
    };
  }
}

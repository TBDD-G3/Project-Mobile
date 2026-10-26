import 'package:cloud_firestore/cloud_firestore.dart';

/// Ví tiền, mỗi ví là một Document trong Firestore.
/// [fromDocument] và [toDocument] là phần ORM của Câu 7.
class Wallet {
  final String id;
  final String userId;
  final String name;

  /// 'cash', 'bank' hoặc 'ewallet'
  final String type;

  /// Số dư chỉ đổi qua `updateBalance` lúc thêm/sửa/xóa giao dịch, UI không sửa tay.
  final double balance;
  final int? iconCode;
  final String? colorHex;
  final DateTime createdAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.iconCode,
    this.colorHex,
    required this.createdAt,
  });

  factory Wallet.fromDocument(String id, Map<String, dynamic> data) {
    return Wallet(
      id: id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'cash',
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      iconCode: (data['iconCode'] as num?)?.toInt(),
      colorHex: data['colorHex'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'iconCode': iconCode,
      'colorHex': colorHex,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Wallet copyWith({
    String? name,
    String? type,
    double? balance,
    int? iconCode,
    String? colorHex,
  }) {
    return Wallet(
      id: id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      iconCode: iconCode ?? this.iconCode,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
    );
  }
}

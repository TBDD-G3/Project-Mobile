import 'package:cloud_firestore/cloud_firestore.dart';

/// Người dùng — profile lưu trong collection `users` (id = Firebase Auth uid).
///
/// Mật khẩu KHÔNG lưu ở đây: Firebase Authentication đảm nhiệm việc
/// xác thực, document này chỉ chứa thông tin hồ sơ.
class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String currencyCode;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName = '',
    this.currencyCode = 'VND',
    required this.createdAt,
  });

  factory AppUser.fromDocument(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      currencyCode: data['currencyCode'] as String? ?? 'VND',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'email': email,
      'displayName': displayName,
      'currencyCode': currencyCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

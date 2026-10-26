import 'package:cloud_firestore/cloud_firestore.dart';

/// Hồ sơ người dùng, id chính là uid bên Firebase Auth.
/// Mật khẩu không lưu ở đây vì Firebase Auth lo phần xác thực rồi.
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

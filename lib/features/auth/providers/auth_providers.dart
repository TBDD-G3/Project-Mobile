import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../data/firestore/models/user.dart';
import '../data/auth_service.dart';

/// Provider dịch vụ xác thực (Firebase Authentication + hồ sơ Firestore).
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: ref.watch(firebaseAuthProvider),
    db: ref.watch(firebaseFirestoreProvider),
  );
});

/// 🔒 Stream lấy thông tin User hiện tại (đăng nhập qua Firebase Auth).
/// Member 2/3 dùng để lấy `id` (userId) và `currencyCode` khi format tiền.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../data/firestore/models/user.dart';
import '../data/auth_service.dart';

/// Provider của AuthService (Firebase Auth + hồ sơ Firestore).
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: ref.watch(firebaseAuthProvider),
    db: ref.watch(firebaseFirestoreProvider),
  );
});

/// User đang đăng nhập. Member 2/3 lấy `id` và `currencyCode` từ đây để format tiền.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

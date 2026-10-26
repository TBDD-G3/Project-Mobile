import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/models/user.dart';

/// Xác thực bằng Firebase Auth (email/password) và lưu hồ sơ vào `users`.
class AuthService {
  final fa.FirebaseAuth auth;
  final FirebaseFirestore db;

  AuthService({
    fa.FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : auth = auth ?? fa.FirebaseAuth.instance,
        db = db ?? FirebaseFirestore.instance;

  /// Tạo tài khoản mới rồi ghi hồ sơ lên Firestore.
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = AppUser(
      id: credential.user!.uid,
      email: email,
      displayName: displayName,
      currencyCode: 'VND',
      createdAt: DateTime.now(),
    );
    await usersCollection(db).doc(user.id).set(user);
  }

  /// Đăng nhập bằng email/password.
  Future<void> signIn({required String email, required String password}) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Gửi mail đặt lại mật khẩu (nút Quên mật khẩu).
  Future<void> sendPasswordReset(String email) {
    return auth.sendPasswordResetEmail(email: email);
  }

  /// Đăng xuất.
  Future<void> signOut() {
    return auth.signOut();
  }

  /// Stream trạng thái đăng nhập, trả về [AppUser] kèm hồ sơ trong Firestore.
  Stream<AppUser?> get authStateChanges {
    return auth.authStateChanges().asyncMap((faUser) async {
      if (faUser == null) return null;
      final doc = await usersCollection(db).doc(faUser.uid).get();
      if (doc.exists) return doc.data();
      return AppUser(
        id: faUser.uid,
        email: faUser.email ?? '',
        displayName: faUser.displayName ?? '',
        currencyCode: 'VND',
        createdAt: faUser.metadata.creationTime ?? DateTime.now(),
      );
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/models/wallet.dart';
import 'wallet_repository.dart';

/// Repository Ví tiền trên Firebase Firestore (Câu 7: ORM với Documents).
///
/// Mỗi ví là 01 Document trong collection `wallets`; mọi truy vấn đều đi
/// qua `walletsCollection()` có gắn converter (`withConverter`) để tự động
/// ánh xạ Document ↔ [Wallet].
class FirestoreWalletRepository implements WalletRepository {
  final FirebaseFirestore _db;

  FirestoreWalletRepository(this._db);

  /// Lọc ví theo người dùng đang đăng nhập (Firebase Auth uid).
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  @override
  Stream<List<Wallet>> watchAllWallets() {
    // Sắp xếp theo createdAt ở tầng Dart để tránh lỗi thiếu Composite Index
    // khi kết hợp .where('userId') và .orderBy('createdAt') trên Firestore.
    return walletsCollection(_db)
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          final wallets = snapshot.docs.map((doc) => doc.data()).toList();
          wallets.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return wallets;
        });
  }

  @override
  Future<Wallet?> getWalletById(String id) async {
    final snapshot = await walletsCollection(_db).doc(id).get();
    return snapshot.exists ? snapshot.data() : null;
  }

  @override
  Future<void> insertWallet(Wallet wallet) async {
    await walletsCollection(_db).doc(wallet.id).set(wallet);
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    await walletsCollection(_db).doc(wallet.id).update(wallet.toDocument());
  }

  @override
  Future<void> updateBalance(String walletId, double delta) async {
    // FieldValue.increment: cộng/trừ nguyên tử trên server, tránh race condition.
    await walletsCollection(_db)
        .doc(walletId)
        .update({'balance': FieldValue.increment(delta)});
  }

  @override
  Future<void> deleteWallet(String id) async {
    await walletsCollection(_db).doc(id).delete();
  }
}

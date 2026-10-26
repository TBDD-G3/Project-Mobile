import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/models/wallet.dart';
import 'wallet_repository.dart';

/// Repository ví chạy trên Firestore (Câu 7).
/// Mỗi ví là một Document trong `wallets`, đọc/ghi đều qua
/// `walletsCollection()` đã gắn converter nên làm việc thẳng với [Wallet].
class FirestoreWalletRepository implements WalletRepository {
  final FirebaseFirestore _db;

  FirestoreWalletRepository(this._db);

  /// Lấy uid của người đang đăng nhập để lọc ví.
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  @override
  Stream<List<Wallet>> watchAllWallets() {
    // Sort ở Dart cho khỏi phải tạo composite index cho where + orderBy.
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
    // FieldValue.increment cộng/trừ ngay trên server, tránh race condition.
    await walletsCollection(_db)
        .doc(walletId)
        .update({'balance': FieldValue.increment(delta)});
  }

  @override
  Future<void> deleteWallet(String id) async {
    await walletsCollection(_db).doc(id).delete();
  }
}

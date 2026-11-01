import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/models/budget.dart';
import 'budget_repository.dart';

/// Bản cài đặt Firestore của [BudgetRepository] (Câu 7).
///
/// Mọi Document đều mang `userId` trùng uid đang đăng nhập — thiếu trường này
/// hoặc lọc sai sẽ bị `PERMISSION_DENIED` theo `firestore.rules`.
class FirestoreBudgetRepository implements BudgetRepository {
  FirestoreBudgetRepository(this._db);

  final FirebaseFirestore _db;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Stream<List<Budget>> watchBudgetsByMonth(int month, int year) {
    if (_uid.isEmpty) return Stream.value(const []);
    return budgetsCollection(_db)
        .where('userId', isEqualTo: _uid)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((doc) => doc.data()).toList();
          // Không orderBy trên Firestore (đòi composite index) — sort trong Dart.
          list.sort((a, b) => a.categoryId.compareTo(b.categoryId));
          return list;
        });
  }

  @override
  Future<Budget?> getBudgetByCategory(
    String categoryId,
    int month,
    int year,
  ) async {
    if (_uid.isEmpty) return null;
    final snap = await budgetsCollection(_db)
        .where('userId', isEqualTo: _uid)
        .where('categoryId', isEqualTo: categoryId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }

  @override
  Future<void> insertBudget(Budget budget) async {
    await budgetsCollection(_db).doc(budget.id).set(budget);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await budgetsCollection(_db).doc(budget.id).set(budget);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await budgetsCollection(_db).doc(id).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import 'models/budget.dart';
import 'models/category.dart';
import 'models/transaction.dart';
import 'models/user.dart';
import 'models/wallet.dart';

/// Tên các collection trong Firestore (tương ứng 5 bảng trước đây).
abstract final class FirestoreCollections {
  static const users = 'users';
  static const wallets = 'wallets';
  static const categories = 'categories';
  static const transactions = 'transactions';
  static const budgets = 'budgets';
}

/// Tầng ORM: ánh xạ Document Firestore ↔ Model của ứng dụng (Câu 7 đề bài).
///
/// `withConverter` đảm bảo mọi thao tác đọc/ghi qua các collection này đều
/// tự động chuyển đổi đúng kiểu dữ liệu, không thao tác `Map` thủ công.
CollectionReference<AppUser> usersCollection(FirebaseFirestore db) {
  return db
      .collection(FirestoreCollections.users)
      .withConverter<AppUser>(
        fromFirestore: (snapshot, _) =>
            AppUser.fromDocument(snapshot.id, snapshot.data()!),
        toFirestore: (user, _) => user.toDocument(),
      );
}

CollectionReference<Wallet> walletsCollection(FirebaseFirestore db) {
  return db
      .collection(FirestoreCollections.wallets)
      .withConverter<Wallet>(
        fromFirestore: (snapshot, _) =>
            Wallet.fromDocument(snapshot.id, snapshot.data()!),
        toFirestore: (wallet, _) => wallet.toDocument(),
      );
}

CollectionReference<Category> categoriesCollection(FirebaseFirestore db) {
  return db
      .collection(FirestoreCollections.categories)
      .withConverter<Category>(
        fromFirestore: (snapshot, _) =>
            Category.fromDocument(snapshot.id, snapshot.data()!),
        toFirestore: (category, _) => category.toDocument(),
      );
}

CollectionReference<Transaction> transactionsCollection(
  FirebaseFirestore db,
) {
  return db
      .collection(FirestoreCollections.transactions)
      .withConverter<Transaction>(
        fromFirestore: (snapshot, _) =>
            Transaction.fromDocument(snapshot.id, snapshot.data()!),
        toFirestore: (transaction, _) => transaction.toDocument(),
      );
}

CollectionReference<Budget> budgetsCollection(FirebaseFirestore db) {
  return db
      .collection(FirestoreCollections.budgets)
      .withConverter<Budget>(
        fromFirestore: (snapshot, _) =>
            Budget.fromDocument(snapshot.id, snapshot.data()!),
        toFirestore: (budget, _) => budget.toDocument(),
      );
}

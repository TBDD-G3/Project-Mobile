import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import 'models/budget.dart';
import 'models/category.dart';
import 'models/transaction.dart';
import 'models/user.dart';
import 'models/wallet.dart';

/// Tên 5 collection bên Firestore (trước đây là 5 bảng).
abstract final class FirestoreCollections {
  static const users = 'users';
  static const wallets = 'wallets';
  static const categories = 'categories';
  static const transactions = 'transactions';
  static const budgets = 'budgets';
}

/// Phần ORM của Câu 7: mỗi hàm trả về collection đã gắn `withConverter`,
/// nên đọc/ghi ra thẳng Model, không phải tự xử lý Map nữa.
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

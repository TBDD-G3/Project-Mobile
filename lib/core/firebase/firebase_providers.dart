import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firestore/seed/initial_seeder.dart';

/// Instance Firestore toàn cục (Câu 7: kết nối CSDL Firebase).
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Instance Firebase Authentication toàn cục.
final firebaseAuthProvider = Provider<fa.FirebaseAuth>((ref) {
  return fa.FirebaseAuth.instance;
});

/// Seeder dữ liệu mặc định (danh mục thu/chi) lên Firestore — idempotent.
/// Trong chế độ mock (kUseMockData = true) provider này được override no-op.
final firebaseSeedProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(firebaseFirestoreProvider);
  await InitialSeeder.seedDefaultData(db);
});

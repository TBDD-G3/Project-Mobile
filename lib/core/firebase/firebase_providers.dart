import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firestore/seed/initial_seeder.dart';

/// Firestore dùng chung cho cả app (Câu 7).
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth dùng chung.
final firebaseAuthProvider = Provider<fa.FirebaseAuth>((ref) {
  return fa.FirebaseAuth.instance;
});

/// Seed 13 danh mục mặc định lên Firestore. Id là id cố định nên chạy lại
/// cũng không bị trùng; ở chế độ mock provider này được override thành no-op.
final firebaseSeedProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(firebaseFirestoreProvider);
  await InitialSeeder.seedDefaultData(db);
});

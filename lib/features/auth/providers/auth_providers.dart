import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';

/// 🔒 Stream lấy thông tin User hiện tại từ Database
final currentUserProvider = StreamProvider<User?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.users)..limit(1)).watchSingleOrNull();
});

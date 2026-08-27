import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';

/// 🔒 Provider cung cấp thông tin người dùng hiện tại (Do Leader implement, Member 2, 3 dùng)
final currentUserProvider = StateProvider<User?>((ref) {
  // Có thể khởi tạo User mặc định hoặc load từ DB/Auth service
  return null;
});

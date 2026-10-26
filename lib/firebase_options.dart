// ignore_for_file: avoid_print

/// ⚠️ FILE TẠM — CHỜ CẤU HÌNH FIREBASE THẬT.
///
/// Chạy lệnh sau để sinh lại file này với cấu hình Firebase của nhóm
/// (file sẽ được ghi đè tự động):
///
///   flutterfire configure
///
/// Sau đó đổi `kUseMockData` trong `lib/main.dart` thành `false`.
library;

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'REPLACE_WITH_API_KEY',
    appId: 'REPLACE_WITH_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
  );
}

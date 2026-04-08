import 'package:flutter/foundation.dart';

class ApiConfig {
  // You can override this at runtime:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
  static const _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  // Android emulator cannot reach localhost directly; use 10.0.2.2.
  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  static const authPrefix = '/api/auth';
}

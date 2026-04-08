import 'package:flutter/foundation.dart';

class ApiConfig {
  static const _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }

    // KHUSUS USB Port Forwarding / ADB Reverse:
    // Kita pakai 127.0.0.1 karena jembatan Chrome sudah aktif.
    // Ini berlaku baik di Web, Android (HP asli), maupun Desktop.
    return 'http://127.0.0.1:8000';
  }

  static const authPrefix = '/api/auth';
}

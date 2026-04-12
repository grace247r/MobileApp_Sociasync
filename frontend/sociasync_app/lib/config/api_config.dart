import 'package:flutter/foundation.dart';

class ApiConfig {
  static const _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }

    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return 'http://$host:8000';
    }

    // Android emulator cannot access host localhost directly.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static const authPrefix = '/api/auth';
}

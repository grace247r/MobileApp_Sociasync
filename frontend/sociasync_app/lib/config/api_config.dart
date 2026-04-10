class ApiConfig {
  static const _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }
    return 'http://127.0.0.1:8000';
  }

  static const authPrefix = '/api/auth';
}

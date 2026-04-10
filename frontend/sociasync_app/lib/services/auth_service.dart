import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sociasync_app/config/api_config.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static Uri _uri(String path) {
    return Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/$path');
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    late final http.Response response;
    try {
      response = await http.post(
        _uri('login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode == 200) {
      final tokens = data['tokens'] as Map<String, dynamic>?;
      await _saveTokens(
        access: tokens?['access'] as String? ?? '',
        refresh: tokens?['refresh'] as String? ?? '',
      );
      return;
    }

    throw AuthException(_extractErrorMessage(data));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  static Future<void> _saveTokens({
    required String access,
    required String refresh,
  }) async {
    if (access.isEmpty || refresh.isEmpty) {
      throw AuthException('Token tidak valid dari server.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  static Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{};
  }

  static String _extractErrorMessage(Map<String, dynamic> data) {
    if (data['error'] is String) {
      return data['error'] as String;
    }

    for (final value in data.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return 'Terjadi kesalahan pada server.';
  }

  static String _connectionErrorMessage() {
    return 'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}).';
  }
}

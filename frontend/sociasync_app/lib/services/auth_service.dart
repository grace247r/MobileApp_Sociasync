import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sociasync_app/config/api_config.dart';
import 'package:sociasync_app/models/user_profile.dart';

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

  static Future<void> register({
    required String name,
    required String email,
    required String gender,
    required String password,
    required String confirmPassword,
  }) async {
    late final http.Response response;
    try {
      response = await http.post(
        _uri('register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'gender': gender,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode == 201) {
      final tokens = data['tokens'] as Map<String, dynamic>?;
      await _saveTokens(
        access: tokens?['access'] as String? ?? '',
        refresh: tokens?['refresh'] as String? ?? '',
      );
      return;
    }

    throw AuthException(_extractErrorMessage(data));
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
      await _saveTokens(
        access: (data['access'] ?? '') as String,
        refresh: (data['refresh'] ?? '') as String,
      );
      return;
    }

    throw AuthException(_extractErrorMessage(data));
  }

  static Future<UserProfile> getMe() async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http.get(
        _uri('me/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    if (response.statusCode == 200) {
      return UserProfile.fromJson(_decode(response.body));
    }

    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        throw AuthException('Sesi habis, silakan login ulang.');
      }

      final retryToken = await _readToken(_accessKey);
      late final http.Response retryResponse;
      try {
        retryResponse = await http.get(
          _uri('me/'),
          headers: {'Authorization': 'Bearer $retryToken'},
        );
      } catch (_) {
        throw AuthException(_connectionErrorMessage());
      }
      if (retryResponse.statusCode == 200) {
        return UserProfile.fromJson(_decode(retryResponse.body));
      }
    }

    throw AuthException('Gagal memuat profil.');
  }

  static Future<UserProfile> updateProfile(UserProfile profile) async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi habis, silakan login ulang.');
    }

    late final http.Response response;
    try {
      response = await http.put(
        _uri('profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profile.toUpdateJson()),
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    if (response.statusCode == 200) {
      return UserProfile.fromJson(_decode(response.body));
    }

    throw AuthException('Gagal menyimpan profil.');
  }

  static Future<bool> hasSession() async {
    final access = await _readToken(_accessKey);
    if (access != null && access.isNotEmpty) {
      return true;
    }

    final refreshed = await _refreshAccessToken();
    return refreshed;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  static Future<String?> _getAccessTokenOrRefresh() async {
    final access = await _readToken(_accessKey);
    if (access != null && access.isNotEmpty) {
      return access;
    }

    final refreshed = await _refreshAccessToken();
    if (!refreshed) return null;
    return _readToken(_accessKey);
  }

  static Future<bool> _refreshAccessToken() async {
    final refresh = await _readToken(_refreshKey);
    if (refresh == null || refresh.isEmpty) {
      return false;
    }

    final response = await http.post(
      _uri('refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    final data = _decode(response.body);
    if (response.statusCode == 200 && data['access'] != null) {
      await _saveTokens(access: data['access'] as String, refresh: refresh);
      return true;
    }

    return false;
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

  static Future<String?> _readToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
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

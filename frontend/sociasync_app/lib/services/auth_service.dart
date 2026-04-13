import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
  static const _emailKey = 'user_email';
  static const _requestTimeout = Duration(seconds: 12);

  static Uri _uri(String path) {
    return Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/$path');
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            _uri('login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw AuthException(_timeoutErrorMessage());
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
      await _saveEmail(email.trim());
      return;
    }

    throw AuthException(_extractErrorMessage(data));
  }

  static Future<void> register({
    required String name,
    required String email,
    required String gender,
    required String password,
    required String confirmPassword,
    required String dateOfBirth,
    required String region,
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
          'date_of_birth': dateOfBirth,
          'region': region,
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
      await _saveEmail(email.trim());
      return;
    }

    throw AuthException(_extractErrorMessage(data));
  }

  static Future<void> requestPasswordResetCode({
    required String identifier,
  }) async {
    late final http.Response response;
    try {
      response = await http.post(
        _uri('password-reset/request/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': identifier}),
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode == 200) {
      return;
    }

    throw AuthException(_extractErrorMessage(data));
  }

  static Future<void> confirmPasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    late final http.Response response;
    try {
      response = await http.post(
        _uri('password-reset/confirm/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': identifier,
          'code': code,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode == 200) {
      return;
    }

    throw AuthException(_extractErrorMessage(data));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_emailKey);
  }

  static Future<Map<String, dynamic>> getMe() async {
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
      return _decode(response.body);
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
        return _decode(retryResponse.body);
      }
    }

    throw AuthException('Gagal memuat profil.');
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http.patch(
        _uri('profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    if (response.statusCode == 200) {
      final updated = _decode(response.body);
      if ((updated['email'] ?? '').toString().trim().isNotEmpty) {
        await _saveEmail((updated['email'] as String).trim());
      }
      return updated;
    }

    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        throw AuthException('Sesi habis, silakan login ulang.');
      }

      final retryToken = await _readToken(_accessKey);
      late final http.Response retryResponse;
      try {
        retryResponse = await http.patch(
          _uri('profile/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $retryToken',
          },
          body: jsonEncode(payload),
        );
      } catch (_) {
        throw AuthException(_connectionErrorMessage());
      }

      if (retryResponse.statusCode == 200) {
        final updated = _decode(retryResponse.body);
        if ((updated['email'] ?? '').toString().trim().isNotEmpty) {
          await _saveEmail((updated['email'] as String).trim());
        }
        return updated;
      }
    }

    throw AuthException('Gagal menyimpan profil.');
  }

  static Future<Map<String, dynamic>> uploadProfileImage(
    XFile imageFile,
  ) async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    Future<http.StreamedResponse> send(String authToken) async {
      final request = http.MultipartRequest('PATCH', _uri('profile/'));
      request.headers['Authorization'] = 'Bearer $authToken';
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'profile_image',
          bytes,
          filename: imageFile.name,
        ),
      );
      return request.send();
    }

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await send(token);
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        throw AuthException('Sesi habis, silakan login ulang.');
      }

      final retryToken = await _readToken(_accessKey);
      if (retryToken == null || retryToken.isEmpty) {
        throw AuthException('Sesi login tidak ditemukan.');
      }

      try {
        final retryStream = await send(retryToken);
        response = await http.Response.fromStream(retryStream);
      } catch (_) {
        throw AuthException(_connectionErrorMessage());
      }
    }

    final data = _decode(response.body);
    if (response.statusCode == 200) {
      if ((data['email'] ?? '').toString().trim().isNotEmpty) {
        await _saveEmail((data['email'] as String).trim());
      }
      return data;
    }

    throw AuthException(_extractErrorMessage(data));
  }

  static Future<void> deleteAccount() async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http.delete(
        _uri('profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    if (response.statusCode == 204) {
      await logout();
      return;
    }

    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        throw AuthException('Sesi habis, silakan login ulang.');
      }

      final retryToken = await _readToken(_accessKey);
      late final http.Response retryResponse;
      try {
        retryResponse = await http.delete(
          _uri('profile/'),
          headers: {'Authorization': 'Bearer $retryToken'},
        );
      } catch (_) {
        throw AuthException(_connectionErrorMessage());
      }

      if (retryResponse.statusCode == 204) {
        await logout();
        return;
      }
    }

    throw AuthException('Gagal menghapus akun.');
  }

  static Future<Map<String, dynamic>> getNotificationSettings() async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/settings/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    if (response.statusCode == 200) {
      return _decode(response.body);
    }

    throw AuthException('Gagal memuat pengaturan notifikasi.');
  }

  static Future<Map<String, dynamic>> updateNotificationSettings(
    Map<String, dynamic> payload,
  ) async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/settings/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    if (response.statusCode == 200) {
      return _decode(response.body);
    }

    throw AuthException('Gagal menyimpan pengaturan notifikasi.');
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.whereType<Map>().map((e) {
          return e.map((key, value) => MapEntry(key.toString(), value));
        }).toList();
      }
      return const <Map<String, dynamic>>[];
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
          Uri.parse('${ApiConfig.baseUrl}/api/notifications/'),
          headers: {'Authorization': 'Bearer $retryToken'},
        );
      } catch (_) {
        throw AuthException(_connectionErrorMessage());
      }

      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(retryResponse.body);
        if (decoded is List) {
          return decoded.whereType<Map>().map((e) {
            return e.map((key, value) => MapEntry(key.toString(), value));
          }).toList();
        }
      }
    }

    throw AuthException('Gagal memuat notifikasi.');
  }

  static Future<int> getUnreadNotificationCount() async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/unread-count/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    if (response.statusCode == 200) {
      final data = _decode(response.body);
      final rawCount = data['unread_count'];
      if (rawCount is int) return rawCount;
      return int.tryParse(rawCount?.toString() ?? '0') ?? 0;
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
          Uri.parse('${ApiConfig.baseUrl}/api/notifications/unread-count/'),
          headers: {'Authorization': 'Bearer $retryToken'},
        );
      } catch (_) {
        throw AuthException(_connectionErrorMessage());
      }

      if (retryResponse.statusCode == 200) {
        final data = _decode(retryResponse.body);
        final rawCount = data['unread_count'];
        if (rawCount is int) return rawCount;
        return int.tryParse(rawCount?.toString() ?? '0') ?? 0;
      }
    }

    throw AuthException('Gagal memuat jumlah notifikasi belum dibaca.');
  }

  static Future<int> markAllNotificationsRead() async {
    final token = await _getAccessTokenOrRefresh();
    if (token == null) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/read-all/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (_) {
      throw AuthException(_connectionErrorMessage());
    }

    if (response.statusCode == 200) {
      final data = _decode(response.body);
      final rawUpdated = data['updated'];
      if (rawUpdated is int) return rawUpdated;
      return int.tryParse(rawUpdated?.toString() ?? '0') ?? 0;
    }

    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        throw AuthException('Sesi habis, silakan login ulang.');
      }

      final retryToken = await _readToken(_accessKey);
      late final http.Response retryResponse;
      try {
        retryResponse = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/notifications/read-all/'),
          headers: {'Authorization': 'Bearer $retryToken'},
        );
      } catch (_) {
        throw AuthException(_connectionErrorMessage());
      }

      if (retryResponse.statusCode == 200) {
        final data = _decode(retryResponse.body);
        final rawUpdated = data['updated'];
        if (rawUpdated is int) return rawUpdated;
        return int.tryParse(rawUpdated?.toString() ?? '0') ?? 0;
      }
    }

    throw AuthException('Gagal menandai notifikasi sebagai dibaca.');
  }

  static Future<String?> getSavedEmail() {
    return _readToken(_emailKey);
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

  static Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
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

    late final http.Response response;
    try {
      response = await http.post(
        _uri('refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );
    } catch (_) {
      return false;
    }

    final data = _decode(response.body);
    if (response.statusCode == 200 && data['access'] != null) {
      await _saveTokens(access: data['access'] as String, refresh: refresh);
      return true;
    }

    return false;
  }

  static Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{
        'error':
            'Respons server tidak valid. Cek backend log (kemungkinan error 500).',
      };
    }
  }

  static Future<String?> _readToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
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
    return 'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}). Untuk HP fisik, gunakan --dart-define API_BASE_URL=http://IP_LAPTOP:8000 atau adb reverse tcp:8000 tcp:8000.';
  }

  static String _timeoutErrorMessage() {
    return 'Server tidak merespons dalam ${_requestTimeout.inSeconds} detik (${ApiConfig.baseUrl}). Cek backend berjalan dan URL API untuk HP fisik sudah benar.';
  }
}

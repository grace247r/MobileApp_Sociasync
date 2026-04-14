import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sociasync_app/config/api_config.dart';
import 'package:sociasync_app/services/auth_service.dart';

class ReminderService {
  static Uri _uri([String path = '']) {
    final cleanPath = path.replaceAll(RegExp(r'^/+'), '');
    final suffix = cleanPath.isEmpty ? '' : cleanPath;
    return Uri.parse('${ApiConfig.baseUrl}/api/reminders/$suffix');
  }

  static Future<List<Map<String, dynamic>>> getReminders() async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    final response = await http.get(
      _uri(),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.whereType<Map>().map((e) {
          return e.map((key, value) => MapEntry(key.toString(), value));
        }).toList();
      }
      return const <Map<String, dynamic>>[];
    }

    _throwApiError(response.body);
  }

  static Future<Map<String, dynamic>> createReminder({
    required String to,
    required String message,
    required String day,
    required String time,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    final response = await http.post(
      _uri('create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'to': to,
        'message': message,
        'day': day,
        'time': time,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    }

    _throwApiError(response.body);
  }

  static Future<Map<String, dynamic>> updateReminder({
    required int reminderId,
    String? to,
    String? message,
    String? day,
    String? time,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    final payload = <String, dynamic>{};
    if (to != null) payload['to'] = to;
    if (message != null) payload['message'] = message;
    if (day != null) payload['day'] = day;
    if (time != null) payload['time'] = time;

    final response = await http.patch(
      _uri('update/$reminderId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    }

    _throwApiError(response.body);
  }

  static Future<void> completeReminder({required int reminderId}) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    final response = await http.patch(
      _uri('complete/$reminderId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    _throwApiError(response.body);
  }

  static Never _throwApiError(String responseBody) {
    try {
      final body = jsonDecode(responseBody);
      if (body is Map<String, dynamic>) {
        for (final value in body.values) {
          if (value is List && value.isNotEmpty) {
            throw AuthException(value.first.toString());
          }
          if (value is String && value.isNotEmpty) {
            throw AuthException(value);
          }
        }
      }
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (_) {
      // Fall through to generic below.
    }

    throw AuthException('Terjadi kesalahan pada server reminders.');
  }
}

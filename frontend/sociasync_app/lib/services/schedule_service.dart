import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sociasync_app/config/api_config.dart';
import 'package:sociasync_app/services/auth_service.dart';

class ScheduleService {
  static Uri _uri([String path = '']) {
    final cleanPath = path.replaceAll(RegExp(r'^/+'), '');
    final suffix = cleanPath.isEmpty ? '' : cleanPath;
    return Uri.parse('${ApiConfig.baseUrl}/api/schedules/$suffix');
  }

  static Future<List<Map<String, dynamic>>> getSchedules() async {
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

    throw AuthException('Gagal memuat schedules.');
  }

  static Future<Map<String, dynamic>> createSchedule({
    required String title,
    required String caption,
    required String platform,
    required DateTime startTime,
    DateTime? endTime,
    required bool isDaily,
    required String repeat,
    required String reminderType,
    String? notes,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    final payload = {
      'title': title,
      'caption': caption,
      'platform': platform,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_daily': isDaily,
      'repeat': repeat,
      'reminder_type': reminderType,
      'notes': (notes ?? '').trim().isEmpty ? null : notes!.trim(),
    };

    final response = await http.post(
      _uri(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    }

    _throwApiError(response.body);
    throw AuthException(
      'Gagal menambahkan event (HTTP ${response.statusCode}).',
    );
  }

  static Future<Map<String, dynamic>> updateSchedule({
    required int scheduleId,
    required String title,
    required String caption,
    required String platform,
    required DateTime startTime,
    DateTime? endTime,
    required bool isDaily,
    required String repeat,
    required String reminderType,
    String? notes,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Sesi login tidak ditemukan.');
    }

    final payload = {
      'title': title,
      'caption': caption,
      'platform': platform,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_daily': isDaily,
      'repeat': repeat,
      'reminder_type': reminderType,
      'notes': (notes ?? '').trim().isEmpty ? null : notes!.trim(),
    };

    final response = await http.patch(
      _uri('$scheduleId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    }

    _throwApiError(response.body);
    throw AuthException('Gagal mengubah event (HTTP ${response.statusCode}).');
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

    throw AuthException('Terjadi kesalahan pada server schedules.');
  }
}

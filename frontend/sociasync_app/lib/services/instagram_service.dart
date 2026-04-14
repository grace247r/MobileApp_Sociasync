import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sociasync_app/config/api_config.dart';
import 'package:sociasync_app/services/auth_service.dart';

class InstagramServiceException implements Exception {
  InstagramServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InstagramService {
  static const _requestTimeout = Duration(seconds: 15);

  static Uri _uri(String path, {Map<String, String>? query}) {
    final base = Uri.parse(
      '${ApiConfig.baseUrl}/api/instagram/instagram/$path',
    );
    if (query == null || query.isEmpty) {
      return base;
    }
    return base.replace(queryParameters: query);
  }

  static Future<Map<String, dynamic>> connectUsername(String username) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw InstagramServiceException('Sesi login tidak ditemukan.');
    }

    final normalized = username.trim();
    if (normalized.isEmpty) {
      throw InstagramServiceException('Username Instagram wajib diisi.');
    }

    late final http.Response response;
    try {
      response = await http
          .post(
            _uri('connect_username/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'instagram_username': normalized}),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw InstagramServiceException(_timeoutMessage());
    } catch (_) {
      throw InstagramServiceException(_connectionMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode == 200) {
      return data;
    }

    throw InstagramServiceException(_extractErrorMessage(data));
  }

  static Future<Map<String, dynamic>> triggerScrape({
    int resultsLimit = 60,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw InstagramServiceException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http
          .post(
            _uri('trigger_scrape/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'results_limit': resultsLimit}),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw InstagramServiceException(_timeoutMessage());
    } catch (_) {
      throw InstagramServiceException(_connectionMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    }

    throw InstagramServiceException(_extractErrorMessage(data));
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw InstagramServiceException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http
          .get(_uri('dashboard/'), headers: {'Authorization': 'Bearer $token'})
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw InstagramServiceException(_timeoutMessage());
    } catch (_) {
      throw InstagramServiceException(_connectionMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode == 200) {
      return data;
    }

    throw InstagramServiceException(_extractErrorMessage(data));
  }

  static Future<List<Map<String, dynamic>>> getStatsHistory({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw InstagramServiceException('Sesi login tidak ditemukan.');
    }

    final query = <String, String>{'limit': '$limit'};
    if (startDate != null) {
      query['start_date'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      query['end_date'] = endDate.toIso8601String().split('T').first;
    }

    late final http.Response response;
    try {
      response = await http
          .get(
            _uri('stats_history/', query: query),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw InstagramServiceException(_timeoutMessage());
    } catch (_) {
      throw InstagramServiceException(_connectionMessage());
    }

    if (response.statusCode != 200) {
      final data = _decode(response.body);
      throw InstagramServiceException(_extractErrorMessage(data));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const <Map<String, dynamic>>[];
    }

    return decoded.whereType<Map>().map((e) {
      return e.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }

  static Future<Map<String, dynamic>> getBestPosts({int limit = 6}) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw InstagramServiceException('Sesi login tidak ditemukan.');
    }

    late final http.Response response;
    try {
      response = await http
          .get(
            _uri('best_posts/', query: {'limit': '$limit'}),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw InstagramServiceException(_timeoutMessage());
    } catch (_) {
      throw InstagramServiceException(_connectionMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode == 200) {
      return data;
    }

    throw InstagramServiceException(_extractErrorMessage(data));
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
      return <String, dynamic>{'error': 'Respons server tidak valid.'};
    }
  }

  static String _extractErrorMessage(Map<String, dynamic> data) {
    if (data['error'] is String) {
      final message = data['error'] as String;
      if (message.contains('APIFY_API_TOKEN not found')) {
        return 'APIFY token belum diset. Isi APIFY_API_TOKEN di backend/backend_drf/.env lalu restart Django server.';
      }
      return message;
    }

    for (final value in data.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return 'Terjadi kesalahan pada layanan Instagram.';
  }

  static String _connectionMessage() {
    return 'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}).';
  }

  static String _timeoutMessage() {
    return 'Server Instagram tidak merespons dalam ${_requestTimeout.inSeconds} detik.';
  }
}

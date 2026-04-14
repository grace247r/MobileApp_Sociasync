import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sociasync_app/config/api_config.dart';
import 'package:sociasync_app/services/auth_service.dart';

class ContentGeneratorServiceException implements Exception {
  ContentGeneratorServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ContentGeneratorService {
  static const _requestTimeout = Duration(seconds: 20);

  static Uri _uri(String path, {Map<String, String>? query}) {
    final base = Uri.parse('${ApiConfig.baseUrl}/api/content-gen/$path');
    if (query == null || query.isEmpty) {
      return base;
    }
    return base.replace(queryParameters: query);
  }

  static Future<String> _token() async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ContentGeneratorServiceException('Sesi login tidak ditemukan.');
    }
    return token;
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final token = await _token();

    late final http.Response response;
    try {
      response = await http
          .post(
            _uri(path),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw ContentGeneratorServiceException(_timeoutMessage());
    } catch (_) {
      throw ContentGeneratorServiceException(_connectionMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ContentGeneratorServiceException(_extractErrorMessage(data));
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final token = await _token();

    late final http.Response response;
    try {
      response = await http
          .get(_uri(path), headers: {'Authorization': 'Bearer $token'})
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw ContentGeneratorServiceException(_timeoutMessage());
    } catch (_) {
      throw ContentGeneratorServiceException(_connectionMessage());
    }

    final data = _decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ContentGeneratorServiceException(_extractErrorMessage(data));
  }

  static Future<List<Map<String, dynamic>>> generateIdeas({
    required String platform,
    required String topic,
    required String goal,
    required String audience,
    required String tone,
  }) async {
    final data = await _post('generate-ideas/', {
      'platform': platform,
      'topic': topic,
      'goal': goal,
      'audience': audience,
      'tone': tone,
    });

    final raw = data['ideas'] ?? data;
    if (raw is! List) {
      throw ContentGeneratorServiceException('Format ide konten tidak valid.');
    }

    return raw.whereType<Map>().map((item) {
      return item.map((k, v) => MapEntry(k.toString(), v));
    }).toList();
  }

  static Future<Map<String, dynamic>> generateScript({
    required String title,
    required String description,
    String? previousHook,
    String? previousBody,
    String? previousCta,
  }) {
    return _post('generate-script/', {
      'title': title,
      'description': description,
      'previous_hook': previousHook ?? '',
      'previous_body': previousBody ?? '',
      'previous_cta': previousCta ?? '',
    });
  }

  static Future<String> generateCaption({
    required String platform,
    required String tone,
  }) async {
    final data = await _post('generate-caption/', {
      'platform': platform,
      'tone': tone,
    });
    final caption = (data['caption'] ?? '').toString().trim();
    if (caption.isEmpty) {
      throw ContentGeneratorServiceException('Caption tidak tersedia.');
    }
    return caption;
  }

  static Future<List<String>> generateHashtags({
    required String platform,
    required String topic,
    required String tone,
  }) async {
    final data = await _post('generate-hashtags/', {
      'platform': platform,
      'topic': topic,
      'tone': tone,
    });

    final raw = data['hashtags'];
    if (raw is! List) {
      throw ContentGeneratorServiceException('Format hashtag tidak valid.');
    }

    return raw
        .map((item) => item.toString())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static Future<int> saveContent({
    required String topic,
    required String platform,
    required Map<String, dynamic> idea,
    required Map<String, dynamic> script,
    required String caption,
    required List<String> hashtags,
  }) async {
    final data = await _post('save-content/', {
      'topic': topic,
      'platform': platform,
      'idea': idea,
      'script': script,
      'caption': caption,
      'hashtags': hashtags,
    });

    final id = int.tryParse(data['content_id']?.toString() ?? '0') ?? 0;
    if (id <= 0) {
      throw ContentGeneratorServiceException('Gagal menyimpan konten.');
    }
    return id;
  }

  static Future<List<Map<String, dynamic>>> getSavedContents() async {
    final data = await _get('saved-content/');
    final raw = data['results'];
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }

    return raw.whereType<Map>().map((item) {
      return item.map((k, v) => MapEntry(k.toString(), v));
    }).toList();
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
    if (data['error'] is String && (data['error'] as String).isNotEmpty) {
      return data['error'] as String;
    }

    if (data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }

    for (final value in data.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return 'Terjadi kesalahan pada layanan Content Generator.';
  }

  static String _connectionMessage() {
    return 'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}).';
  }

  static String _timeoutMessage() {
    return 'Server tidak merespons dalam ${_requestTimeout.inSeconds} detik.';
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sociasync_app/config/api_config.dart';
import 'package:sociasync_app/services/auth_service.dart';

class ChatbotServiceException implements Exception {
  ChatbotServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChatbotService {
  static const _timeout = Duration(seconds: 20);

  static Uri _uri() => Uri.parse('${ApiConfig.baseUrl}/api/chat/');

  static Future<String> chat({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ChatbotServiceException(
        'Sesi login tidak ditemukan. Silakan login ulang.',
      );
    }

    late final http.Response response;

    try {
      response = await http
          .post(
            _uri(),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'message': message, 'history': history}),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw ChatbotServiceException('Chatbot timeout. Coba lagi.');
    } catch (_) {
      throw ChatbotServiceException('Tidak bisa terhubung ke server chatbot.');
    }

    final data = _decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final reply = (data['reply'] ?? '').toString().trim();
      if (reply.isEmpty) {
        throw ChatbotServiceException('Balasan chatbot kosong.');
      }
      return reply;
    }

    throw ChatbotServiceException(_extractErrorMessage(data));
  }

  static Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{'error': 'Respons chatbot tidak valid.'};
    }
  }

  static String _extractErrorMessage(Map<String, dynamic> data) {
    if (data['error'] is String && (data['error'] as String).isNotEmpty) {
      return data['error'] as String;
    }
    if (data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    return 'Gagal memproses chat.';
  }
}

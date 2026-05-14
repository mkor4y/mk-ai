/// MK AI - Chat Servisi
///
/// FastAPI backend'deki /api/chat endpoint'ine HTTP çağrıları yapar.
/// AI sohbet, hisse analizi, eğitim içerikleri ve yardım talepleri.
library;

import 'package:dio/dio.dart';
import 'api_client.dart';

class ChatService {
  final Dio _dio = ApiClient.instance;

  /// AI'a mesaj gönder ve yanıt al
  /// Endpoint: POST /api/chat
  Future<ChatResponse> sendMessage(String message, {String? stockCode}) async {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'message': message,
          if (stockCode != null) 'stock_code': stockCode,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ChatResponse(
        success: json['success'] as bool? ?? false,
        response: json['response'] as String? ?? '',
        provider: json['provider'] as String? ?? '',
      );
    } on DioException catch (e) {
      return ChatResponse(
        success: false,
        response: 'Bağlantı hatası: ${e.message ?? "Sunucuya erişilemiyor"}',
        provider: 'error',
      );
    }
  }
}

/// Chat API yanıt modeli
class ChatResponse {
  final bool success;
  final String response;
  final String provider;

  const ChatResponse({
    required this.success,
    required this.response,
    required this.provider,
  });
}

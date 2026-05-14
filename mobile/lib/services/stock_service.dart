/// MK AI - Hisse Analiz Servisi
///
/// FastAPI backend'deki /api/market/summary ve /api/analyze/{code}
/// endpoint'lerine HTTP çağrıları yapar.
library;

import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/market_summary.dart';
import '../models/analysis_result.dart';
import 'api_client.dart';

class StockService {
  final Dio _dio = ApiClient.instance;

  /// Piyasa özeti al (BIST 100/30 endeksleri + watchlist)
  /// Endpoint: GET /api/market/summary
  Future<MarketSummary> getMarketSummary() async {
    try {
      final response = await _dio.get('/api/market/summary');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return MarketSummary.fromJson(json);
      }
      throw Exception(json['error'] ?? 'Piyasa verisi alınamadı');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Kapsamlı hisse analizi yap
  /// Endpoint: GET /api/analyze/{stockCode}
  Future<AnalysisResult> analyzeStock(String stockCode) async {
    try {
      final code = stockCode.toUpperCase();
      final response = await _dio.get('/api/analyze/$code');
      final json = response.data as Map<String, dynamic>;

      return AnalysisResult.fromJson(json);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Dio hatalarını kullanıcı dostu mesajlara çevirir
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin. '
          '(API: ${AppConfig.apiBaseUrl})',
        );
      case DioExceptionType.connectionError:
        return Exception(
          'Sunucuya erişilemiyor. Backend çalışıyor mu? '
          '(${AppConfig.apiBaseUrl})',
        );
      default:
        return Exception(
          e.response?.data?['detail'] ?? e.message ?? 'Bilinmeyen hata',
        );
    }
  }
}

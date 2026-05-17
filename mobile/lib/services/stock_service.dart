/// MK AI - Hisse Analiz Servisi
///
/// FastAPI backend'deki /api/market/summary ve /api/analyze/{code}
/// endpoint'lerine HTTP çağrıları yapar.
library;

import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/market_summary.dart';
import '../models/analysis_result.dart';
import '../models/chart_data.dart';
import 'api_client.dart';

/// Hafif fiyat snapshot'i — /api/quotes yanitindan parse edilir.
class StockQuote {
  final String symbol;
  final String name;
  final double price;
  final double changePct;

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePct,
  });

  bool get up => changePct >= 0;
}

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

  /// Portfoy/watchlist icin batch fiyat al
  /// Endpoint: GET /api/quotes?codes=THYAO,GARAN
  ///
  /// Returns: { 'THYAO': StockQuote(...), ... } — desteklenmeyen veya
  /// hata alan semboller eksik gelir (silent fail).
  Future<Map<String, StockQuote>> getQuotes(List<String> codes) async {
    if (codes.isEmpty) return const {};
    try {
      final cleanCodes =
          codes.map((c) => c.toUpperCase().trim()).where((c) => c.isNotEmpty).toSet().join(',');
      final response = await _dio.get(
        '/api/quotes',
        queryParameters: {'codes': cleanCodes},
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw Exception(json['error'] ?? 'Fiyatlar alinamadi');
      }
      final raw = (json['quotes'] as Map?) ?? const {};
      final out = <String, StockQuote>{};
      raw.forEach((k, v) {
        final m = v as Map<String, dynamic>;
        out[k.toString().toUpperCase()] = StockQuote(
          symbol: k.toString().toUpperCase(),
          name: (m['name'] as String?) ?? '',
          price: (m['price'] as num? ?? 0).toDouble(),
          changePct: (m['change_pct'] as num? ?? 0).toDouble(),
        );
      });
      return out;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Hisse grafik verisi (OHLCV) al
  /// Endpoint: GET /api/chart/{stockCode}?range=1A
  Future<ChartData> getChartData(String stockCode, String range) async {
    try {
      final code = stockCode.toUpperCase();
      final response = await _dio.get(
        '/api/chart/$code',
        queryParameters: {'range': range},
      );
      final json = response.data as Map<String, dynamic>;
      return ChartData.fromJson(json);
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

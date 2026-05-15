/// MK AI - Uygulama Konfigürasyonu
///
/// API URL'leri, desteklenen hisse kodları ve uygulama sabitleri.
/// Backend'deki [config.py] ile senkronize tutulmalıdır.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  // ==================== API AYARLARI ====================

  /// FastAPI backend URL'si
  /// Emülatör: http://10.0.2.2:8000
  /// Gerçek cihaz: http://172.20.10.6:8000
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://172.20.10.6:8000';

  // ==================== API ENDPOINT'LERİ ====================
  static String get marketSummaryUrl => '$apiBaseUrl/api/market/summary';
  static String analyzeUrl(String code) => '$apiBaseUrl/api/analyze/$code';
  static String get chatUrl => '$apiBaseUrl/api/chat';
  static String get newsUrl => '$apiBaseUrl/api/news';

  // ==================== UYGULAMA SABİTLERİ ====================
  static const String appName = 'MK AI';
  static const String appSlogan = 'Akıllı Yatırım Asistanı';
  static const String appVersion = '1.0.0';
  static const String developerName = 'Mustafa Koray Kök';

  /// Dashboard auto-refresh süresi (milisaniye)
  static const int refreshInterval = 30000; // 30 saniye

  /// HTTP istek zaman aşımı (saniye)
  static const int httpTimeout = 30;

  // ==================== DESTEKLENEN BIST HİSSELERİ ====================
  /// Backend'deki Config.SUPPORTED_BIST_STOCKS ile birebir aynı.
  static const List<StockItem> supportedStocks = [
    StockItem(code: 'THYAO', name: 'Türk Hava Yolları'),
    StockItem(code: 'GARAN', name: 'Garanti Bankası'),
    StockItem(code: 'AKBNK', name: 'Akbank'),
    StockItem(code: 'ASELS', name: 'Aselsan'),
    StockItem(code: 'KRDMD', name: 'Kardemir'),
    StockItem(code: 'TUPRS', name: 'Tüpraş'),
    StockItem(code: 'DOFRB', name: 'Dofer'),
    StockItem(code: 'ISCTR', name: 'İş Bankası'),
    StockItem(code: 'YKBNK', name: 'Yapı Kredi Bankası'),
    StockItem(code: 'HALKB', name: 'Halkbank'),
    StockItem(code: 'VAKBN', name: 'Vakıfbank'),
    StockItem(code: 'SISE', name: 'Şişecam'),
    StockItem(code: 'BIMAS', name: 'BİM Mağazalar'),
    StockItem(code: 'EREGL', name: 'Ereğli Demir Çelik'),
    StockItem(code: 'HEKTS', name: 'Hektaş'),
    StockItem(code: 'SASA', name: 'SASA Polyester'),
    StockItem(code: 'FROTO', name: 'Ford Otosan'),
    StockItem(code: 'TOASO', name: 'Tofaş'),
    StockItem(code: 'KCHOL', name: 'Koç Holding'),
    StockItem(code: 'SAHOL', name: 'Sabancı Holding'),
    StockItem(code: 'BORLS', name: 'Borlease Otomotiv'),
    StockItem(code: 'TUREX', name: 'Tureks Turizm Taşımacılık'),
    StockItem(code: 'KSTUR', name: 'KSTUR Turizm Taşımacılık'),
    StockItem(code: 'TKFEN', name: 'Tekfen Holding'),
  ];

  /// Hisse kodu listesi (sadece kodlar)
  static List<String> get stockCodes =>
      supportedStocks.map((s) => s.code).toList();

  /// Hisse ismi getir
  static String stockName(String code) =>
      supportedStocks
          .where((s) => s.code == code)
          .map((s) => s.name)
          .firstOrNull ??
      code;

  // ==================== RİSK UYARISI ====================
  static const String riskWarning =
      '⚠️ Bu uygulama sadece bilgilendirme amaçlıdır ve yatırım tavsiyesi değildir. '
      'BIST hisse yatırımları risk taşır ve sermayenizi kaybedebilirsiniz. '
      'Her zaman kendi araştırmanızı yapın ve risk yönetimi uygulayın. '
      'Geçmiş performans gelecekteki sonuçların garantisi değildir.';

  // ==================== EĞİTİM KONULARI ====================
  static const List<String> educationTopics = [
    'Teknik Analiz Temelleri',
    'RSI Göstergesi',
    'MACD Göstergesi',
    'Bollinger Bands',
    'Moving Average',
    'Risk Yönetimi',
    'Temel Analiz',
    "BIST'te Yatırım",
  ];
}

/// Hisse bilgi modeli (config seviyesi — sadece kod + isim)
class StockItem {
  final String code;
  final String name;

  const StockItem({required this.code, required this.name});
}

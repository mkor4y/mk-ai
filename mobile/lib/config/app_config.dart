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
  ///
  /// Üretim:             https://m-koray.online/api
  /// Android emülatör:   http://10.0.2.2:8000
  /// Gerçek cihaz (LAN): http://[PC-LAN-IP]:8000
  ///
  /// Değer önceliği:
  /// 1) `--dart-define=API_BASE_URL=...` (build sırasında geçilen)
  /// 2) `.env` dosyasındaki `API_BASE_URL` (assets/pubspec'e dahil)
  /// 3) Fallback: aşağıdaki üretim URL'si
  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    try {
      final fromDotenv = dotenv.env['API_BASE_URL'];
      if (fromDotenv != null && fromDotenv.isNotEmpty) return fromDotenv;
    } catch (_) {
      // dotenv henüz initialize edilmediyse veya .env asset'i yoksa sessizce fallback'e geç
    }
    return 'https://m-koray.online/api';
  }

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

  /// HTTP istek zaman aşımı (saniye).
  /// 60 sn cunku /api/market/summary yavas backend'lerde (cold start)
  /// 8 sembol icin TradingView'den veri cekiyor.
  static const int httpTimeout = 60;

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

  // ==================== HISSE SEKTORLERI ====================
  /// Her BIST hissesinin sektoru (filter chip icin).
  static const Map<String, String> stockSectors = {
    'GARAN': 'Bankacılık',
    'AKBNK': 'Bankacılık',
    'ISCTR': 'Bankacılık',
    'YKBNK': 'Bankacılık',
    'HALKB': 'Bankacılık',
    'VAKBN': 'Bankacılık',
    'THYAO': 'Ulaşım',
    'PGSUS': 'Ulaşım',
    'TUREX': 'Ulaşım',
    'KSTUR': 'Ulaşım',
    'ASELS': 'Savunma',
    'KCHOL': 'Holding',
    'SAHOL': 'Holding',
    'TKFEN': 'Holding',
    'KRDMD': 'Demir-Çelik',
    'EREGL': 'Demir-Çelik',
    'TUPRS': 'Enerji',
    'SISE': 'Cam',
    'BIMAS': 'Perakende',
    'FROTO': 'Otomotiv',
    'TOASO': 'Otomotiv',
    'DOFRB': 'Otomotiv',
    'BORLS': 'Otomotiv',
    'HEKTS': 'Tarım Kimya',
    'SASA': 'Kimya',
  };

  static String sectorOf(String code) =>
      stockSectors[code.toUpperCase()] ?? 'Diğer';

  /// Benzersiz sektor listesi (alfabetik)
  static List<String> get allSectors {
    final set = supportedStocks.map((s) => sectorOf(s.code)).toSet().toList();
    set.sort();
    return set;
  }

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

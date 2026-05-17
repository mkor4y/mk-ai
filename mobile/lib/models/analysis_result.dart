/// Kapsamlı hisse analizi sonuç modeli — /api/analyze/{code} yanıtı
library;

class AnalysisResult {
  final bool success;
  final String stockSymbol;
  final StockInfo? stockInfo;
  final TechnicalData? technicalData;
  final TradingSignals? signals;
  final String? aiAnalysis;
  final String? newsapiText;
  final NewsSummary? newsSummary;
  final String? error;

  const AnalysisResult({
    required this.success,
    required this.stockSymbol,
    this.stockInfo,
    this.technicalData,
    this.signals,
    this.aiAnalysis,
    this.newsapiText,
    this.newsSummary,
    this.error,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AnalysisResult(
      success: json['success'] as bool? ?? false,
      stockSymbol: json['stock'] as String? ?? data['stock_symbol'] as String? ?? '',
      stockInfo: data['stock_info'] != null
          ? StockInfo.fromJson(data['stock_info'] as Map<String, dynamic>)
          : null,
      technicalData: data['technical_data'] != null
          ? TechnicalData.fromJson(data['technical_data'] as Map<String, dynamic>)
          : null,
      signals: data['signals'] != null
          ? TradingSignals.fromJson(data['signals'] as Map<String, dynamic>)
          : null,
      aiAnalysis: data['ai_analysis'] as String?,
      newsapiText: data['newsapi_text'] as String?,
      newsSummary: data['news_summary'] != null
          ? NewsSummary.fromJson(data['news_summary'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String? ?? data['error'] as String?,
    );
  }
}

/// Hisse fiyat ve temel bilgileri
class StockInfo {
  final String name;
  final String symbol;
  final double currentPrice;
  final double priceChange24h;
  final double volume24h;
  final double marketCap;
  final double peRatio;
  final double dividendYield;
  final double high52w;
  final double low52w;

  const StockInfo({
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.priceChange24h,
    required this.volume24h,
    this.marketCap = 0,
    this.peRatio = 0,
    this.dividendYield = 0,
    this.high52w = 0,
    this.low52w = 0,
  });

  factory StockInfo.fromJson(Map<String, dynamic> json) {
    return StockInfo(
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      currentPrice: _toDouble(json['current_price']),
      priceChange24h: _toDouble(json['price_change_24h']),
      volume24h: _toDouble(json['volume_24h']),
      marketCap: _toDouble(json['market_cap']),
      peRatio: _toDouble(json['pe_ratio']),
      dividendYield: _toDouble(json['dividend_yield']),
      high52w: _toDouble(json['high_52w']),
      low52w: _toDouble(json['low_52w']),
    );
  }
}

/// Teknik gösterge verileri (RSI, MACD, Bollinger, ADX)
class TechnicalData {
  final double rsi;
  final double macd;
  final double macdSignal;
  final double macdHistogram;
  final double ma20;
  final double ma50;
  final double ma100;
  final double adx;
  final double bbUpper;
  final double bbMiddle;
  final double bbLower;
  final double gapPct;

  const TechnicalData({
    required this.rsi,
    required this.macd,
    this.macdSignal = 0,
    this.macdHistogram = 0,
    required this.ma20,
    required this.ma50,
    required this.ma100,
    required this.adx,
    required this.bbUpper,
    required this.bbMiddle,
    required this.bbLower,
    this.gapPct = 0,
  });

  factory TechnicalData.fromJson(Map<String, dynamic> json) {
    return TechnicalData(
      rsi: _toDouble(json['rsi']),
      macd: _toDouble(json['macd']),
      macdSignal: _toDouble(json['macd_signal']),
      macdHistogram: _toDouble(json['macd_histogram']),
      ma20: _toDouble(json['ma_20']),
      ma50: _toDouble(json['ma_50']),
      ma100: _toDouble(json['ma_100']),
      adx: _toDouble(json['adx']),
      bbUpper: _toDouble(json['bb_upper']),
      bbMiddle: _toDouble(json['bb_middle']),
      bbLower: _toDouble(json['bb_lower']),
      gapPct: _toDouble(json['gap_pct']),
    );
  }
}

/// Trading sinyalleri (AL/SAT/BEKLE, güven skoru, risk seviyesi)
class TradingSignals {
  final String rsiSignal;
  final String macdSignal;
  final String maSignal;
  final String bbSignal;
  final String volumeSignal;
  final String trendSignal;
  final String momentumSignal;
  final String overallSignal;
  final double confidence;
  final String riskLevel;
  final String signalStrength;
  final String trendRegime;
  final String trendDirection;

  const TradingSignals({
    required this.rsiSignal,
    required this.macdSignal,
    required this.maSignal,
    required this.bbSignal,
    required this.volumeSignal,
    required this.trendSignal,
    required this.momentumSignal,
    required this.overallSignal,
    required this.confidence,
    required this.riskLevel,
    required this.signalStrength,
    this.trendRegime = '',
    this.trendDirection = '',
  });

  factory TradingSignals.fromJson(Map<String, dynamic> json) {
    return TradingSignals(
      rsiSignal: json['rsi_signal'] as String? ?? 'NÖTR',
      macdSignal: json['macd_signal'] as String? ?? 'NÖTR',
      maSignal: json['ma_signal'] as String? ?? 'NÖTR',
      bbSignal: json['bb_signal'] as String? ?? 'NÖTR',
      volumeSignal: json['volume_signal'] as String? ?? 'NÖTR',
      trendSignal: json['trend_signal'] as String? ?? 'NÖTR',
      momentumSignal: json['momentum_signal'] as String? ?? 'NÖTR',
      overallSignal: json['overall_signal'] as String? ?? 'BEKLE',
      confidence: _toDouble(json['confidence']),
      riskLevel: json['risk_level'] as String? ?? 'ORTA',
      signalStrength: json['signal_strength'] as String? ?? 'ZAYIF',
      trendRegime: json['trend_regime'] as String? ?? '',
      trendDirection: json['trend_direction'] as String? ?? '',
    );
  }
}

/// Haber özeti modeli
class NewsSummary {
  final String summary;
  final List<NewsItem> latestNews;

  const NewsSummary({required this.summary, required this.latestNews});

  factory NewsSummary.fromJson(Map<String, dynamic> json) {
    return NewsSummary(
      summary: json['summary'] as String? ?? '',
      latestNews: (json['latest_news'] as List? ?? [])
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Tekil haber modeli
class NewsItem {
  final String title;
  final String source;
  final String published;
  final String link;

  const NewsItem({
    required this.title,
    required this.source,
    required this.published,
    required this.link,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] as String? ?? '',
      source: json['source'] as String? ?? '',
      published: json['published']?.toString() ?? '',
      link: json['link'] as String? ?? '',
    );
  }
}

/// Chat mesaj modeli
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? provider;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.provider,
    this.isError = false,
  });

  /// Yeni mesaj olustur (otomatik id)
  factory ChatMessage.create({
    required String content,
    required bool isUser,
    String? provider,
    bool isError = false,
  }) {
    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
      provider: provider,
      isError: isError,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'provider': provider,
        'isError': isError,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: (j['id'] as String?) ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        content: (j['content'] as String?) ?? '',
        isUser: (j['isUser'] as bool?) ?? false,
        timestamp:
            DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.now(),
        provider: j['provider'] as String?,
        isError: (j['isError'] as bool?) ?? false,
      );
}

/// JSON'dan double parse — null/string/int güvenli
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

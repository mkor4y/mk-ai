/// MK AI - Haber modeli
///
/// /api/news endpoint'inden donen haber listesi icin model.
/// Sentiment, kaydetme ve okundu state'leri burada degil; provider'larda tutulur.
library;

import '../config/app_config.dart';

enum NewsSentiment { positive, negative, neutral }

NewsSentiment _parseSentiment(String? s) {
  switch (s?.toLowerCase()) {
    case 'positive':
      return NewsSentiment.positive;
    case 'negative':
      return NewsSentiment.negative;
    default:
      return NewsSentiment.neutral;
  }
}

class NewsArticle {
  final String title;
  final String description;
  final String link;
  final String published;
  final DateTime? publishedAt;
  final String source;
  final String? image;
  final NewsSentiment sentiment;
  final double sentimentScore;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.link,
    required this.published,
    this.publishedAt,
    required this.source,
    this.image,
    this.sentiment = NewsSentiment.neutral,
    this.sentimentScore = 0.0,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    DateTime? parsed;
    final iso = json['published_iso'] as String?;
    if (iso != null && iso.isNotEmpty) {
      parsed = DateTime.tryParse(iso);
    }
    return NewsArticle(
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      link: json['link'] as String? ?? '',
      published: json['published'] as String? ?? '',
      publishedAt: parsed?.toLocal(),
      source: json['source'] as String? ?? '',
      image: _validImage(json['image'] as String?),
      sentiment: _parseSentiment(json['sentiment'] as String?),
      sentimentScore: (json['sentiment_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Kaydedilenler icin yerel JSON formatina cevir
  Map<String, dynamic> toLocalJson() => {
        'title': title,
        'description': description,
        'link': link,
        'published': published,
        'published_iso': publishedAt?.toIso8601String() ?? '',
        'source': source,
        'image': image,
        'sentiment': sentiment.name,
        'sentiment_score': sentimentScore,
      };

  /// Bos veya gecersiz image URL'lerini null'a duser
  static String? _validImage(String? url) {
    if (url == null) return null;
    final t = url.trim();
    if (t.isEmpty) return null;
    if (!t.startsWith('http')) return null;
    return t;
  }

  bool get hasImage => image != null && image!.isNotEmpty;

  /// Bu haberde hisse kodu geciyor mu?
  /// (Hisse bazli filter chip icin)
  List<String> get matchedStockCodes {
    final text = '$title $description'.toLowerCase();
    return AppConfig.stockCodes
        .where((code) => text.contains(code.toLowerCase()))
        .toList();
  }

  /// Genel kategori (Filter chip icin)
  NewsCategory get category {
    final source = this.source.toLowerCase();
    // Global / Ingilizce kaynaklar
    const global = ['bbc', 'marketwatch', 'cnbc', 'reuters', 'bloomberg_us'];
    if (global.any((g) => source.contains(g))) return NewsCategory.global;
    if (matchedStockCodes.isNotEmpty) return NewsCategory.stockSpecific;
    return NewsCategory.bist;
  }
}

enum NewsCategory { all, bist, global, stockSpecific }

extension NewsCategoryLabel on NewsCategory {
  String get label {
    switch (this) {
      case NewsCategory.all:
        return 'Tümü';
      case NewsCategory.bist:
        return 'BIST';
      case NewsCategory.global:
        return 'Global';
      case NewsCategory.stockSpecific:
        return 'Hisse';
    }
  }
}

/// Piyasa özeti modeli — /api/market/summary yanıtı
library;

class MarketSummary {
  final List<MarketIndex> indices;
  final List<WatchlistItem> watchlist;
  final String timestamp;

  const MarketSummary({
    required this.indices,
    required this.watchlist,
    required this.timestamp,
  });

  factory MarketSummary.fromJson(Map<String, dynamic> json) {
    return MarketSummary(
      indices: (json['indices'] as List? ?? [])
          .map((e) => MarketIndex.fromJson(e as Map<String, dynamic>))
          .toList(),
      watchlist: (json['watchlist'] as List? ?? [])
          .map((e) => WatchlistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}

class MarketIndex {
  final String name;
  final String value;
  final String change;
  final bool up;

  const MarketIndex({
    required this.name,
    required this.value,
    required this.change,
    required this.up,
  });

  factory MarketIndex.fromJson(Map<String, dynamic> json) {
    return MarketIndex(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '0',
      change: json['change'] as String? ?? '+0.00%',
      up: json['up'] as bool? ?? true,
    );
  }
}

class WatchlistItem {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool up;

  const WatchlistItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.up,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: json['price'] as String? ?? '0',
      change: json['change'] as String? ?? '+0.00%',
      up: json['up'] as bool? ?? true,
    );
  }
}

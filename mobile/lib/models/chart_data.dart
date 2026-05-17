/// MK AI - Grafik veri modelleri
///
/// /api/chart/{stock_code}?range=1A endpoint'inden donen OHLCV cevabini parse eder.
library;

class ChartData {
  final bool success;
  final String stock;
  final String range;
  final List<Candle> candles;
  final String? error;

  const ChartData({
    required this.success,
    required this.stock,
    required this.range,
    required this.candles,
    this.error,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      success: json['success'] as bool? ?? false,
      stock: json['stock'] as String? ?? '',
      range: json['range'] as String? ?? '1A',
      candles: (json['candles'] as List? ?? [])
          .map((e) => Candle.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
    );
  }

  bool get isEmpty => candles.isEmpty;

  double get minPrice {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
  }

  double get maxPrice {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
  }

  /// Yuzde olarak donem getirisi: (son kapanis / ilk kapanis - 1) * 100
  double get periodChangePct {
    if (candles.length < 2) return 0;
    final first = candles.first.close;
    final last = candles.last.close;
    if (first == 0) return 0;
    return (last / first - 1) * 100;
  }
}

class Candle {
  /// Unix epoch milliseconds
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory Candle.fromJson(Map<String, dynamic> json) {
    return Candle(
      timestamp: _toInt(json['t']),
      open: _toDouble(json['o']),
      high: _toDouble(json['h']),
      low: _toDouble(json['l']),
      close: _toDouble(json['c']),
      volume: _toDouble(json['v']),
    );
  }

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(timestamp);
}

/// Desteklenen zaman araliklari
class ChartRange {
  static const String oneWeek = '1H';
  static const String oneMonth = '1A';
  static const String threeMonths = '3A';
  static const String sixMonths = '6A';
  static const String oneYear = '1Y';

  static const List<({String code, String label})> all = [
    (code: oneWeek, label: '1H'),
    (code: oneMonth, label: '1A'),
    (code: threeMonths, label: '3A'),
    (code: sixMonths, label: '6A'),
    (code: oneYear, label: '1Y'),
  ];
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

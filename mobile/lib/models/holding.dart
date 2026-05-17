/// MK AI - Portfoy Pozisyonu (Holding) modeli
///
/// Kullanicinin elinde tuttugu bir hisse pozisyonunu temsil eder.
/// SharedPreferences'a JSON olarak yazilir.
library;

class Holding {
  /// BIST hisse kodu (uppercase, suffix yok). Orn: THYAO
  final String symbol;

  /// Sirket adi (gosterim icin, opsiyonel)
  final String name;

  /// Sahip olunan adet
  final double quantity;

  /// Birim basina ortalama maliyet (TL)
  final double avgCost;

  /// Pozisyonun olusturuldugu tarih (ms epoch)
  final int addedAt;

  /// Kullanici notu (opsiyonel)
  final String note;

  const Holding({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgCost,
    required this.addedAt,
    this.note = '',
  });

  /// Yeni pozisyon olusturur, addedAt otomatik atanir.
  factory Holding.create({
    required String symbol,
    String name = '',
    required double quantity,
    required double avgCost,
    String note = '',
  }) {
    return Holding(
      symbol: symbol.toUpperCase().trim(),
      name: name.trim(),
      quantity: quantity,
      avgCost: avgCost,
      addedAt: DateTime.now().millisecondsSinceEpoch,
      note: note.trim(),
    );
  }

  /// Toplam maliyet (quantity * avgCost)
  double get totalCost => quantity * avgCost;

  /// Verilen guncel fiyata gore toplam deger
  double valueAt(double currentPrice) => quantity * currentPrice;

  /// Verilen guncel fiyata gore kar/zarar (TL)
  double pnlAt(double currentPrice) => valueAt(currentPrice) - totalCost;

  /// Verilen guncel fiyata gore kar/zarar yuzdesi (%)
  double pnlPctAt(double currentPrice) {
    if (totalCost <= 0) return 0;
    return ((currentPrice - avgCost) / avgCost) * 100;
  }

  Holding copyWith({
    String? symbol,
    String? name,
    double? quantity,
    double? avgCost,
    int? addedAt,
    String? note,
  }) =>
      Holding(
        symbol: symbol ?? this.symbol,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        avgCost: avgCost ?? this.avgCost,
        addedAt: addedAt ?? this.addedAt,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'quantity': quantity,
        'avgCost': avgCost,
        'addedAt': addedAt,
        'note': note,
      };

  factory Holding.fromJson(Map<String, dynamic> json) => Holding(
        symbol: (json['symbol'] as String? ?? '').toUpperCase(),
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num? ?? 0).toDouble(),
        avgCost: (json['avgCost'] as num? ?? 0).toDouble(),
        addedAt: (json['addedAt'] as num? ??
                DateTime.now().millisecondsSinceEpoch)
            .toInt(),
        note: json['note'] as String? ?? '',
      );
}

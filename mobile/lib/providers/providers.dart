/// MK AI - Riverpod Provider'lar
///
/// Uygulamanın tüm state management provider'ları tek dosyada.
/// Dashboard verisi, analiz sonuçları ve chat mesajları.
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/market_summary.dart';
import '../models/analysis_result.dart';
import '../models/chart_data.dart';
import '../models/news_item.dart';
import '../models/holding.dart';
import '../services/api_client.dart';
import '../services/stock_service.dart' show StockService, StockQuote;
import '../services/chat_service.dart';

// ==================== SERVİS PROVIDER'LARI ====================

final stockServiceProvider = Provider<StockService>((ref) => StockService());
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

// ==================== PİYASA VERİSİ ====================

/// Dashboard piyasa özeti (auto-refresh destekli)
final marketSummaryProvider = FutureProvider.autoDispose<MarketSummary>((ref) {
  final service = ref.read(stockServiceProvider);
  return service.getMarketSummary();
});

// ==================== HİSSE ANALİZİ ====================

/// Hisse analizi — family provider (hisse koduna göre)
final analysisProvider =
    FutureProvider.autoDispose.family<AnalysisResult, String>((ref, stockCode) {
  final service = ref.read(stockServiceProvider);
  return service.analyzeStock(stockCode);
});

/// Hisse grafik verisi (range degistikce yeni istek atar)
typedef ChartRequest = ({String code, String range});

final chartDataProvider =
    FutureProvider.autoDispose.family<ChartData, ChartRequest>((ref, req) {
  final service = ref.read(stockServiceProvider);
  return service.getChartData(req.code, req.range);
});

/// Analiz ekraninda secili zaman araligi (varsayilan 1A)
final selectedChartRangeProvider =
    StateProvider.autoDispose.family<String, String>(
  (ref, stockCode) => ChartRange.oneMonth,
);

// ==================== HABERLER ====================

/// Tum haberleri ceken provider (auto-refresh destekli)
final newsListProvider =
    FutureProvider.autoDispose<List<NewsArticle>>((ref) async {
  try {
    final dio = ApiClient.instance;
    final response = await dio.get('/api/news');
    final json = response.data as Map<String, dynamic>;
    if (json['success'] != true) {
      throw Exception(json['error'] ?? 'Haberler alınamadı');
    }
    final list = (json['news'] as List? ?? [])
        .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  } on DioException catch (e) {
    throw Exception(e.message ?? 'Bağlantı hatası');
  }
});

/// Haber ekraninda secili filtre kategorisi
final selectedNewsCategoryProvider =
    StateProvider<NewsCategory>((ref) => NewsCategory.all);

/// Haber arama metni (alt cizgi ve aksan-insensitive aranir)
final newsSearchQueryProvider = StateProvider<String>((ref) => '');

/// Arka planda otomatik yenileme (her N saniye newsListProvider'i invalidate eder)
/// Sadece haber sekmesindeyken aktif olmali — `keepAlive` olmadigi icin sayfa
/// kapatildiginda otomatik durur.
final newsAutoRefreshProvider = Provider.autoDispose<void>((ref) {
  const refreshSeconds = 300; // 5 dakika
  final timer = Timer.periodic(const Duration(seconds: refreshSeconds), (_) {
    ref.invalidate(newsListProvider);
  });
  ref.onDispose(timer.cancel);
});

// ==================== KAYDEDILEN HABERLER ====================

/// Kullanicinin kaydettigi haberler (shared_preferences ile kalici, JSON list).
/// Benzersizlik icin haber.link kullanilir.
final bookmarkedNewsProvider =
    StateNotifierProvider<BookmarkedNewsNotifier, List<NewsArticle>>(
  (ref) => BookmarkedNewsNotifier(),
);

class BookmarkedNewsNotifier extends StateNotifier<List<NewsArticle>> {
  static const _storageKey = 'mk_ai_bookmarked_news';

  BookmarkedNewsNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      state = const [];
      return;
    }
    try {
      final decoded = jsonDecode(raw) as List;
      state = decoded
          .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(state.map((n) => n.toLocalJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  bool isBookmarked(String link) => state.any((n) => n.link == link);

  Future<void> toggle(NewsArticle article) async {
    if (article.link.isEmpty) return;
    if (isBookmarked(article.link)) {
      state = state.where((n) => n.link != article.link).toList();
    } else {
      // En yeni kaydedilen ustte olsun
      state = [article, ...state];
    }
    await _persist();
  }

  Future<void> remove(String link) async {
    if (!isBookmarked(link)) return;
    state = state.where((n) => n.link != link).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    state = const [];
    await _persist();
  }
}

// ==================== OKUNAN HABERLER ====================

/// Kullanicinin tikladigi (okudugu) haberlerin link seti.
/// Cihaza kalici (shared_preferences) yazilir, UI'da solgun gosterilir.
final readNewsProvider =
    StateNotifierProvider<ReadNewsNotifier, Set<String>>(
  (ref) => ReadNewsNotifier(),
);

class ReadNewsNotifier extends StateNotifier<Set<String>> {
  static const _storageKey = 'mk_ai_read_news';
  static const _maxKeep = 1000; // FIFO sinir

  ReadNewsNotifier() : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey) ?? const [];
    state = list.toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    var list = state.toList();
    if (list.length > _maxKeep) {
      list = list.sublist(list.length - _maxKeep);
    }
    await prefs.setStringList(_storageKey, list);
  }

  bool isRead(String link) => state.contains(link);

  Future<void> markRead(String link) async {
    if (link.isEmpty || state.contains(link)) return;
    state = {...state, link};
    await _persist();
  }

  Future<void> clearAll() async {
    state = const {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

// ==================== CHAT ====================

/// Chat mesaj listesi (kalici - shared_preferences)
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier(ref);
});

/// Chat yükleniyor mu?
final chatLoadingProvider = StateProvider<bool>((ref) => false);

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  static const _storageKey = 'mk_ai_chat_history';
  static const _maxHistory = 200;

  ChatMessagesNotifier(this._ref) : super(const []) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        state = const [];
        return;
      }
      final decoded = jsonDecode(raw) as List;
      state = decoded
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var list = state;
      if (list.length > _maxHistory) {
        list = list.sublist(list.length - _maxHistory);
      }
      final raw = jsonEncode(list.map((m) => m.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (_) {
      // sessiz fail; UI calismaya devam etsin
    }
  }

  /// Tum mesajlari sil
  Future<void> clearMessages() async {
    state = const [];
    await _persist();
  }

  /// Son AI yanitini tekrar uret (kullanici mesajini tekrar gonderir)
  Future<void> regenerateLastResponse() async {
    // Son kullanici mesajini bul
    final lastUserMsg = state.lastWhere(
      (m) => m.isUser,
      orElse: () => ChatMessage.create(content: '', isUser: true),
    );
    if (lastUserMsg.content.isEmpty) return;

    // Son AI mesajini sil (eger varsa)
    if (state.isNotEmpty && !state.last.isUser) {
      state = state.sublist(0, state.length - 1);
    }

    // Yeniden cevap al (kullanici mesajini eklemeden)
    await _fetchResponse(lastUserMsg.content);
  }

  /// Kullanıcı mesajı gönder ve AI yanıtı al
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Kullanıcı mesajını ekle
    final userMsg = ChatMessage.create(content: text.trim(), isUser: true);
    state = [...state, userMsg];
    await _persist();

    await _fetchResponse(text);
  }

  Future<void> _fetchResponse(String text) async {
    _ref.read(chatLoadingProvider.notifier).state = true;

    try {
      final service = _ref.read(chatServiceProvider);
      final response = await service.sendMessage(text);

      state = [
        ...state,
        ChatMessage.create(
          content: response.response,
          isUser: false,
          provider: response.provider,
          isError: !response.success,
        ),
      ];
    } catch (e) {
      state = [
        ...state,
        ChatMessage.create(
          content: '❌ Bir hata oluştu: $e',
          isUser: false,
          provider: 'error',
          isError: true,
        ),
      ];
    } finally {
      _ref.read(chatLoadingProvider.notifier).state = false;
      await _persist();
    }
  }
}

// ==================== FAVORILER (kalici depo) ====================

/// Favori hisse kodlari listesi (shared_preferences ile kalici)
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<List<String>> {
  static const _storageKey = 'mk_ai_favorites';

  FavoritesNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_storageKey) ?? const [];
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, state);
  }

  bool isFavorite(String stockCode) =>
      state.contains(stockCode.toUpperCase());

  Future<void> toggle(String stockCode) async {
    final code = stockCode.toUpperCase();
    state = state.contains(code)
        ? state.where((c) => c != code).toList()
        : [...state, code];
    await _persist();
  }

  Future<void> remove(String stockCode) async {
    final code = stockCode.toUpperCase();
    if (!state.contains(code)) return;
    state = state.where((c) => c != code).toList();
    await _persist();
  }
}

// ==================== TEMA ====================

/// Seçili bottom nav tab index
final selectedTabProvider = StateProvider<int>((ref) => 0);

// ==================== KULLANICI PROFILI ====================

class UserProfile {
  final String displayName;
  final int avatarColorIndex;

  const UserProfile({
    required this.displayName,
    required this.avatarColorIndex,
  });

  UserProfile copyWith({String? displayName, int? avatarColorIndex}) =>
      UserProfile(
        displayName: displayName ?? this.displayName,
        avatarColorIndex: avatarColorIndex ?? this.avatarColorIndex,
      );

  /// Avatar harfini hesaplar (ad bos ise 'M')
  String get initial {
    final t = displayName.trim();
    if (t.isEmpty) return 'M';
    return t[0].toUpperCase();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (ref) => UserProfileNotifier(),
);

class UserProfileNotifier extends StateNotifier<UserProfile> {
  static const _kName = 'mk_ai_user_name';
  static const _kColor = 'mk_ai_user_avatar_color';

  UserProfileNotifier()
      : super(const UserProfile(displayName: 'Misafir', avatarColorIndex: 0)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserProfile(
      displayName: prefs.getString(_kName) ?? 'Misafir',
      avatarColorIndex: prefs.getInt(_kColor) ?? 0,
    );
  }

  Future<void> setName(String name) async {
    state = state.copyWith(displayName: name.trim());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, name.trim());
  }

  Future<void> setAvatarColor(int idx) async {
    state = state.copyWith(avatarColorIndex: idx);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kColor, idx);
  }
}

// ==================== HISSE FIYATLARI (BATCH) ====================

/// Verilen sembol listesi icin guncel fiyatlari ceker.
/// Periyodik refresh icin autoDispose + 60sn lokal cache.
final stockQuotesProvider = FutureProvider.autoDispose
    .family<Map<String, StockQuote>, List<String>>((ref, codes) async {
  if (codes.isEmpty) return const {};
  final service = ref.read(stockServiceProvider);
  return service.getQuotes(codes);
});

// ==================== PORTFOY (HOLDINGS) ====================

/// Kullanicinin portfoyundeki pozisyonlar (kalici).
/// Listenin sirasini bozmadan ekle/duzenle/sil yapar.
final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, List<Holding>>(
  (ref) => PortfolioNotifier(),
);

class PortfolioNotifier extends StateNotifier<List<Holding>> {
  static const _storageKey = 'mk_ai_portfolio';

  PortfolioNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      state = const [];
      return;
    }
    try {
      final decoded = jsonDecode(raw) as List;
      state = decoded
          .map((e) => Holding.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(state.map((h) => h.toJson()).toList()),
    );
  }

  /// Yeni pozisyon ekler. Ayni sembol zaten varsa adetleri birlestirir
  /// ve ortalama maliyeti agirlikli hesaplar (DCA mantigi).
  Future<void> add(Holding h) async {
    final idx = state.indexWhere((x) => x.symbol == h.symbol);
    if (idx >= 0) {
      final existing = state[idx];
      final totalQty = existing.quantity + h.quantity;
      final weightedCost = totalQty <= 0
          ? h.avgCost
          : (existing.totalCost + h.totalCost) / totalQty;
      final updated = existing.copyWith(
        quantity: totalQty,
        avgCost: weightedCost,
        name: h.name.isNotEmpty ? h.name : existing.name,
      );
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == idx) updated else state[i],
      ];
    } else {
      state = [...state, h];
    }
    await _persist();
  }

  /// Mevcut pozisyonu komple gunceller (sembol degisemez).
  Future<void> update(Holding h) async {
    state = [
      for (final x in state)
        if (x.symbol == h.symbol) h else x,
    ];
    await _persist();
  }

  Future<void> remove(String symbol) async {
    final s = symbol.toUpperCase();
    state = state.where((h) => h.symbol != s).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

// ==================== VERI YONETIMI (RESET) ====================

/// Tum uygulama verisini siler: favoriler, kaydedilen haberler,
/// okunmus haberler, sohbet gecmisi, kullanici profili, portfoy.
Future<void> resetAllLocalData(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  ref.invalidate(favoritesProvider);
  ref.invalidate(bookmarkedNewsProvider);
  ref.invalidate(readNewsProvider);
  ref.invalidate(chatMessagesProvider);
  ref.invalidate(userProfileProvider);
  ref.invalidate(portfolioProvider);
}

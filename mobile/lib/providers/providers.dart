/// MK AI - Riverpod Provider'lar
///
/// Uygulamanın tüm state management provider'ları tek dosyada.
/// Dashboard verisi, analiz sonuçları ve chat mesajları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_summary.dart';
import '../models/analysis_result.dart';
import '../services/stock_service.dart';
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

// ==================== CHAT ====================

/// Chat mesaj listesi
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier(ref);
});

/// Chat yükleniyor mu?
final chatLoadingProvider = StateProvider<bool>((ref) => false);

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  ChatMessagesNotifier(this._ref)
      : super([
          // Karşılama mesajı
          ChatMessage(
            content:
                '🤖 Merhaba! Ben MK AI, Borsa İstanbul analiz asistanınım.\n\n'
                '📊 Hisse analizi yapmak için hisse kodunu yazın (örn: THYAO)\n'
                '📚 Eğitim konuları için "RSI nedir?" gibi sorular sorun\n'
                '💬 Her türlü finans sorunuzu yanıtlayabilirim!',
            isUser: false,
            timestamp: DateTime.now(),
            provider: 'system',
          ),
        ]);

  /// Kullanıcı mesajı gönder ve AI yanıtı al
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Kullanıcı mesajını ekle
    state = [
      ...state,
      ChatMessage(
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    ];

    // Yükleniyor state'i
    _ref.read(chatLoadingProvider.notifier).state = true;

    try {
      final service = _ref.read(chatServiceProvider);
      final response = await service.sendMessage(text);

      // AI yanıtını ekle
      state = [
        ...state,
        ChatMessage(
          content: response.response,
          isUser: false,
          timestamp: DateTime.now(),
          provider: response.provider,
        ),
      ];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(
          content: '❌ Bir hata oluştu: $e',
          isUser: false,
          timestamp: DateTime.now(),
          provider: 'error',
        ),
      ];
    } finally {
      _ref.read(chatLoadingProvider.notifier).state = false;
    }
  }
}

// ==================== TEMA ====================

/// Seçili bottom nav tab index
final selectedTabProvider = StateProvider<int>((ref) => 0);

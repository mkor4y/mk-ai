/// MK AI - Pro Analysis Detail (Minimalist / Pure Black)
///
/// Buyuk yenileme:
///   - Fiyat ust bolumune Hacim / P/E / 24s degisim mini-stat satiri
///   - AI Karari: buyuk renkli karar karti + guven cubuk + sinyal gucu yildizlari + risk chip
///   - Teknik gostergeler: RSI bar (0-100 zonlu), MACD durumu, ADX trend gucu, MA20/MA50 cross
///   - Favori butonu: yildiz, shared_preferences'a yazar
///   - Pull-to-refresh
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/analysis_result.dart';
import '../../models/chart_data.dart';

class AnalysisScreen extends ConsumerWidget {
  final String stockCode;
  const AnalysisScreen({super.key, required this.stockCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisProvider(stockCode));
    final isFav = ref
        .watch(favoritesProvider)
        .contains(stockCode.toUpperCase());

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          stockCode.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isFav ? 'Favorilerden çıkar' : 'Favorilere ekle',
            icon: Icon(
              isFav ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFav ? AppTheme.stockUp : AppTheme.textPrimary,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggle(stockCode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 1200),
                  backgroundColor: AppTheme.bgTertiary,
                  content: Text(
                    isFav
                        ? '${stockCode.toUpperCase()} favorilerden çıkarıldı'
                        : '${stockCode.toUpperCase()} favorilere eklendi',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.stockUp,
        backgroundColor: AppTheme.bgTertiary,
        onRefresh: () async {
          ref.invalidate(analysisProvider(stockCode));
          ref.invalidate(chartDataProvider(
              (code: stockCode, range: ref.read(selectedChartRangeProvider(stockCode)))));
          await ref.read(analysisProvider(stockCode).future);
        },
        child: analysisAsync.when(
          loading: () => _buildLoading(),
          error: (e, _) => _buildError(
              e.toString(), () => ref.invalidate(analysisProvider(stockCode))),
        data: (result) {
          if (!result.success || result.stockInfo == null) {
              return Center(
                child: Text(
                  result.error ?? 'Veri çekilemedi',
                  style: const TextStyle(color: AppTheme.stockDown),
                ),
              );
          }
          return _buildContent(result);
        },
        ),
      ),
    );
  }

  Widget _buildContent(AnalysisResult result) {
    final info = result.stockInfo!;
    final signals = result.signals;
    final tech = result.technicalData;
    final isUp = info.priceChange24h >= 0;
    final themeColor = isUp ? AppTheme.stockUp : AppTheme.stockDown;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // ============ FIYAT HEADER ============
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.name,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_formatPrice(info.currentPrice)} ₺',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2.0,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: themeColor,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${isUp ? "+" : ""}${info.priceChange24h.toStringAsFixed(2)}% Bugün',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(),
        ),

        // ============ HIZLI ISTATISTIKLER ============
        _QuickStatsRow(info: info)
            .animate(delay: 80.ms)
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0),

        const SizedBox(height: 8),

        // ============ FIYAT GRAFIGI ============
        _PriceChartSection(stockCode: stockCode),

        const SizedBox(height: 32),

        // ============ AI KARAR KARTI ============
        if (signals != null) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _AiDecisionCard(signals: signals)
                .animate(delay: 200.ms)
                .fadeIn()
                .slideY(begin: 0.1, end: 0),
          ),
                const SizedBox(height: 32),
              ],

        // ============ TEKNIK GOSTERGELER (gorsel) ============
              if (tech != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader('Teknik Göstergeler'),
                _RsiIndicator(value: tech.rsi)
                    .animate(delay: 300.ms)
                    .fadeIn()
                    .slideX(begin: -0.05, end: 0),
                const SizedBox(height: 20),
                _MacdIndicator(
                  macd: tech.macd,
                  signal: tech.macdSignal,
                  histogram: tech.macdHistogram,
                )
                    .animate(delay: 350.ms)
                    .fadeIn()
                    .slideX(begin: -0.05, end: 0),
                const SizedBox(height: 20),
                _AdxMeter(
                  value: tech.adx,
                  regime: signals?.trendRegime ?? '-',
                  direction: signals?.trendDirection ?? '-',
                )
                    .animate(delay: 400.ms)
                    .fadeIn()
                    .slideX(begin: -0.05, end: 0),
                const SizedBox(height: 20),
                _MaCrossIndicator(
                  currentPrice: info.currentPrice,
                  ma20: tech.ma20,
                  ma50: tech.ma50,
                  ma100: tech.ma100,
                )
                    .animate(delay: 450.ms)
                    .fadeIn()
                    .slideX(begin: -0.05, end: 0),
                const SizedBox(height: 20),
                _BollingerIndicator(
                  upper: tech.bbUpper,
                  middle: tech.bbMiddle,
                  lower: tech.bbLower,
                  current: info.currentPrice,
                )
                    .animate(delay: 500.ms)
                    .fadeIn()
                    .slideX(begin: -0.05, end: 0),
                const SizedBox(height: 32),
              ],
            ),
          ),
              ],

        // ============ AI YORUM ============
              if (result.aiAnalysis != null && result.aiAnalysis!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader('AI Yorumu'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    result.aiAnalysis!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ).animate(delay: 600.ms).fadeIn(),
        ],

        // ============ HABER OZETI ============
        if (result.newsSummary != null &&
            result.newsSummary!.summary.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader('Haber Özeti'),
                Text(
                  result.newsSummary!.summary,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ).animate(delay: 700.ms).fadeIn(),
        ],
      ],
    );
  }

  Widget _buildLoading() {
    return ListView(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmer(160, 14),
              const SizedBox(height: 12),
              _shimmer(200, 48),
              const SizedBox(height: 12),
              _shimmer(120, 14),
              const SizedBox(height: 32),
              _shimmer(double.infinity, 230, radius: 12),
              const SizedBox(height: 32),
              _shimmer(double.infinity, 140, radius: 14),
              const SizedBox(height: 24),
              ...List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _shimmer(double.infinity, 60, radius: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmer(double width, double height, {double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 800.ms, curve: Curves.easeInOut);
  }

  Widget _buildError(String msg, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            const Icon(Icons.warning_rounded,
                size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
        ],
        ),
      ),
    );
  }

  static String _formatPrice(double v) {
    if (v >= 100000) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  static String formatVolume(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}Mr';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ==================== ORTAK ALT WIDGETLAR ====================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final StockInfo info;
  const _QuickStatsRow({required this.info});

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String)>[
      ('Hacim 24s', AnalysisScreen.formatVolume(info.volume24h)),
      if (info.marketCap > 0)
        ('Piyasa Değ.', '${AnalysisScreen.formatVolume(info.marketCap)} ₺'),
      if (info.peRatio > 0) ('F/K Oranı', info.peRatio.toStringAsFixed(2)),
      if (info.dividendYield > 0)
        ('Temettü', '%${info.dividendYield.toStringAsFixed(2)}'),
    ];

    if (stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stats.map((s) {
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    s.$1,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.$2,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ==================== AI KARAR KARTI ====================

class _AiDecisionCard extends StatelessWidget {
  final TradingSignals signals;
  const _AiDecisionCard({required this.signals});

  @override
  Widget build(BuildContext context) {
    final signalUpper = signals.overallSignal.toUpperCase();
    final color = AppTheme.signalColor(signalUpper);
    final icon = _signalIcon(signalUpper);
    final label = _humanLabel(signalUpper);
    final confidence = signals.confidence.clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI KARARI',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              _RiskChip(level: signals.riskLevel),
            ],
          ),
          const SizedBox(height: 20),

          // Guven cubugu
          Row(
            children: [
              const Text(
                'Güven',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '%${confidence.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: AppTheme.bgTertiary,
                ),
                FractionallySizedBox(
                  widthFactor: confidence / 100,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sinyal gucu (yildizlar)
          Row(
            children: [
              const Text(
                'Sinyal Gücü',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              ..._signalStrengthStars(signals.signalStrength, color),
              const SizedBox(width: 8),
              Text(
                signals.signalStrength,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _signalIcon(String s) {
    if (s.contains('AL') || s.contains('BUY')) return Icons.trending_up_rounded;
    if (s.contains('SAT') || s.contains('SELL')) return Icons.trending_down_rounded;
    return Icons.remove_rounded;
  }

  String _humanLabel(String s) {
    if (s.contains('GUCLU AL') || s.contains('STRONG BUY')) return 'GÜÇLÜ AL';
    if (s.contains('GUCLU SAT') || s.contains('STRONG SELL')) return 'GÜÇLÜ SAT';
    if (s.contains('AL') || s.contains('BUY')) return 'AL';
    if (s.contains('SAT') || s.contains('SELL')) return 'SAT';
    return 'BEKLE';
  }

  List<Widget> _signalStrengthStars(String strength, Color color) {
    final upper = strength.toUpperCase();
    int filled = 1;
    if (upper.contains('ÇOK GÜÇLÜ') || upper.contains('VERY STRONG')) {
      filled = 5;
    } else if (upper.contains('GÜÇLÜ') || upper.contains('STRONG')) {
      filled = 4;
    } else if (upper.contains('ORTA') || upper.contains('MEDIUM')) {
      filled = 3;
    } else if (upper.contains('ZAYIF') || upper.contains('WEAK')) {
      filled = 2;
    }
    return List.generate(
      5,
      (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Icon(
          i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: i < filled ? color : AppTheme.textMuted,
          size: 14,
        ),
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  final String level;
  const _RiskChip({required this.level});

  @override
  Widget build(BuildContext context) {
    final upper = level.toUpperCase();
    Color color = AppTheme.stockNeutral;
    if (upper.contains('YÜKSEK') || upper.contains('HIGH')) {
      color = AppTheme.stockDown;
    } else if (upper.contains('DÜŞÜK') || upper.contains('LOW')) {
      color = AppTheme.stockUp;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'RİSK',
            style: TextStyle(
              fontSize: 9,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            level.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TEKNIK GOSTERGELER ====================

class _IndicatorTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  const _IndicatorTile({
    required this.label,
    this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RsiIndicator extends StatelessWidget {
  final double value;
  const _RsiIndicator({required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 100.0);
    final (label, color) = _zone(v);

    return _IndicatorTile(
      label: 'RSI',
      subtitle: '14 periyot',
      trailing: _ValueChip(value: v.toStringAsFixed(1), color: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              return SizedBox(
                height: 28,
                child: Stack(
                  children: [
                    // Gradient track
                    Positioned(
                      top: 11,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.stockUp,
                              AppTheme.stockNeutral,
                              AppTheme.stockDown,
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Marker
                    Positioned(
                      left: (c.maxWidth - 12) * (v / 100),
                      top: 6,
                      child: Container(
                        width: 12,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.textPrimary,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Aşırı Satım', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              Text('Nötr', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              Text('Aşırı Alım', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _zone(double v) {
    if (v <= 30) return ('Aşırı satım — yükseliş baskısı oluşabilir', AppTheme.stockUp);
    if (v >= 70) return ('Aşırı alım — düşüş baskısı oluşabilir', AppTheme.stockDown);
    if (v >= 50) return ('Nötr, hafif yükseliş eğilimi', AppTheme.stockNeutral);
    return ('Nötr, hafif düşüş eğilimi', AppTheme.stockNeutral);
  }
}

class _MacdIndicator extends StatelessWidget {
  final double macd;
  final double signal;
  final double histogram;
  const _MacdIndicator({
    required this.macd,
    required this.signal,
    required this.histogram,
  });

  @override
  Widget build(BuildContext context) {
    final isBullish = histogram >= 0;
    final color = isBullish ? AppTheme.stockUp : AppTheme.stockDown;
    final label = isBullish ? 'Yükseliş momentumu' : 'Düşüş momentumu';

    return _IndicatorTile(
      label: 'MACD',
      subtitle: '12 / 26 / 9',
      trailing: _ValueChip(value: macd.toStringAsFixed(3), color: color),
      child: Column(
        children: [
          Row(
            children: [
              _MacdMini('MACD', macd, color),
              const SizedBox(width: 12),
              _MacdMini('Sinyal', signal, AppTheme.textSecondary),
              const SizedBox(width: 12),
              _MacdMini('Histogram', histogram, color),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isBullish ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacdMini extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MacdMini(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.toStringAsFixed(3),
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdxMeter extends StatelessWidget {
  final double value;
  final String regime;
  final String direction;
  const _AdxMeter({
    required this.value,
    required this.regime,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 60.0);
    final (label, color) = _strength(v);
    final dirColor = direction.toUpperCase().contains('YUKSEL') ||
            direction.toUpperCase().contains('UP')
        ? AppTheme.stockUp
        : direction.toUpperCase().contains('DUSUS') ||
                direction.toUpperCase().contains('DOWN')
            ? AppTheme.stockDown
            : AppTheme.stockNeutral;

    return _IndicatorTile(
      label: 'ADX',
      subtitle: 'Trend gücü',
      trailing: _ValueChip(value: value.toStringAsFixed(1), color: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.bgTertiary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (v / 60).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              if (regime.isNotEmpty && regime != '-')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.bgTertiary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    regime,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              if (direction.isNotEmpty && direction != '-')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: dirColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    direction,
                    style: TextStyle(
                      fontSize: 10,
                      color: dirColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  (String, Color) _strength(double v) {
    if (v < 20) return ('Trend yok / zayıf', AppTheme.stockNeutral);
    if (v < 25) return ('Trend oluşuyor', AppTheme.textSecondary);
    if (v < 40) return ('Güçlü trend', AppTheme.stockUp);
    return ('Çok güçlü trend', AppTheme.stockUp);
  }
}

class _MaCrossIndicator extends StatelessWidget {
  final double currentPrice;
  final double ma20;
  final double ma50;
  final double ma100;
  const _MaCrossIndicator({
    required this.currentPrice,
    required this.ma20,
    required this.ma50,
    required this.ma100,
  });

  @override
  Widget build(BuildContext context) {
    final crossLabel = ma20 >= ma50 ? 'Altın Kesişim' : 'Ölüm Kesişimi';
    final crossColor = ma20 >= ma50 ? AppTheme.stockUp : AppTheme.stockDown;
    final crossDescription =
        ma20 >= ma50 ? 'MA20 ↑ MA50 — Yükseliş eğilimi' : 'MA20 ↓ MA50 — Düşüş eğilimi';

    return _IndicatorTile(
      label: 'Hareketli Ortalama',
      subtitle: 'MA20 / MA50 / MA100',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: crossColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: crossColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          crossLabel,
          style: TextStyle(
            fontSize: 10,
            color: crossColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        children: [
          _MaRow('MA20', ma20, currentPrice),
          const SizedBox(height: 6),
          _MaRow('MA50', ma50, currentPrice),
          const SizedBox(height: 6),
          _MaRow('MA100', ma100, currentPrice),
          const SizedBox(height: 8),
          Text(
            crossDescription,
            style: TextStyle(
              fontSize: 11,
              color: crossColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaRow extends StatelessWidget {
  final String label;
  final double value;
  final double current;
  const _MaRow(this.label, this.value, this.current);

  @override
  Widget build(BuildContext context) {
    final above = current > value;
    final diff = value == 0 ? 0.0 : ((current - value) / value) * 100;
    final color = above ? AppTheme.stockUp : AppTheme.stockDown;
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            '${value.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          above ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: color,
          size: 12,
        ),
        const SizedBox(width: 2),
        Text(
          '${above ? "+" : ""}${diff.toStringAsFixed(2)}%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BollingerIndicator extends StatelessWidget {
  final double upper;
  final double middle;
  final double lower;
  final double current;
  const _BollingerIndicator({
    required this.upper,
    required this.middle,
    required this.lower,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    if (upper == 0 || lower == 0 || upper == lower) {
      return const SizedBox.shrink();
    }
    final position = ((current - lower) / (upper - lower)).clamp(0.0, 1.0);
    final color = position > 0.85
        ? AppTheme.stockDown
        : position < 0.15
            ? AppTheme.stockUp
            : AppTheme.stockNeutral;
    final label = position > 0.85
        ? 'Üst banda yakın — geri çekilme riski'
        : position < 0.15
            ? 'Alt banda yakın — toparlanma fırsatı'
            : 'Bant ortasında — yatay seyir';

    return _IndicatorTile(
      label: 'Bollinger Bantları',
      subtitle: '20 / 2σ',
      trailing: _ValueChip(
        value: '%${(position * 100).toStringAsFixed(0)}',
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              return SizedBox(
                height: 24,
                child: Stack(
                  children: [
                    Positioned(
                      top: 9,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.stockUp,
                              AppTheme.stockNeutral,
                              AppTheme.stockDown,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (c.maxWidth - 4) * position,
                      top: 4,
                      child: Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.textPrimary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
              Text('${lower.toStringAsFixed(2)} ₺',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              Text('${middle.toStringAsFixed(2)} ₺',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              Text('${upper.toStringAsFixed(2)} ₺',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String value;
  final Color color;
  const _ValueChip({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ==================== FIYAT GRAFIGI (degisiklik yok) ====================

class _PriceChartSection extends ConsumerWidget {
  final String stockCode;
  const _PriceChartSection({required this.stockCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(selectedChartRangeProvider(stockCode));
    final chartAsync = ref.watch(
      chartDataProvider((code: stockCode, range: selectedRange)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 230,
          width: double.infinity,
          child: chartAsync.when(
            loading: () => _buildSkeleton(),
            error: (e, _) => _buildError(ref, stockCode, selectedRange),
            data: (chart) {
              if (chart.isEmpty || !chart.success) {
                return _buildError(ref, stockCode, selectedRange);
              }
              return _buildChart(chart);
            },
          ),
        ),
        const SizedBox(height: 12),
        _RangeSelector(stockCode: stockCode, selected: selectedRange),
        chartAsync.when(
          data: (chart) {
            if (chart.isEmpty) return const SizedBox.shrink();
            return _buildPeriodInfo(chart);
          },
          loading: () => const SizedBox(height: 20),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    ).animate(delay: 120.ms).fadeIn();
  }

  Widget _buildChart(ChartData chart) {
    final color =
        chart.periodChangePct >= 0 ? AppTheme.stockUp : AppTheme.stockDown;
    final spots = <FlSpot>[];
    for (int i = 0; i < chart.candles.length; i++) {
      spots.add(FlSpot(i.toDouble(), chart.candles[i].close));
    }

    final minY = chart.minPrice;
    final maxY = chart.maxPrice;
    final yPadding = (maxY - minY) * 0.1;

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 24),
      child: LineChart(
      LineChartData(
          minY: minY - yPadding,
          maxY: maxY + yPadding,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.bgTertiary,
            tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              getTooltipItems: (spots) => spots.map((s) {
                final idx = s.x.toInt();
                if (idx < 0 || idx >= chart.candles.length) {
                  return LineTooltipItem('', const TextStyle());
                }
                final c = chart.candles[idx];
                final date = DateFormat('dd MMM', 'tr_TR').format(c.date);
                return LineTooltipItem(
                  '${c.close.toStringAsFixed(2)} ₺\n',
                  const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: date,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              }).toList(),
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
              spots: spots,
            isCurved: true,
              curveSmoothness: 0.2,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                    color.withValues(alpha: 0.18),
                  color.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: AppTheme.accent,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildError(WidgetRef ref, String code, String range) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.show_chart_rounded,
              size: 32, color: AppTheme.textMuted),
          const SizedBox(height: 8),
          const Text(
            'Grafik verisi alınamadı',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(
              chartDataProvider((code: code, range: range)),
            ),
            child: const Text('Tekrar dene',
                style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodInfo(ChartData chart) {
    final pct = chart.periodChangePct;
    final isUp = pct >= 0;
    final color = isUp ? AppTheme.stockUp : AppTheme.stockDown;
    final sign = isUp ? '+' : '';
    final firstDate = chart.candles.first.date;
    final lastDate = chart.candles.last.date;
    final fmt = DateFormat('dd MMM yy', 'tr_TR');

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${fmt.format(firstDate)} → ${fmt.format(lastDate)}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          Text(
            '$sign${pct.toStringAsFixed(2)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeSelector extends ConsumerWidget {
  final String stockCode;
  final String selected;

  const _RangeSelector({required this.stockCode, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ChartRange.all.map((r) {
          final isSelected = r.code == selected;
          return GestureDetector(
            onTap: () => ref
                .read(selectedChartRangeProvider(stockCode).notifier)
                .state = r.code,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.bgTertiary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                r.label,
                style: TextStyle(
                  color:
                      isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// MK AI - Pro Analysis Detail (Minimalist / Pure Black)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/analysis_result.dart';

class AnalysisScreen extends ConsumerWidget {
  final String stockCode;
  const AnalysisScreen({super.key, required this.stockCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisProvider(stockCode));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border_rounded),
            onPressed: () {}, // TODO: Add to favorites
          ),
        ],
      ),
      body: analysisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2)),
        error: (e, _) => _buildError(e.toString(), () => ref.invalidate(analysisProvider(stockCode))),
        data: (result) {
          if (!result.success || result.stockInfo == null) {
            return Center(child: Text(result.error ?? 'Veri çekilemedi', style: const TextStyle(color: AppTheme.stockDown)));
          }
          return _buildContent(result);
        },
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
      children: [
        // BIG PRICE HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info.name, style: const TextStyle(fontSize: 16, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('${info.currentPrice.toStringAsFixed(2)} ₺', 
                   style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: -2.0, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text('${isUp ? "+" : ""}${info.priceChange24h.toStringAsFixed(2)}% Bugün', 
                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeColor)),
            ],
          ).animate().fadeIn(),
        ),

        // BIG CHART
        SizedBox(
          height: 250,
          width: double.infinity,
          child: _HeroChart(isUp: isUp, color: themeColor),
        ).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 24),

        // DETAILS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Signals
              if (signals != null) ...[
                _SectionHeader('AI Kararı'),
                Text(signals.overallSignal.toUpperCase(), 
                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.signalColor(signals.overallSignal))),
                const SizedBox(height: 8),
                Text('Sinyal Gücü: ${signals.signalStrength}', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                Text('Güven Skoru: %${signals.confidence.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 32),
              ],

              // Technical
              if (tech != null) ...[
                _SectionHeader('Teknik Seviyeler'),
                _TechRow('RSI (14)', tech.rsi.toStringAsFixed(2)),
                _TechRow('MACD', tech.macd.toStringAsFixed(3)),
                _TechRow('ADX', tech.adx.toStringAsFixed(2)),
                _TechRow('MA20', '${tech.ma20.toStringAsFixed(2)} ₺'),
                _TechRow('MA50', '${tech.ma50.toStringAsFixed(2)} ₺'),
                _TechRow('Hacim', _formatVolume(info.volume24h)),
                const SizedBox(height: 32),
              ],

              // AI Commentary
              if (result.aiAnalysis != null && result.aiAnalysis!.isNotEmpty) ...[
                _SectionHeader('Otonom Analiz'),
                Text(result.aiAnalysis!, style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.6)),
                const SizedBox(height: 32),
              ],
              
              // News
              if (result.newsSummary != null) ...[
                _SectionHeader('Haber Özeti'),
                Text(result.newsSummary!.summary, style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.6)),
                const SizedBox(height: 48),
              ],
            ],
          ),
        ).animate(delay: 200.ms).fadeIn(),
      ],
    );
  }

  Widget _buildError(String msg, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_rounded, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }

  String _formatVolume(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)} Milyar';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)} Milyon';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(0)} Bin';
    return v.toStringAsFixed(0);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final String label, value;
  const _TechRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HeroChart extends StatelessWidget {
  final bool isUp;
  final Color color;
  const _HeroChart({required this.isUp, required this.color});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.bgTertiary,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) => LineTooltipItem('${spot.y.toStringAsFixed(2)} ₺', const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            // Pseudo spots representing a daily chart
            spots: isUp ? const [
              FlSpot(0, 100), FlSpot(1, 102), FlSpot(2, 101), FlSpot(3, 105),
              FlSpot(4, 104), FlSpot(5, 108), FlSpot(6, 107), FlSpot(7, 110),
            ] : const [
              FlSpot(0, 110), FlSpot(1, 108), FlSpot(2, 109), FlSpot(3, 105),
              FlSpot(4, 106), FlSpot(5, 102), FlSpot(6, 103), FlSpot(7, 100),
            ],
            isCurved: true,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

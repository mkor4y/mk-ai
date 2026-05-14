/// MK AI - Pro Dashboard Screen (Minimalist / Pure Black)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';
import '../../providers/providers.dart';
import '../../models/market_summary.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketAsync = ref.watch(marketSummaryProvider);

    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.stockUp,
        backgroundColor: AppTheme.bgTertiary,
        onRefresh: () async => ref.invalidate(marketSummaryProvider),
        child: marketAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.stockUp, strokeWidth: 2)),
          error: (e, _) => _buildError(e.toString(), () => ref.invalidate(marketSummaryProvider)),
          data: (data) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              _buildMainIndex(data.indices),
              const SizedBox(height: 48),
              _buildQuickSearch(context),
              const SizedBox(height: 40),
              const Text('İzleme Listesi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              ...data.watchlist.map((item) => _buildWatchlistTile(context, item)),
              const SizedBox(height: 40),
              _buildRiskText(),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }

  Widget _buildMainIndex(List<MarketIndex> indices) {
    if (indices.isEmpty) return const SizedBox.shrink();
    // Use the first index (BIST 100) as the huge hero element
    final mainIdx = indices.first;
    final isUp = mainIdx.up;
    final color = isUp ? AppTheme.stockUp : AppTheme.stockDown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mainIdx.name, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(mainIdx.value, style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: -2.0, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 20),
            const SizedBox(width: 4),
            Text(mainIdx.change, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickSearch(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgTertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _QuickAnalysisInput(),
        ),
      ],
    );
  }

  Widget _buildWatchlistTile(BuildContext context, WatchlistItem item) {
    final color = item.up ? AppTheme.stockUp : AppTheme.stockDown;
    return InkWell(
      onTap: () => context.push('/analysis/${item.symbol}'),
      splashColor: AppTheme.bgTertiary,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text(item.name, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // Pseudo sparkline placeholder
                SizedBox(
                  width: 50,
                  height: 30,
                  child: CustomPaint(painter: _SparklinePainter(color: color)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(item.change, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildRiskText() {
    return const Center(
      child: Text(
        'Yapay zeka analizleri yatırım tavsiyesi değildir.\nLütfen kendi araştırmanızı yapın.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
      ),
    );
  }

  Widget _buildError(String msg, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            const Text('Bağlantı Hatası', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
          ],
        ),
      ),
    );
  }
}

class _QuickAnalysisInput extends StatefulWidget {
  @override
  State<_QuickAnalysisInput> createState() => _QuickAnalysisInputState();
}

class _QuickAnalysisInputState extends State<_QuickAnalysisInput> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _go(String code) {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) return;
    if (!AppConfig.stockCodes.contains(c)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ "$c" BIST30 dışı veya desteklenmiyor'), backgroundColor: AppTheme.bgTertiary));
      return;
    }
    context.push('/analysis/$c');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Hisse ara (Örn: THYAO)',
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w400),
        prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.accent),
          onPressed: () => _go(_ctrl.text),
        ),
      ),
      onSubmitted: _go,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.5, size.width, size.height * 0.2);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

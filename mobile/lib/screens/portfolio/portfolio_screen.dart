/// MK AI - Portfoy Ekrani
///
/// Kullanicinin pozisyonlarini, canli fiyatlardan hesaplanan toplam deger /
/// kar zarar bilgisini ve sektor dagilimini gosterir.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../models/holding.dart';
import '../../providers/providers.dart';
import '../../services/stock_service.dart' show StockQuote;
import 'widgets/add_holding_sheet.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(portfolioProvider);
    final symbols = holdings.map((h) => h.symbol).toSet().toList();
    final quotesAsync = ref.watch(stockQuotesProvider(symbols));

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Portföy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh_rounded,
                size: 20, color: AppTheme.textPrimary),
            onPressed: () =>
                ref.invalidate(stockQuotesProvider(symbols)),
          ),
          IconButton(
            tooltip: 'Pozisyon Ekle',
            icon: const Icon(Icons.add_rounded,
                size: 22, color: AppTheme.stockUp),
            onPressed: () => showAddHoldingSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: holdings.isEmpty
          ? _EmptyState(onAdd: () => showAddHoldingSheet(context))
          : RefreshIndicator(
              backgroundColor: AppTheme.bgSecondary,
              color: AppTheme.stockUp,
              onRefresh: () async {
                ref.invalidate(stockQuotesProvider(symbols));
                await ref.read(stockQuotesProvider(symbols).future);
              },
              child: _Body(
                holdings: holdings,
                quotesAsync: quotesAsync,
              ),
            ),
      floatingActionButton: holdings.isEmpty
          ? null
          : FloatingActionButton(
              backgroundColor: AppTheme.stockUp,
              foregroundColor: AppTheme.bgPrimary,
              onPressed: () => showAddHoldingSheet(context),
              tooltip: 'Yeni pozisyon',
              child: const Icon(Icons.add_rounded),
            ),
    );
  }
}

// ============================ BODY ============================
class _Body extends ConsumerWidget {
  final List<Holding> holdings;
  final AsyncValue<Map<String, StockQuote>> quotesAsync;

  const _Body({required this.holdings, required this.quotesAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = quotesAsync.value ?? const <String, StockQuote>{};
    final summary = _PortfolioSummary.fromHoldings(holdings, quotes);
    final loading = quotesAsync.isLoading && quotes.isEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        _SummaryCard(summary: summary, loading: loading)
            .animate()
            .fadeIn(duration: 250.ms),
        if (quotesAsync.hasError && quotes.isEmpty) ...[
          const SizedBox(height: 12),
          _ErrorBanner(
            message:
                'Canlı fiyatlar alınamadı. Maliyet üzerinden görüntüleniyor.',
            onRetry: () => ref.invalidate(
              stockQuotesProvider(holdings.map((h) => h.symbol).toList()),
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (summary.sectorBreakdown.length >= 2) ...[
          _SectionTitle(
            label: 'Sektör Dağılımı',
            icon: Icons.pie_chart_rounded,
            color: const Color(0xFF5B8DEF),
          ),
          const SizedBox(height: 10),
          _SectorPie(breakdown: summary.sectorBreakdown),
          const SizedBox(height: 20),
        ],
        _SectionTitle(
          label: 'Pozisyonlar (${holdings.length})',
          icon: Icons.account_balance_wallet_rounded,
          color: AppTheme.stockUp,
        ),
        const SizedBox(height: 10),
        ...holdings.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HoldingTile(
                holding: h,
                quote: quotes[h.symbol],
              ),
            )),
      ],
    );
  }
}

// ============================ MODEL: summary helper ============================
class _PortfolioSummary {
  final double totalCost;
  final double totalValue;
  final int knownCount; // canli fiyati olan pozisyon sayisi
  final int totalCount;
  final Map<String, double> sectorBreakdown; // sektor -> deger

  const _PortfolioSummary({
    required this.totalCost,
    required this.totalValue,
    required this.knownCount,
    required this.totalCount,
    required this.sectorBreakdown,
  });

  double get pnl => totalValue - totalCost;
  double get pnlPct => totalCost <= 0 ? 0 : (pnl / totalCost) * 100;
  bool get up => pnl >= 0;
  int get unknownCount => totalCount - knownCount;

  factory _PortfolioSummary.fromHoldings(
    List<Holding> holdings,
    Map<String, StockQuote> quotes,
  ) {
    double cost = 0, value = 0;
    int known = 0;
    final sector = <String, double>{};

    for (final h in holdings) {
      cost += h.totalCost;
      final q = quotes[h.symbol];
      double pieceValue;
      if (q != null && q.price > 0) {
        pieceValue = h.valueAt(q.price);
        known++;
      } else {
        // Fiyat yoksa maliyet uzerinden hesapla (kullaniciya yanlis P/L gostermeyiz)
        pieceValue = h.totalCost;
      }
      value += pieceValue;
      final sName = AppConfig.sectorOf(h.symbol);
      sector[sName] = (sector[sName] ?? 0) + pieceValue;
    }
    return _PortfolioSummary(
      totalCost: cost,
      totalValue: value,
      knownCount: known,
      totalCount: holdings.length,
      sectorBreakdown: sector,
    );
  }
}

// ============================ SUMMARY CARD ============================
class _SummaryCard extends StatelessWidget {
  final _PortfolioSummary summary;
  final bool loading;
  const _SummaryCard({required this.summary, required this.loading});

  @override
  Widget build(BuildContext context) {
    final color = summary.up ? AppTheme.stockUp : AppTheme.stockDown;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            AppTheme.bgSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                color: color.withValues(alpha: 0.9),
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'TOPLAM DEĞER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: AppTheme.stockUp,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _money(summary.totalValue),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      summary.up
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: color,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${summary.up ? '+' : ''}${summary.pnlPct.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${summary.up ? '+' : ''}${_money(summary.pnl)}',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: AppTheme.border.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCol(
                  label: 'Maliyet',
                  value: _money(summary.totalCost),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.border.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _StatCol(
                  label: 'Pozisyon',
                  value: '${summary.totalCount}',
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.border.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _StatCol(
                  label: 'Canlı Fiyat',
                  value: '${summary.knownCount}/${summary.totalCount}',
                ),
              ),
            ],
          ),
          if (summary.unknownCount > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                  width: 0.6,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.amber, size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${summary.unknownCount} pozisyon için fiyat alınamadı, maliyet üzerinden gösteriliyor',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  const _StatCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ============================ SECTOR PIE ============================
class _SectorPie extends StatefulWidget {
  final Map<String, double> breakdown;
  const _SectorPie({required this.breakdown});

  @override
  State<_SectorPie> createState() => _SectorPieState();
}

class _SectorPieState extends State<_SectorPie> {
  static const _palette = [
    Color(0xFF21D782), // green
    Color(0xFF5B8DEF), // blue
    Color(0xFFFF6B35), // orange
    Color(0xFFB983FF), // purple
    Color(0xFFFFB020), // amber
    Color(0xFFFF3B7B), // pink
    Color(0xFF36C5D7), // cyan
    Color(0xFFFFD166), // yellow
  ];

  int? _touched;

  @override
  Widget build(BuildContext context) {
    final entries = widget.breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total =
        entries.fold<double>(0, (acc, e) => acc + e.value);
    if (total <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                pieTouchData: PieTouchData(
                  touchCallback: (event, resp) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          resp == null ||
                          resp.touchedSection == null) {
                        _touched = null;
                        return;
                      }
                      _touched = resp.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: List.generate(entries.length, (i) {
                  final e = entries[i];
                  final pct = (e.value / total) * 100;
                  final selected = _touched == i;
                  final color = _palette[i % _palette.length];
                  return PieChartSectionData(
                    color: color,
                    value: e.value,
                    title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
                    radius: selected ? 42 : 36,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(entries.length, (i) {
                final e = entries[i];
                final pct = (e.value / total) * 100;
                final color = _palette[i % _palette.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ HOLDING TILE ============================
class _HoldingTile extends ConsumerWidget {
  final Holding holding;
  final StockQuote? quote;

  const _HoldingTile({required this.holding, required this.quote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPrice = quote != null && quote!.price > 0;
    final current = hasPrice ? quote!.price : holding.avgCost;
    final value = holding.valueAt(current);
    final pnl = hasPrice ? holding.pnlAt(current) : 0.0;
    final pnlPct = hasPrice ? holding.pnlPctAt(current) : 0.0;
    final up = pnl >= 0;
    final pnlColor =
        !hasPrice ? AppTheme.textMuted : (up ? AppTheme.stockUp : AppTheme.stockDown);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openActions(context, ref),
        onLongPress: () => _openActions(context, ref),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.border.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: pnlColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        holding.symbol.isNotEmpty
                            ? holding.symbol.substring(0, 1)
                            : '?',
                        style: TextStyle(
                          color: pnlColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              holding.symbol,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.bgTertiary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppConfig.sectorOf(holding.symbol),
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_qty(holding.quantity)} × ${_money(holding.avgCost)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _money(value),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: pnlColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          hasPrice
                              ? '${up ? '+' : ''}${pnlPct.toStringAsFixed(2)}%'
                              : 'fiyat yok',
                          style: TextStyle(
                            color: pnlColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (hasPrice) ...[
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: AppTheme.border.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Fiyat',
                        value: _money(current),
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'P/L',
                        value: '${up ? '+' : ''}${_money(pnl)}',
                        color: pnlColor,
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Günlük',
                        value:
                            '${quote!.changePct >= 0 ? '+' : ''}${quote!.changePct.toStringAsFixed(2)}%',
                        color: quote!.changePct >= 0
                            ? AppTheme.stockUp
                            : AppTheme.stockDown,
                      ),
                    ),
                  ],
                ),
              ],
              if (holding.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgTertiary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sticky_note_2_outlined,
                          size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          holding.note,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  void _openActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              holding.symbol,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _ActionItem(
              icon: Icons.analytics_rounded,
              color: AppTheme.stockUp,
              label: 'Detaylı Analiz',
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push('/analysis/${holding.symbol}');
              },
            ),
            _ActionItem(
              icon: Icons.edit_rounded,
              color: const Color(0xFF5B8DEF),
              label: 'Düzenle',
              onTap: () async {
                Navigator.pop(sheetCtx);
                await showAddHoldingSheet(context, editing: holding);
              },
            ),
            _ActionItem(
              icon: Icons.delete_outline_rounded,
              color: AppTheme.stockDown,
              label: 'Pozisyonu Sil',
              onTap: () async {
                Navigator.pop(sheetCtx);
                final ok = await _confirmDelete(context, holding.symbol);
                if (!ok) return;
                await ref
                    .read(portfolioProvider.notifier)
                    .remove(holding.symbol);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String symbol) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: Text(
          '$symbol Silinsin mi?',
          style: const TextStyle(
              color: AppTheme.textPrimary, fontSize: 16),
        ),
        content: const Text(
          'Bu pozisyon portföyden kaldırılacak.',
          style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil',
                style: TextStyle(
                    color: AppTheme.stockDown,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _MiniStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color ?? AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ EMPTY STATE ============================
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.stockUp.withValues(alpha: 0.25),
                  AppTheme.stockUp.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.stockUp.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.stockUp,
              size: 38,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Portföyün boş',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sahip olduğun hisseleri ekleyerek\ncanlı kâr/zarar takibini başlat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Pozisyon Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.stockUp,
              foregroundColor: AppTheme.bgPrimary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ MISC ============================
class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SectionTitle({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 12),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.stockDown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.stockDown.withValues(alpha: 0.3),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: AppTheme.stockDown, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.stockDown,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Tekrar',
                style: TextStyle(
                  color: AppTheme.stockDown,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }
}

// ============================ FORMAT HELPERS ============================
String _money(double v) {
  final isNeg = v < 0;
  final abs = v.abs();
  final whole = abs.truncate();
  final frac = ((abs - whole) * 100).round().toString().padLeft(2, '0');
  final wholeStr = whole.toString();
  final buf = StringBuffer();
  for (int i = 0; i < wholeStr.length; i++) {
    final remaining = wholeStr.length - i;
    buf.write(wholeStr[i]);
    if (remaining > 1 && remaining % 3 == 1) buf.write('.');
  }
  return '${isNeg ? '-' : ''}$buf,$frac ₺';
}

String _qty(double v) {
  // 100.0 -> "100", 1.5 -> "1.5"
  if (v == v.truncate()) return v.truncate().toString();
  return v.toString();
}

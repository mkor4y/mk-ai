/// MK AI - Profesyonel Dashboard
///
/// Bolumler (yukaridan asagiya):
/// 1. Greeting header     - selam, tarih, market durumu (acik/kapali)
/// 2. BIST 100 Hero Card   - buyuk gradient kart + sparkline + change badge
/// 3. Diger endeksler      - yatay scroll mini kartlar
/// 4. Hizli arama          - hisse kodu arama
/// 5. Hizli eylemler       - 4 renkli ikon (Analiz / Haberler / AI / Favoriler)
/// 6. Favoriler            - kullanici eklemisse compact strip
/// 7. Top Movers           - watchlist'ten en yuksek/dusuk degisimliler (tabs)
/// 8. Watchlist            - sparkline'li liste
/// 9. Risk footer
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../models/market_summary.dart';
import '../../providers/providers.dart';
import 'widgets/sparkline.dart';

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
          loading: () => const _DashboardSkeleton(),
          error: (e, _) => _ErrorView(
            message: e.toString().replaceFirst('Exception: ', ''),
            onRetry: () => ref.invalidate(marketSummaryProvider),
          ),
          data: (data) => _DashboardBody(data: data, ref: ref),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final MarketSummary data;
  final WidgetRef ref;
  const _DashboardBody({required this.data, required this.ref});

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final indices = data.indices;
    final mainIndex = indices.isNotEmpty ? indices.first : null;
    final otherIndices = indices.length > 1 ? indices.sublist(1) : <MarketIndex>[];

    // Top movers (en cok yukselen + en cok dusen)
    final sorted = [...data.watchlist]
      ..sort((a, b) => _changePct(b.change).abs().compareTo(_changePct(a.change).abs()));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
      children: [
        _GreetingHeader(timestamp: data.timestamp)
            .animate()
            .fadeIn(duration: 350.ms),

        const SizedBox(height: 16),

        if (mainIndex != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _HeroIndexCard(index: mainIndex)
                .animate()
                .fadeIn(duration: 400.ms, delay: 80.ms)
                .slideY(begin: 0.05),
          ),

        if (otherIndices.isNotEmpty) ...[
          const SizedBox(height: 12),
          _OtherIndicesRow(indices: otherIndices),
        ],

        const SizedBox(height: 20),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _QuickSearch(),
        ),

        const SizedBox(height: 20),

        const _QuickActionsGrid(),

        const SizedBox(height: 24),

        if (favorites.isNotEmpty) ...[
          _FavoritesSection(codes: favorites, watchlist: data.watchlist),
          const SizedBox(height: 24),
        ],

        _TopMoversSection(items: sorted.take(4).toList()),

        const SizedBox(height: 24),

        _WatchlistSection(items: data.watchlist),

        const SizedBox(height: 24),

        const _RiskFooter(),
      ],
    );
  }
}

// ============================ HEADER ============================
class _GreetingHeader extends ConsumerWidget {
  final String timestamp;
  const _GreetingHeader({required this.timestamp});

  // Settings'teki paletle ayni — sirayla [yesil, mavi, amber, turuncu, mor, pembe]
  static const _avatarPalette = [
    AppTheme.stockUp,
    Color(0xFF5B8DEF),
    Colors.amber,
    Color(0xFFFF6B35),
    Colors.purpleAccent,
    Color(0xFFFF3B7B),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final profile = ref.watch(userProfileProvider);
    final color =
        _avatarPalette[profile.avatarColorIndex % _avatarPalette.length];
    final greetingBase = _greeting(now);
    // "Misafir" ise sadece selam; ad varsa "selam, Ad"
    final greeting = profile.displayName == 'Misafir'
        ? greetingBase
        : '$greetingBase, ${profile.displayName.split(' ').first}';
    final dateStr = DateFormat('EEEE, d MMMM', 'tr_TR').format(now);
    final marketOpen = _isMarketOpen(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar (tiklanabilir -> /settings)
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  profile.initial,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textMuted.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          _MarketStatusBadge(open: marketOpen),
        ],
      ),
    );
  }

  String _greeting(DateTime t) {
    final h = t.hour;
    if (h < 6) return 'İyi geceler';
    if (h < 11) return 'Günaydın';
    if (h < 17) return 'İyi günler';
    if (h < 22) return 'İyi akşamlar';
    return 'İyi geceler';
  }

  bool _isMarketOpen(DateTime now) {
    // BIST: Pzt-Cum 10:00 - 18:00 (TR saati). Resmi tatil hesabi yok.
    if (now.weekday > 5) return false;
    final m = now.hour * 60 + now.minute;
    return m >= 10 * 60 && m < 18 * 60;
  }
}

class _MarketStatusBadge extends StatelessWidget {
  final bool open;
  const _MarketStatusBadge({required this.open});

  @override
  Widget build(BuildContext context) {
    final color = open ? AppTheme.stockUp : AppTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          )
              .animate(
                  onPlay: (c) => open ? c.repeat(reverse: true) : c.stop())
              .fadeIn(duration: 800.ms),
          const SizedBox(width: 5),
          Text(
            open ? 'BIST AÇIK' : 'BIST KAPALI',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ HERO INDEX CARD ============================
class _HeroIndexCard extends StatelessWidget {
  final MarketIndex index;
  const _HeroIndexCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final color = index.up ? AppTheme.stockUp : AppTheme.stockDown;
    final pct = _changePct(index.change);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            AppTheme.bgSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.bgPrimary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  index.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.bolt_rounded,
                  size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              const Text(
                'CANLI',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            index.value,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      index.up
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 13,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      index.change,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${pct.abs().toStringAsFixed(2)} puan',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Sparkline(
                symbol: index.name,
                isUp: index.up,
                color: color,
                width: 90,
                height: 36,
                fill: true,
                strokeWidth: 1.6,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================ OTHER INDICES ROW ============================
class _OtherIndicesRow extends StatelessWidget {
  final List<MarketIndex> indices;
  const _OtherIndicesRow({required this.indices});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: indices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final idx = indices[i];
          final color = idx.up ? AppTheme.stockUp : AppTheme.stockDown;
          return Container(
            width: 170,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        idx.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        idx.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            idx.up
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 12,
                            color: color,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            idx.change,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Sparkline(
                  symbol: idx.name,
                  isUp: idx.up,
                  color: color,
                  width: 48,
                  height: 30,
                  fill: true,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: (i * 60).ms, duration: 350.ms)
              .slideX(begin: 0.1);
        },
      ),
    );
  }
}

// ============================ QUICK SEARCH ============================
class _QuickSearch extends StatefulWidget {
  const _QuickSearch();

  @override
  State<_QuickSearch> createState() => _QuickSearchState();
}

class _QuickSearchState extends State<_QuickSearch> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _go(String code) {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) return;
    if (!AppConfig.stockCodes.contains(c)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$c" desteklenmiyor — Analiz sekmesinden seç',
              style: const TextStyle(color: AppTheme.textPrimary)),
          backgroundColor: AppTheme.bgTertiary,
        ),
      );
      return;
    }
    context.push('/analysis/$c');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focus.hasFocus
              ? AppTheme.stockUp.withValues(alpha: 0.4)
              : AppTheme.border,
          width: 1,
        ),
      ),
      child: TextField(
      controller: _ctrl,
        focusNode: _focus,
      textCapitalization: TextCapitalization.characters,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
          letterSpacing: 0.3,
        ),
        decoration: const InputDecoration(
          hintText: 'Hisse ara: THYAO, AKBNK, ASELS...',
          hintStyle: TextStyle(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w400,
            fontSize: 13.5,
          ),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppTheme.textMuted, size: 20),
        border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        onSubmitted: _go,
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}

// ============================ QUICK ACTIONS ============================
class _QuickActionsGrid extends ConsumerWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioCount = ref.watch(portfolioProvider).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.analytics_rounded,
              label: 'Analiz',
              color: AppTheme.stockUp,
              onTap: () =>
                  ref.read(selectedTabProvider.notifier).state = 1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Portföy',
              color: const Color(0xFFB983FF),
              badge: portfolioCount > 0 ? '$portfolioCount' : null,
              onTap: () => context.push('/portfolio'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              icon: Icons.newspaper_rounded,
              label: 'Haberler',
              color: const Color(0xFF5B8DEF),
              onTap: () =>
                  ref.read(selectedTabProvider.notifier).state = 2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              icon: Icons.auto_awesome_rounded,
              label: 'AI Chat',
              color: Colors.amber,
              onTap: () =>
                  ref.read(selectedTabProvider.notifier).state = 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.stockUp,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.bgSecondary, width: 1.2),
                      ),
                      constraints: const BoxConstraints(
                          minWidth: 16, minHeight: 14),
                      child: Text(
                        badge!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.bgPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ FAVORITES ============================
class _FavoritesSection extends StatelessWidget {
  final List<String> codes;
  final List<WatchlistItem> watchlist;
  const _FavoritesSection({required this.codes, required this.watchlist});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionTitle(
            label: 'Favorilerim',
            icon: Icons.star_rounded,
            iconColor: Colors.amber,
            trailing: Text(
              '${codes.length} hisse',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: codes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final code = codes[i];
              // Watchlist'te varsa gercek fiyat goster
              WatchlistItem? wl;
              for (final w in watchlist) {
                if (w.symbol == code) {
                  wl = w;
                  break;
                }
              }
              final isUp = wl?.up ?? true;
              final color = isUp ? AppTheme.stockUp : AppTheme.stockDown;
              return InkWell(
                onTap: () => context.push('/analysis/$code'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.border.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            code,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Icon(Icons.star_rounded,
                              size: 13, color: Colors.amber),
                        ],
                      ),
                      Sparkline(
                        symbol: code,
                        isUp: isUp,
                        color: color,
                        width: double.infinity,
                        height: 26,
                        fill: true,
                      ),
                      if (wl != null)
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₺${wl.price}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              wl.change,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          AppConfig.stockName(code),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (i * 50).ms, duration: 300.ms)
                  .slideX(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }
}

// ============================ TOP MOVERS ============================
class _TopMoversSection extends StatelessWidget {
  final List<WatchlistItem> items;
  const _TopMoversSection({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _SectionTitle(
            label: 'Öne Çıkanlar',
            icon: Icons.local_fire_department_rounded,
            iconColor: Color(0xFFFF6B35),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.85,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final color = item.up ? AppTheme.stockUp : AppTheme.stockDown;
              return InkWell(
                onTap: () => context.push('/analysis/${item.symbol}'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              item.up
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 11,
                              color: color,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.change,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.symbol,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            '₺${item.price}',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  AppTheme.textMuted.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================ WATCHLIST ============================
class _WatchlistSection extends ConsumerWidget {
  final List<WatchlistItem> items;
  const _WatchlistSection({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionTitle(
            label: 'İzleme Listesi',
            icon: Icons.visibility_rounded,
            iconColor: const Color(0xFF5B8DEF),
            trailing: GestureDetector(
              onTap: () =>
                  ref.read(selectedTabProvider.notifier).state = 1,
              child: const Row(
                children: [
                  Text(
                    'Tümü',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: AppTheme.textMuted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isFav = favorites.contains(item.symbol);
                final showDivider = i != items.length - 1;
                return Column(
                  children: [
                    _WatchlistTile(
                      item: item,
                      isFavorite: isFav,
                      onFavToggle: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(item.symbol),
                    ),
                    if (showDivider)
                      Divider(
                        color: AppTheme.border.withValues(alpha: 0.4),
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatchlistTile extends StatelessWidget {
  final WatchlistItem item;
  final bool isFavorite;
  final VoidCallback onFavToggle;

  const _WatchlistTile({
    required this.item,
    required this.isFavorite,
    required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.up ? AppTheme.stockUp : AppTheme.stockDown;
    return InkWell(
      onTap: () => context.push('/analysis/${item.symbol}'),
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Sol: sembol icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Text(
                  item.symbol.substring(0, item.symbol.length >= 3 ? 3 : item.symbol.length),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Orta: sembol + adi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.symbol,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onFavToggle,
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color:
                              isFavorite ? Colors.amber : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Sparkline
            Sparkline(
              symbol: item.symbol,
              isUp: item.up,
              color: color,
              width: 54,
              height: 28,
            ),
            const SizedBox(width: 12),
            // Sag: fiyat + change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${item.price}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.change,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ SECTION TITLE ============================
class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  const _SectionTitle({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ============================ RISK FOOTER ============================
class _RiskFooter extends StatelessWidget {
  const _RiskFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.border.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.shield_outlined,
              size: 14,
              color: AppTheme.textMuted.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Yapay zeka analizleri yatırım tavsiyesi değildir. Kararlarınızı kendi araştırmanızla destekleyin.',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppTheme.textMuted.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ SKELETON ============================
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _shimmer(width: 42, height: 42, radius: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmer(width: 140, height: 18),
                  const SizedBox(height: 6),
                  _shimmer(width: 100, height: 12),
                ],
              ),
            ),
            _shimmer(width: 72, height: 22, radius: 6),
          ],
        ),
        const SizedBox(height: 20),
        _shimmer(height: 150, radius: 18),
        const SizedBox(height: 12),
        SizedBox(
          height: 86,
          child: Row(
            children: List.generate(
              2,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 0 ? 10 : 0),
                  child: _shimmer(radius: 12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _shimmer(height: 48, radius: 12),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: _shimmer(height: 76, radius: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        for (int i = 0; i < 5; i++) ...[
          _shimmer(height: 60, radius: 12),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _shimmer({double? width, double height = 40, double radius = 8}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1200.ms, color: AppTheme.bgSecondary);
  }
}

// ============================ ERROR VIEW ============================
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            const Text(
              'Bağlantı Hatası',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.bgTertiary,
                foregroundColor: AppTheme.textPrimary,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ HELPERS ============================
double _changePct(String s) {
  // "+1.34%" -> 1.34, "-2.10%" -> -2.10
  final cleaned = s.replaceAll('%', '').replaceAll('+', '').trim();
  return double.tryParse(cleaned) ?? 0.0;
}

/// MK AI - Profesyonel Hisse Seçim Listesi
///
/// Ozellikler:
/// - Header (baslik + arama cubugu)
/// - Tab bar: Tumu / Favoriler / Yukselenler / Dusenler
/// - Sektor filter chip'leri (yatay scroll)
/// - List / Grid gorunum toggle
/// - Watchlist'te olan hisseler icin gercek fiyat + change badge
/// - Diger hisseler icin deterministik sparkline + sektor rozeti
/// - Favorilere yildiz toggle
/// - Animasyonlu fade-in
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../models/market_summary.dart';
import '../../providers/providers.dart';
import '../dashboard/widgets/sparkline.dart';

enum _StockFilter { all, favorites, gainers, losers }

extension _StockFilterLabel on _StockFilter {
  String get label {
    switch (this) {
      case _StockFilter.all:
        return 'Tümü';
      case _StockFilter.favorites:
        return 'Favoriler';
      case _StockFilter.gainers:
        return 'Yükselenler';
      case _StockFilter.losers:
        return 'Düşenler';
    }
  }

  IconData get icon {
    switch (this) {
      case _StockFilter.all:
        return Icons.list_alt_rounded;
      case _StockFilter.favorites:
        return Icons.star_rounded;
      case _StockFilter.gainers:
        return Icons.trending_up_rounded;
      case _StockFilter.losers:
        return Icons.trending_down_rounded;
    }
  }
}

class StockListScreen extends ConsumerStatefulWidget {
  const StockListScreen({super.key});

  @override
  ConsumerState<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends ConsumerState<StockListScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _searchQuery = '';
  String _selectedSector = 'Tümü'; // 'Tümü' veya sektör adı
  _StockFilter _activeFilter = _StockFilter.all;
  bool _gridView = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  WatchlistItem? _watchlistFor(String code, List<WatchlistItem> wl) {
    for (final w in wl) {
      if (w.symbol == code) return w;
    }
    return null;
  }

  List<StockItem> _applyFilters(
    List<StockItem> all,
    List<String> favorites,
    List<WatchlistItem> watchlist,
  ) {
    Iterable<StockItem> result = all;

    // Tab filtresi
    switch (_activeFilter) {
      case _StockFilter.all:
        break;
      case _StockFilter.favorites:
        result = result.where((s) => favorites.contains(s.code));
        break;
      case _StockFilter.gainers:
        result = result.where((s) => _watchlistFor(s.code, watchlist)?.up == true);
        break;
      case _StockFilter.losers:
        result = result.where((s) => _watchlistFor(s.code, watchlist)?.up == false);
        break;
    }

    // Sektör filtresi
    if (_selectedSector != 'Tümü') {
      result = result.where((s) => AppConfig.sectorOf(s.code) == _selectedSector);
    }

    // Arama
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((s) =>
          s.code.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q));
    }
    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final marketAsync = ref.watch(marketSummaryProvider);
    final watchlist =
        marketAsync.maybeWhen(data: (d) => d.watchlist, orElse: () => <WatchlistItem>[]);

    final filtered = _applyFilters(AppConfig.supportedStocks, favorites, watchlist);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              searchCtrl: _searchCtrl,
              searchFocus: _searchFocus,
              query: _searchQuery,
              onChanged: (v) => setState(() => _searchQuery = v),
              onClear: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
              gridView: _gridView,
              onToggleView: () => setState(() => _gridView = !_gridView),
              totalCount: AppConfig.supportedStocks.length,
              filteredCount: filtered.length,
            ),
            _FilterTabs(
              active: _activeFilter,
              onSelect: (f) => setState(() => _activeFilter = f),
              favCount: favorites.length,
              gainerCount:
                  watchlist.where((w) => w.up).length,
              loserCount:
                  watchlist.where((w) => !w.up).length,
            ),
            _SectorChips(
              selected: _selectedSector,
              onSelect: (s) => setState(() => _selectedSector = s),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: filtered.isEmpty
                  ? const _EmptyView()
                  : RefreshIndicator(
                      color: AppTheme.stockUp,
                      backgroundColor: AppTheme.bgTertiary,
                      onRefresh: () async =>
                          ref.invalidate(marketSummaryProvider),
                      child: _gridView
                          ? _GridList(
                              items: filtered,
                              watchlist: watchlist,
                              favorites: favorites,
                            )
                          : _LinearList(
                              items: filtered,
                              watchlist: watchlist,
                              favorites: favorites,
                              onFavToggle: (code) => ref
                                  .read(favoritesProvider.notifier)
                                  .toggle(code),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ HEADER ============================
class _Header extends StatelessWidget {
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool gridView;
  final VoidCallback onToggleView;
  final int totalCount;
  final int filteredCount;

  const _Header({
    required this.searchCtrl,
    required this.searchFocus,
    required this.query,
    required this.onChanged,
    required this.onClear,
    required this.gridView,
    required this.onToggleView,
    required this.totalCount,
    required this.filteredCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hisseler',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'BIST destekli 24 hisse',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: gridView ? 'Liste görünümü' : 'Grid görünümü',
                onPressed: onToggleView,
                icon: Icon(
                  gridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  color: AppTheme.textPrimary,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppTheme.bgTertiary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: searchFocus.hasFocus
                    ? AppTheme.stockUp.withValues(alpha: 0.4)
                    : AppTheme.border,
                width: 1,
              ),
            ),
            child: TextField(
              controller: searchCtrl,
              focusNode: searchFocus,
              textCapitalization: TextCapitalization.characters,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
                letterSpacing: 0.3,
              ),
              decoration: InputDecoration(
                hintText: 'Hisse ara: THYAO, Bankacılık...',
                hintStyle: const TextStyle(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w400,
                  fontSize: 13.5,
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textMuted, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppTheme.textMuted, size: 18),
                        onPressed: onClear,
                      )
                    : null,
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              ),
            ),
          ),
          if (query.isNotEmpty || filteredCount != totalCount) ...[
            const SizedBox(height: 8),
            Text(
              '$filteredCount sonuç gösteriliyor',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================ FILTER TABS ============================
class _FilterTabs extends StatelessWidget {
  final _StockFilter active;
  final ValueChanged<_StockFilter> onSelect;
  final int favCount;
  final int gainerCount;
  final int loserCount;

  const _FilterTabs({
    required this.active,
    required this.onSelect,
    required this.favCount,
    required this.gainerCount,
    required this.loserCount,
  });

  @override
  Widget build(BuildContext context) {
    int? countFor(_StockFilter f) {
      switch (f) {
        case _StockFilter.all:
          return null;
        case _StockFilter.favorites:
          return favCount;
        case _StockFilter.gainers:
          return gainerCount;
        case _StockFilter.losers:
          return loserCount;
      }
    }

    Color colorFor(_StockFilter f) {
      switch (f) {
        case _StockFilter.gainers:
          return AppTheme.stockUp;
        case _StockFilter.losers:
          return AppTheme.stockDown;
        case _StockFilter.favorites:
          return Colors.amber;
        case _StockFilter.all:
          return AppTheme.textPrimary;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: _StockFilter.values.map((f) {
          final isActive = f == active;
          final color = colorFor(f);
          final count = countFor(f);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => onSelect(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? color.withValues(alpha: 0.4)
                          : AppTheme.border.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        f.icon,
                        size: 14,
                        color: isActive ? color : AppTheme.textMuted,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              f.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? color
                                    : AppTheme.textSecondary,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          if (count != null && count > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? color
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============================ SECTOR CHIPS ============================
class _SectorChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _SectorChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final sectors = ['Tümü', ...AppConfig.allSectors];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sectors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final s = sectors[i];
          final isActive = s == selected;
          return GestureDetector(
            onTap: () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.textPrimary
                    : AppTheme.bgTertiary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? AppTheme.textPrimary
                      : AppTheme.border,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppTheme.bgPrimary
                        : AppTheme.textSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================ LINEAR LIST ============================
class _LinearList extends StatelessWidget {
  final List<StockItem> items;
  final List<WatchlistItem> watchlist;
  final List<String> favorites;
  final void Function(String code) onFavToggle;

  const _LinearList({
    required this.items,
    required this.watchlist,
    required this.favorites,
    required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final stock = items[i];
        final wl = _findWl(stock.code, watchlist);
        final isFav = favorites.contains(stock.code);
        return _LinearTile(
          stock: stock,
          watchlist: wl,
          isFavorite: isFav,
          onFavToggle: () => onFavToggle(stock.code),
        )
            .animate()
            .fadeIn(
                duration: 220.ms, delay: (i * 18).clamp(0, 400).ms)
            .slideY(begin: 0.06, end: 0);
      },
    );
  }
}

WatchlistItem? _findWl(String code, List<WatchlistItem> wl) {
  for (final w in wl) {
    if (w.symbol == code) return w;
  }
  return null;
}

class _LinearTile extends StatelessWidget {
  final StockItem stock;
  final WatchlistItem? watchlist;
  final bool isFavorite;
  final VoidCallback onFavToggle;

  const _LinearTile({
    required this.stock,
    required this.watchlist,
    required this.isFavorite,
    required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrice = watchlist != null;
    final isUp = watchlist?.up ?? true;
    final color = isUp ? AppTheme.stockUp : AppTheme.stockDown;
    final sector = AppConfig.sectorOf(stock.code);

    return InkWell(
      onTap: () => context.push('/analysis/${stock.code}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            // Sembol ikon
            Container(
              width: 42,
              height: 42,
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
                  stock.code.substring(
                      0, stock.code.length >= 3 ? 3 : stock.code.length),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Sembol + ad + sektör
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        stock.code,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
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
                          size: 15,
                          color:
                              isFavorite ? Colors.amber : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          stock.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.bgTertiary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          sector,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sparkline
            Sparkline(
              symbol: stock.code,
              isUp: isUp,
              color: hasPrice
                  ? color
                  : AppTheme.textMuted.withValues(alpha: 0.5),
              width: 50,
              height: 26,
            ),
            const SizedBox(width: 10),
            // Fiyat / change veya "—"
            SizedBox(
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: hasPrice
                    ? [
                        Text(
                          '₺${watchlist!.price}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            watchlist!.change,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ]
                    : const [
                        Text(
                          '—',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Analiz et',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ GRID LIST ============================
class _GridList extends StatelessWidget {
  final List<StockItem> items;
  final List<WatchlistItem> watchlist;
  final List<String> favorites;

  const _GridList({
    required this.items,
    required this.watchlist,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final stock = items[i];
        final wl = _findWl(stock.code, watchlist);
        final isFav = favorites.contains(stock.code);
        return _GridTile(stock: stock, watchlist: wl, isFavorite: isFav)
            .animate()
            .fadeIn(
                duration: 220.ms, delay: (i * 18).clamp(0, 400).ms)
            .slideY(begin: 0.06, end: 0);
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  final StockItem stock;
  final WatchlistItem? watchlist;
  final bool isFavorite;

  const _GridTile({
    required this.stock,
    required this.watchlist,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrice = watchlist != null;
    final isUp = watchlist?.up ?? true;
    final color = isUp ? AppTheme.stockUp : AppTheme.stockDown;
    final sector = AppConfig.sectorOf(stock.code);

    return InkWell(
      onTap: () => context.push('/analysis/${stock.code}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
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
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stock.code,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                if (isFavorite)
                  const Icon(Icons.star_rounded,
                      size: 13, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              stock.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const Spacer(),
            Sparkline(
              symbol: stock.code,
              isUp: isUp,
              color: hasPrice
                  ? color
                  : AppTheme.textMuted.withValues(alpha: 0.5),
              width: double.infinity,
              height: 24,
              fill: true,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasPrice ? '₺${watchlist!.price}' : sector,
                  style: TextStyle(
                    fontSize: hasPrice ? 12.5 : 10,
                    fontWeight:
                        hasPrice ? FontWeight.w700 : FontWeight.w600,
                    color: hasPrice
                        ? AppTheme.textPrimary
                        : AppTheme.textMuted,
                  ),
                ),
                if (hasPrice)
                  Text(
                    watchlist!.change,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  )
                else
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 10, color: AppTheme.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ EMPTY ============================
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_off_rounded,
              size: 48, color: AppTheme.textMuted),
          SizedBox(height: 12),
          Text(
            'Eşleşen hisse bulunamadı',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Filtreleri ya da arama metnini değiştir',
            style: TextStyle(
              fontSize: 11.5,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

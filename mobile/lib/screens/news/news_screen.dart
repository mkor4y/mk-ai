/// MK AI - Haberler Ekrani (Profesyonel UI)
///
/// Ozellikler:
/// - Featured (one cikan) haber + buyuk resim
/// - Liste karti (sol thumbnail + sag icerik)
/// - 4 kategori filtresi
/// - Arama cubugu (baslik + aciklama)
/// - Kaydet/bookmark (kalici)
/// - Paylas (sistem share)
/// - In-app WebView
/// - Hisse chip > analiz ekrani
/// - Sentiment renkli baslik (yesil/kirmizi/beyaz)
/// - Okundu state (solgun)
/// - Otomatik 5dk yenileme + skeleton + pull-to-refresh
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../config/app_theme.dart';
import '../../models/news_item.dart';
import '../../providers/providers.dart';
import 'news_webview_screen.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openArticle(NewsArticle article) {
    ref.read(readNewsProvider.notifier).markRead(article.link);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NewsWebViewScreen(
        url: article.link,
        title: article.source,
      ),
    ));
  }

  Future<void> _shareArticle(NewsArticle article) async {
    final text = '${article.title}\n${article.link}';
    await Share.share(text, subject: article.title);
  }

  @override
  Widget build(BuildContext context) {
    // Auto-refresh timer'ini bu sekme acikken aktif tut
    ref.watch(newsAutoRefreshProvider);

    final newsAsync = ref.watch(newsListProvider);
    final selectedCategory = ref.watch(selectedNewsCategoryProvider);
    final searchQuery = ref.watch(newsSearchQueryProvider);
    final readSet = ref.watch(readNewsProvider);
    final bookmarked = ref.watch(bookmarkedNewsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          backgroundColor: AppTheme.bgSecondary,
          onRefresh: () => ref.refresh(newsListProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  showSearch: _showSearch,
                  onToggleSearch: () {
                    setState(() => _showSearch = !_showSearch);
                    if (!_showSearch) {
                      _searchController.clear();
                      ref.read(newsSearchQueryProvider.notifier).state = '';
                    }
                  },
                  savedCount: bookmarked.length,
                  onOpenSaved: () => context.push('/saved-news'),
                ),
              ),

              if (_showSearch)
                SliverToBoxAdapter(
                  child: _SearchBar(
                    controller: _searchController,
                    onChanged: (q) =>
                        ref.read(newsSearchQueryProvider.notifier).state = q,
                  ),
                ),

              SliverToBoxAdapter(
                child: _CategoryChips(selected: selectedCategory),
              ),

              newsAsync.when(
                loading: () => const SliverToBoxAdapter(child: _NewsSkeleton()),
                error: (e, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorView(
                    message: e.toString().replaceFirst('Exception: ', ''),
                    onRetry: () => ref.invalidate(newsListProvider),
                  ),
                ),
                data: (all) {
                  final filtered = _applyFilters(
                      all, selectedCategory, searchQuery);

                  if (filtered.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyView(),
                    );
                  }

                  final NewsArticle featured = filtered.firstWhere(
                      (n) => n.hasImage,
                      orElse: () => filtered.first);
                  final rest = filtered
                      .where((n) => identical(n, featured) == false)
                      .toList();

                  return SliverList.builder(
                    itemCount: rest.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                          child: _FeaturedCard(
                            article: featured,
                            isRead: readSet.contains(featured.link),
                            isBookmarked: bookmarked
                                .any((b) => b.link == featured.link),
                            onTap: () => _openArticle(featured),
                            onBookmark: () => ref
                                .read(bookmarkedNewsProvider.notifier)
                                .toggle(featured),
                            onShare: () => _shareArticle(featured),
                          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                        );
                      }
                      if (index == 1) {
                        return _SectionLabel(count: filtered.length);
                      }

                      final item = rest[index - 2];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _NewsListCard(
                          article: item,
                          isRead: readSet.contains(item.link),
                          isBookmarked:
                              bookmarked.any((b) => b.link == item.link),
                          onTap: () => _openArticle(item),
                          onBookmark: () => ref
                              .read(bookmarkedNewsProvider.notifier)
                              .toggle(item),
                          onShare: () => _shareArticle(item),
                        )
                            .animate()
                            .fadeIn(
                                duration: 250.ms,
                                delay: ((index - 2) * 25).clamp(0, 600).ms)
                            .slideY(begin: 0.06, end: 0),
                      );
                    },
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  List<NewsArticle> _applyFilters(
    List<NewsArticle> all,
    NewsCategory category,
    String search,
  ) {
    Iterable<NewsArticle> r = all;
    if (category != NewsCategory.all) {
      r = r.where((n) => n.category == category);
    }
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      r = r.where((n) =>
          n.title.toLowerCase().contains(q) ||
          n.description.toLowerCase().contains(q) ||
          n.source.toLowerCase().contains(q));
    }
    return r.toList();
  }
}

// ============================ HEADER ============================
class _Header extends StatelessWidget {
  final bool showSearch;
  final VoidCallback onToggleSearch;
  final int savedCount;
  final VoidCallback onOpenSaved;

  const _Header({
    required this.showSearch,
    required this.onToggleSearch,
    required this.savedCount,
    required this.onOpenSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Haberler',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.stockUp.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppTheme.stockUp.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppTheme.stockUp,
                              shape: BoxShape.circle,
                            ),
                          )
                              .animate(
                                  onPlay: (c) => c.repeat(reverse: true))
                              .fadeIn(duration: 800.ms),
                          const SizedBox(width: 5),
                          const Text(
                            'CANLI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.stockUp,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Anlik finans + global piyasa haberleri',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textMuted.withValues(alpha: 0.9),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          _IconAction(
            icon: showSearch
                ? Icons.close_rounded
                : Icons.search_rounded,
            onTap: onToggleSearch,
          ),
          _IconAction(
            icon: Icons.bookmark_rounded,
            onTap: onOpenSaved,
            badge: savedCount > 0 ? '$savedCount' : null,
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
  const _IconAction({required this.icon, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, color: AppTheme.textPrimary, size: 22),
          onPressed: onTap,
        ),
        if (badge != null)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.stockUp,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.bgPrimary, width: 1.2),
              ),
              constraints:
                  const BoxConstraints(minWidth: 16, minHeight: 14),
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
    );
  }
}

// ============================ SEARCH BAR ============================
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgTertiary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: TextField(
          controller: controller,
          autofocus: true,
          onChanged: onChanged,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Haberlerde ara (THYAO, faiz, dolar...)',
            hintStyle: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppTheme.textMuted, size: 18),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: AppTheme.textMuted, size: 16),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 180.ms).slideY(begin: -0.1);
  }
}

// ============================ KATEGORI CHIPS ============================
class _CategoryChips extends ConsumerWidget {
  final NewsCategory selected;
  const _CategoryChips({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = NewsCategory.values;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                children: categories.map((cat) {
                  final isSelected = cat == selected;
                  return Flexible(
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => ref
                            .read(selectedNewsCategoryProvider.notifier)
                            .state = cat,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.textPrimary
                                : AppTheme.bgTertiary,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.textPrimary
                                  : AppTheme.border,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _iconFor(cat),
                                size: 13,
                                color: isSelected
                                    ? AppTheme.bgPrimary
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  cat.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppTheme.bgPrimary
                                        : AppTheme.textSecondary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(NewsCategory c) {
    switch (c) {
      case NewsCategory.all:
        return Icons.dynamic_feed_rounded;
      case NewsCategory.bist:
        return Icons.account_balance_rounded;
      case NewsCategory.global:
        return Icons.public_rounded;
      case NewsCategory.stockSpecific:
        return Icons.show_chart_rounded;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final int count;
  const _SectionLabel({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          const Text(
            'Son Haberler',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.bgTertiary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const Spacer(),
          Icon(Icons.bolt_rounded,
              size: 14, color: AppTheme.stockUp.withValues(alpha: 0.8)),
          const SizedBox(width: 4),
          const Text(
            'OTOMATİK YENİLENİR',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.stockUp,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ FEATURED CARD ============================
class _FeaturedCard extends StatelessWidget {
  final NewsArticle article;
  final bool isRead;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const _FeaturedCard({
    required this.article,
    required this.isRead,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isRead ? 0.7 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.border.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _NewsImage(
                        url: article.image,
                        placeholderText: article.source,
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _SourcePill(
                            source: article.source, featured: true),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatTime(article.publishedAt),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xCC000000),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _sentimentColor(article.sentiment),
                          height: 1.3,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (article.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          article.description,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                AppTheme.textMuted.withValues(alpha: 0.95),
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (article.matchedStockCodes.isNotEmpty)
                            ...article.matchedStockCodes
                                .take(2)
                                .map((c) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 6),
                                      child: _StockChip(code: c),
                                    )),
                          const Spacer(),
                          _CardActionIcon(
                            icon: Icons.ios_share_rounded,
                            onTap: onShare,
                          ),
                          const SizedBox(width: 4),
                          _CardActionIcon(
                            icon: isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: isBookmarked ? AppTheme.stockUp : null,
                            onTap: onBookmark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================ LIST CARD ============================
class _NewsListCard extends StatelessWidget {
  final NewsArticle article;
  final bool isRead;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const _NewsListCard({
    required this.article,
    required this.isRead,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isRead ? 0.7 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? AppTheme.border.withValues(alpha: 0.3)
                  : AppTheme.border.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: _NewsImage(
                    url: article.image,
                    placeholderText: article.source,
                    compact: true,
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
                        Expanded(child: _SourcePill(source: article.source)),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(article.publishedAt),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _sentimentColor(article.sentiment),
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (article.matchedStockCodes.isNotEmpty)
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: article.matchedStockCodes
                                  .take(3)
                                  .map((c) => _StockChip(code: c))
                                  .toList(),
                            ),
                          )
                        else
                          const Spacer(),
                        _CardActionIcon(
                          icon: Icons.ios_share_rounded,
                          onTap: onShare,
                          dense: true,
                        ),
                        const SizedBox(width: 2),
                        _CardActionIcon(
                          icon: isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isBookmarked ? AppTheme.stockUp : null,
                          onTap: onBookmark,
                          dense: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool dense;
  const _CardActionIcon({
    required this.icon,
    required this.onTap,
    this.color,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: dense ? 14 : 18,
      child: Padding(
        padding: EdgeInsets.all(dense ? 4 : 6),
        child: Icon(
          icon,
          size: dense ? 16 : 18,
          color: color ?? AppTheme.textMuted,
        ),
      ),
    );
  }
}

// ============================ NEWS IMAGE ============================
class _NewsImage extends StatelessWidget {
  final String? url;
  final String placeholderText;
  final bool compact;

  const _NewsImage({
    required this.url,
    required this.placeholderText,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _placeholder();
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, __) => Container(
        color: AppTheme.bgTertiary,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textMuted),
            ),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    final initial =
        (placeholderText.isNotEmpty ? placeholderText[0] : '?').toUpperCase();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bgTertiary, Colors.black],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: compact ? 22 : 38,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            if (!compact) ...[
              const SizedBox(height: 6),
              Text(
                initial,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================ SOURCE PILL ============================
class _SourcePill extends StatelessWidget {
  final String source;
  final bool featured;
  const _SourcePill({required this.source, this.featured = false});

  @override
  Widget build(BuildContext context) {
    final bg = featured
        ? Colors.black.withValues(alpha: 0.55)
        : AppTheme.bgTertiary;
    final fg = featured ? Colors.white : AppTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        source.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ============================ STOCK CHIP (TAP-TO-ANALYSIS) ============================
class _StockChip extends StatelessWidget {
  final String code;
  const _StockChip({required this.code});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/analysis/$code'),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.stockUp.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppTheme.stockUp.withValues(alpha: 0.35),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppTheme.stockUp,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.arrow_outward_rounded,
                size: 10, color: AppTheme.stockUp),
          ],
        ),
      ),
    );
  }
}

// ============================ SKELETON ============================
class _NewsSkeleton extends StatelessWidget {
  const _NewsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(height: 200, radius: 16),
          const SizedBox(height: 12),
          _shimmerBox(height: 16, width: 120),
          const SizedBox(height: 16),
          for (int i = 0; i < 5; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(height: 84, width: 84, radius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(height: 10, width: 60),
                      const SizedBox(height: 8),
                      _shimmerBox(height: 14),
                      const SizedBox(height: 6),
                      _shimmerBox(height: 14, width: 200),
                      const SizedBox(height: 6),
                      _shimmerBox(height: 14, width: 150),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _shimmerBox({double height = 14, double? width, double radius = 6}) {
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

// ============================ ERROR / EMPTY ============================
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
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppTheme.stockDown),
            const SizedBox(height: 12),
            const Text(
              'Haberler yüklenemedi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textMuted),
          SizedBox(height: 12),
          Text(
            'Eşleşen haber bulunamadı',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ HELPERS ============================
String _formatTime(DateTime? dt) {
  if (dt == null) return '';
  return timeago.format(dt, locale: 'tr');
}

Color _sentimentColor(NewsSentiment s) {
  switch (s) {
    case NewsSentiment.positive:
      return AppTheme.stockUp;
    case NewsSentiment.negative:
      return AppTheme.stockDown;
    case NewsSentiment.neutral:
      return AppTheme.textPrimary;
  }
}

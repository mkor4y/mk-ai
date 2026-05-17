/// MK AI - Kaydedilen Haberler Ekrani
///
/// Kullanicinin bookmark ile kaydettigi haberleri liste halinde gosterir.
/// Boyle bir haber yoksa bos durum widget'i, varsa "tumunu temizle" butonu.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../config/app_theme.dart';
import '../../models/news_item.dart';
import '../../providers/providers.dart';
import 'news_webview_screen.dart';

class SavedNewsScreen extends ConsumerWidget {
  const SavedNewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(bookmarkedNewsProvider);
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
          'Kaydedilen Haberler',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          if (saved.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: const Text(
                'Temizle',
                style: TextStyle(
                  color: AppTheme.stockDown,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: saved.isEmpty
          ? _Empty()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: saved.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final article = saved[i];
                return Dismissible(
                  key: ValueKey(article.link),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.stockDown.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: AppTheme.stockDown, size: 22),
                  ),
                  onDismissed: (_) {
                    ref.read(bookmarkedNewsProvider.notifier)
                        .remove(article.link);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.bgTertiary,
                        content: const Text('Haber kaldırıldı',
                            style: TextStyle(color: AppTheme.textPrimary)),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'Geri Al',
                          textColor: AppTheme.stockUp,
                          onPressed: () => ref
                              .read(bookmarkedNewsProvider.notifier)
                              .toggle(article),
                        ),
                      ),
                    );
                  },
                  child: _SavedCard(article: article)
                      .animate()
                      .fadeIn(duration: 250.ms, delay: (i * 25).clamp(0, 400).ms)
                      .slideY(begin: 0.05, end: 0),
                );
              },
            ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: const Text('Tümünü Temizle?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Kaydedilen tüm haberler silinecek. Bu işlem geri alınamaz.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(bookmarkedNewsProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Sil',
                style: TextStyle(color: AppTheme.stockDown)),
          ),
        ],
      ),
    );
  }
}

class _SavedCard extends ConsumerWidget {
  final NewsArticle article;
  const _SavedCard({required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(readNewsProvider.notifier).markRead(article.link);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => NewsWebViewScreen(
            url: article.link,
            title: article.source,
          ),
        ));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 70,
                height: 70,
                child: (article.hasImage)
                    ? CachedNetworkImage(
                        imageUrl: article.image!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppTheme.bgTertiary),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.source.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                  if (article.publishedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(article.publishedAt!, locale: 'tr'),
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppTheme.bgTertiary,
        child: const Icon(Icons.bookmark_rounded,
            color: AppTheme.textMuted, size: 22),
      );
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

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.bookmark_outline_rounded,
              size: 56, color: AppTheme.textMuted),
          SizedBox(height: 12),
          Text(
            'Kaydedilen haber yok',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Bir haberi sonra okumak için haberin yanındaki yer işareti ikonuna basabilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: AppTheme.textMuted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

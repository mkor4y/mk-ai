/// MK AI - Haberler Ekranı
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';
import '../../services/api_client.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _newsList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.instance.get(AppConfig.newsUrl);
      if (response.data != null && response.data['success'] == true) {
        setState(() {
          _newsList = response.data['news'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Haberler alınamadı.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Sunucuya bağlanılamadı.';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Haber Akışı',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'BIST ve global piyasalardan anlık RSS beslemeleri',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: AppTheme.border.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),

            // İçerik
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorView()
                      : _newsList.isEmpty
                          ? _buildEmptyView()
                          : RefreshIndicator(
                              color: AppTheme.accent,
                              backgroundColor: AppTheme.bgSecondary,
                              onRefresh: _fetchNews,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                itemCount: _newsList.length,
                                separatorBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(
                                    height: 1,
                                    color: AppTheme.border.withValues(alpha: 0.3),
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  final item = _newsList[index];
                                  return _buildNewsItem(item, index);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(dynamic item, int index) {
    final title = item['title'] ?? '';
    final source = item['source'] ?? 'Finans';
    final published = item['published'] ?? '';
    final link = item['link'] ?? '';

    return InkWell(
      onTap: () => _launchUrl(link),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kaynak & Tarih Satırı
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.bgTertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    source.toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  published,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Başlık
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.stockDown),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Hata',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bgTertiary,
              foregroundColor: AppTheme.textPrimary,
              elevation: 0,
            ),
            onPressed: _fetchNews,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'Haber akışı boş',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _fetchNews,
            child: const Text('Yenile', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

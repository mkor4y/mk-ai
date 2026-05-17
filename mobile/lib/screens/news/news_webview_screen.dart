/// MK AI - In-App Haber WebView Ekrani
///
/// Haber linkini cihazin tarayicisi yerine uygulama icinde acar.
/// Sag ust kosede "harici tarayicida ac" + "paylas" + "yenile" butonlari.
library;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/app_theme.dart';

class NewsWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const NewsWebViewScreen({
    super.key,
    required this.url,
    this.title = '',
  });

  @override
  State<NewsWebViewScreen> createState() => _NewsWebViewScreenState();
}

class _NewsWebViewScreenState extends State<NewsWebViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.bgPrimary)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() {
          _progress = p;
          _loading = p < 100;
        }),
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _openExternal() async {
    if (await canLaunchUrlString(widget.url)) {
      await launchUrlString(widget.url,
          mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _share() async {
    final text = widget.title.isNotEmpty
        ? '${widget.title}\n${widget.url}'
        : widget.url;
    await Share.share(text, subject: widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        title: Text(
          widget.title.isEmpty ? 'Haber' : widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            tooltip: 'Paylas',
            icon: const Icon(Icons.ios_share_rounded, size: 20),
            onPressed: _share,
          ),
          IconButton(
            tooltip: 'Tarayicida ac',
            icon: const Icon(Icons.open_in_browser_rounded, size: 20),
            onPressed: _openExternal,
          ),
        ],
        bottom: _loading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 2,
                  backgroundColor: AppTheme.bgTertiary,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.stockUp),
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

/// MK AI - Chat Mesaj Balonu (markdown + uzun bas menu + provider rozeti)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../config/app_config.dart';
import '../../../config/app_theme.dart';
import '../../../models/analysis_result.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final VoidCallback? onRegenerate;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _Avatar(isUser: false, visible: showAvatar),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isUser && showAvatar) _ProviderHeader(message: message),
                GestureDetector(
                  onLongPress: () => _showActions(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: _bubbleColor(),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: isUser || message.isError
                          ? null
                          : Border.all(
                              color: AppTheme.border.withValues(alpha: 0.5),
                              width: 1,
                            ),
                    ),
                    child: _content(context),
                  ),
                ),
                const SizedBox(height: 4),
                _Footer(message: message, onRegenerate: onRegenerate),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _Avatar(isUser: true, visible: showAvatar),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Color _bubbleColor() {
    if (message.isError) return AppTheme.stockDown.withValues(alpha: 0.18);
    return message.isUser ? AppTheme.bgTertiary : AppTheme.bgSecondary;
  }

  Widget _content(BuildContext context) {
    // Kullanici mesajini ham metin goster (markdown render etmeye gerek yok)
    if (message.isUser) {
      return Text(
        message.content,
        style: const TextStyle(
          fontSize: 14.5,
          color: AppTheme.textPrimary,
          height: 1.45,
        ),
      );
    }

    return MarkdownBody(
      data: message.content,
      selectable: true,
      onTapLink: (text, href, title) async {
        if (href == null) return;
        // Hisse kod link'i ($THYAO -> /analysis/THYAO)
        if (href.startsWith('stock://')) {
          final code = href.substring(8).toUpperCase();
          context.push('/analysis/$code');
          return;
        }
        if (await canLaunchUrlString(href)) {
          await launchUrlString(href, mode: LaunchMode.externalApplication);
        }
      },
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          fontSize: 14.5,
          color: AppTheme.textSecondary,
          height: 1.5,
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
        em: const TextStyle(
          fontStyle: FontStyle.italic,
          color: AppTheme.textSecondary,
        ),
        h1: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
          height: 1.3,
        ),
        h2: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          height: 1.3,
        ),
        h3: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          height: 1.3,
        ),
        listBullet: const TextStyle(color: AppTheme.stockUp, fontSize: 14.5),
        code: TextStyle(
          fontSize: 13,
          color: AppTheme.stockUp,
          backgroundColor: AppTheme.bgTertiary.withValues(alpha: 0.6),
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        codeblockPadding: const EdgeInsets.all(10),
        blockquote: const TextStyle(
          color: AppTheme.textMuted,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppTheme.stockUp.withValues(alpha: 0.7),
              width: 3,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
        tableHead: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          fontSize: 13,
        ),
        tableBody: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
        ),
        tableBorder: TableBorder.all(
          color: AppTheme.border,
          width: 1,
        ),
        tableCellsPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        a: const TextStyle(
          color: AppTheme.stockUp,
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.stockUp,
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _ActionTile(
              icon: Icons.copy_rounded,
              label: 'Kopyala',
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.bgTertiary,
                    content: Text('Kopyalandı',
                        style: TextStyle(color: AppTheme.textPrimary)),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.ios_share_rounded,
              label: 'Paylaş',
              onTap: () {
                Navigator.pop(context);
                Share.share(message.content);
              },
            ),
            if (!message.isUser && onRegenerate != null)
              _ActionTile(
                icon: Icons.refresh_rounded,
                label: 'Yeniden Üret',
                onTap: () {
                  Navigator.pop(context);
                  onRegenerate!();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ProviderHeader extends StatelessWidget {
  final ChatMessage message;
  const _ProviderHeader({required this.message});

  @override
  Widget build(BuildContext context) {
    final providerLabel = _providerLabel(message.provider);
    final color = _providerColor(message.provider);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            providerLabel,
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

class _Footer extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRegenerate;
  const _Footer({required this.message, required this.onRegenerate});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.timestamp);
    final showRegen = !message.isUser && onRegenerate != null;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: message.isUser ? 4 : 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showRegen) ...[
            InkResponse(
              onTap: onRegenerate,
              radius: 14,
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.refresh_rounded,
                    size: 13, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final bool isUser;
  final bool visible;
  const _Avatar({required this.isUser, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox(width: 30, height: 30);
    }
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUser
              ? [AppTheme.bgTertiary, AppTheme.bgSecondary]
              : [
                  AppTheme.stockUp.withValues(alpha: 0.25),
                  AppTheme.stockUp.withValues(alpha: 0.05),
                ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isUser
              ? AppTheme.border
              : AppTheme.stockUp.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person_outline_rounded : Icons.auto_awesome_rounded,
          size: 15,
          color: isUser ? AppTheme.textMuted : AppTheme.stockUp,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary, size: 20),
      title: Text(label,
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
      dense: true,
    );
  }
}

String _providerLabel(String? provider) {
  switch (provider) {
    case 'bist-analyzer':
      return 'BIST ANALYZER';
    case 'chatgpt-education':
      return 'EĞİTİM AI';
    case 'chatgpt':
    case 'openai':
      return 'GPT';
    case 'groq':
      return 'GROQ';
    case 'openrouter':
      return 'OPENROUTER';
    case 'system':
      return 'MK AI';
    case 'error':
      return 'HATA';
    default:
      return (provider ?? 'MK AI').toUpperCase();
  }
}

Color _providerColor(String? provider) {
  switch (provider) {
    case 'bist-analyzer':
      return AppTheme.stockUp;
    case 'chatgpt-education':
      return Colors.amber;
    case 'chatgpt':
    case 'openai':
      return const Color(0xFF10A37F);
    case 'groq':
      return const Color(0xFFFF6B35);
    case 'openrouter':
      return const Color(0xFF5B8DEF);
    case 'error':
      return AppTheme.stockDown;
    case 'system':
    default:
      return AppTheme.textMuted;
  }
}

/// Yardimci: AI yanitindaki hisse kodlarini ($THYAO veya  THYAO ) markdown link'e cevir.
String enrichWithStockLinks(String text) {
  // BIST hisse kodu listesi sirasiyla kontrol et (en uzun kod onde olmali)
  final codes = AppConfig.stockCodes
      .map((c) => c.toUpperCase())
      .toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  String out = text;
  for (final code in codes) {
    // Sadece kelime sinirindaki kodlari hedefle, zaten linklenmis olanlari atla
    final re = RegExp(r'(?<![\w\[\(])' + code + r'(?![\w\]\)])');
    out = out.replaceAllMapped(re, (m) => '[**$code**](stock://$code)');
  }
  return out;
}

/// Backend KAPSAMLI ANALIZ ciktisi `•` ile prefix'lenmis satirlar
/// dondurur ama markdown'da bunlar tek paragraph icine sigmis gibi
/// gorunur (cunku iki yerine tek newline var ve `•` markdown bullet degil).
///
/// Bu fonksiyon:
/// - `•` ile baslayan satirlari `- ` (markdown liste maddesi) yapar.
/// - Bir liste'nin onune (paragraph -> liste gecisinde) bos satir ekler
///   ki markdown gercek bir liste blogu olarak ayirabilsin.
/// - Cift bos satir varsa birine indirir (gereksiz bosluga karsi).
String normalizeAnalysisText(String input) {
  if (input.isEmpty) return input;

  final lines = input.split('\n');
  final out = <String>[];

  bool isBullet(String l) {
    final t = l.trimLeft();
    return t.startsWith('• ') || t.startsWith('•') || t.startsWith('-  ');
  }

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trimLeft();

    if (isBullet(trimmed)) {
      // Bullet karakterini at, "- " ile baslat
      var content = trimmed;
      if (content.startsWith('•')) {
        content = content.substring(1).trimLeft();
      } else if (content.startsWith('- ')) {
        content = content.substring(2);
      }
      // Onceki satir bos da degilse, bullet de degilse -> paragraph'tan
      // liste'ye gecis: arada bos satir lazim
      if (out.isNotEmpty &&
          out.last.trim().isNotEmpty &&
          !out.last.trimLeft().startsWith('- ')) {
        out.add('');
      }
      out.add('- $content');
    } else {
      // Cift bos satir varsa atla
      if (line.trim().isEmpty &&
          out.isNotEmpty &&
          out.last.trim().isEmpty) {
        continue;
      }
      out.add(line);
    }
  }
  return out.join('\n');
}

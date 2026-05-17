/// MK AI - AI Chat Ekrani (Profesyonel)
///
/// Ozellikler:
/// - Markdown render (flutter_markdown_plus)
/// - Provider rozeti (GPT / GROQ / BIST-ANALYZER vs.)
/// - Kalici sohbet gecmisi (shared_preferences)
/// - Uzun bas menu (kopyala / paylas / yeniden uret)
/// - Bos ekranda kategorize edilmis prompt onerileri
/// - Hisse kod algilama (yanit icindeki THYAO -> link, tikla analize git)
/// - Tarih ayraclari (Bugun / Dun / 23 Eyl 2024)
/// - Auto-grow text input (max 5 satir)
/// - Scroll-to-bottom FAB
/// - Avatarli, gruplu mesaj balonu
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../models/analysis_result.dart';
import '../../providers/providers.dart';
import 'widgets/message_bubble.dart';
import 'widgets/suggestions_panel.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _inputFocus = FocusNode();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final atBottom =
        _scrollCtrl.offset >= _scrollCtrl.position.maxScrollExtent - 120;
    if (atBottom == _showScrollToBottom) {
      setState(() => _showScrollToBottom = !atBottom);
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollCtrl.hasClients) return;
    final target = _scrollCtrl.position.maxScrollExtent + 100;
    if (animate) {
      _scrollCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(target);
    }
  }

  void _send([String? text]) {
    final value = (text ?? _controller.text).trim();
    if (value.isEmpty) return;
    _controller.clear();
    ref.read(chatMessagesProvider.notifier).sendMessage(value);
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: const Text('Sohbeti Temizle?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Tüm mesajlar silinecek. Bu işlem geri alınamaz.',
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
              ref.read(chatMessagesProvider.notifier).clearMessages();
              Navigator.pop(context);
            },
            child: const Text('Temizle',
                style: TextStyle(color: AppTheme.stockDown)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatLoadingProvider);

    // Yeni mesaj geldiginde otomatik scroll
    ref.listen<List<ChatMessage>>(chatMessagesProvider, (prev, next) {
      if (prev != null && next.length > prev.length) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    // Hisse kodlarini link'e cevir + analiz ciktisini normalize et
    final enriched = messages.map((m) {
      if (m.isUser || m.isError) return m;
      final normalized = normalizeAnalysisText(m.content);
      return ChatMessage(
        id: m.id,
        content: enrichWithStockLinks(normalized),
        isUser: false,
        timestamp: m.timestamp,
        provider: m.provider,
        isError: m.isError,
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onClear: messages.isEmpty ? null : _confirmClear,
              messageCount: messages.length,
              isLoading: isLoading,
            ),
            Expanded(
              child: Stack(
                children: [
                  messages.isEmpty && !isLoading
                      ? SingleChildScrollView(
                          child: SuggestionsPanel(
                            onPromptTap: (p) {
                              _controller.text = p;
                              _send();
                            },
                          ),
                        )
                      : _MessageList(
                          messages: enriched,
                          isLoading: isLoading,
                          scrollCtrl: _scrollCtrl,
                          onRegenerate: () => ref
                              .read(chatMessagesProvider.notifier)
                              .regenerateLastResponse(),
                        ),
                  if (_showScrollToBottom)
                    Positioned(
                      right: 16,
                      bottom: 12,
                      child: _ScrollToBottomFab(onTap: _scrollToBottom),
                    ),
                ],
              ),
            ),
            _ComposerBar(
              controller: _controller,
              focusNode: _inputFocus,
              isLoading: isLoading,
              onSend: () => _send(),
              onQuickPrompt: (p) => _send(p),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ HEADER ============================
class _Header extends StatelessWidget {
  final VoidCallback? onClear;
  final int messageCount;
  final bool isLoading;
  const _Header({
    required this.onClear,
    required this.messageCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: const BoxDecoration(
        color: AppTheme.bgPrimary,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.stockUp.withValues(alpha: 0.3),
                  AppTheme.stockUp.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.stockUp.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded,
                  color: AppTheme.stockUp, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MK AI Asistan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isLoading
                            ? Colors.amber
                            : AppTheme.stockUp,
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(
                            onPlay: (c) => c.repeat(reverse: true))
                        .fadeIn(duration: 800.ms),
                    const SizedBox(width: 5),
                    Text(
                      isLoading ? 'Yazıyor...' : 'Çevrimiçi',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLoading
                            ? Colors.amber
                            : AppTheme.stockUp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (messageCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.bgTertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$messageCount mesaj',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onClear != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.textMuted, size: 22),
              onPressed: onClear,
              tooltip: 'Sohbeti temizle',
            ),
        ],
      ),
    );
  }
}

// ============================ MESSAGE LIST ============================
class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ScrollController scrollCtrl;
  final VoidCallback onRegenerate;

  const _MessageList({
    required this.messages,
    required this.isLoading,
    required this.scrollCtrl,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(messages);
    final itemCount = items.length + (isLoading ? 1 : 0);

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      itemCount: itemCount,
      itemBuilder: (ctx, i) {
        if (i == items.length && isLoading) {
          return const TypingIndicator();
        }
        final item = items[i];
        if (item is _DateSeparatorItem) {
          return _DateSeparator(label: item.label);
        }
        final m = (item as _MessageItem);
        final isLastBotMessage =
            !m.message.isUser && _isLastBotMessage(items, i);
        return MessageBubble(
          message: m.message,
          showAvatar: m.showAvatar,
          onRegenerate: isLastBotMessage ? onRegenerate : null,
        );
      },
    );
  }

  bool _isLastBotMessage(List<_ListItem> items, int index) {
    for (int i = index + 1; i < items.length; i++) {
      if (items[i] is _MessageItem) return false;
    }
    return true;
  }

  /// Mesajlari tarih ayracli + ardisik mesajlari gruplayarak duzenler
  static List<_ListItem> _buildItems(List<ChatMessage> messages) {
    final out = <_ListItem>[];
    DateTime? lastDate;
    bool? lastIsUser;

    for (final m in messages) {
      final day = DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
      if (lastDate == null || lastDate != day) {
        out.add(_DateSeparatorItem(label: _formatDayLabel(day)));
        lastDate = day;
        lastIsUser = null;
      }
      // Ayni gondericinin ardisik mesajlarinda sadece ilkinde avatar goster
      final showAvatar = lastIsUser != m.isUser;
      out.add(_MessageItem(message: m, showAvatar: showAvatar));
      lastIsUser = m.isUser;
    }
    return out;
  }
}

sealed class _ListItem {}

class _MessageItem extends _ListItem {
  final ChatMessage message;
  final bool showAvatar;
  _MessageItem({required this.message, required this.showAvatar});
}

class _DateSeparatorItem extends _ListItem {
  final String label;
  _DateSeparatorItem({required this.label});
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
              child: Divider(
                  color: AppTheme.border.withValues(alpha: 0.5),
                  height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
              child: Divider(
                  color: AppTheme.border.withValues(alpha: 0.5),
                  height: 1)),
        ],
      ),
    );
  }
}

String _formatDayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  if (day == today) return 'Bugün';
  if (day == yesterday) return 'Dün';
  return DateFormat('d MMMM yyyy', 'tr_TR').format(day);
}

// ============================ SCROLL FAB ============================
class _ScrollToBottomFab extends StatelessWidget {
  final VoidCallback onTap;
  const _ScrollToBottomFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.bgSecondary,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: const Icon(
            Icons.arrow_downward_rounded,
            color: AppTheme.textPrimary,
            size: 20,
          ),
        ),
      ),
    ).animate().scale(
          duration: 180.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
        );
  }
}

// ============================ COMPOSER BAR (INPUT) ============================
class _ComposerBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;
  final void Function(String) onQuickPrompt;

  const _ComposerBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
    required this.onQuickPrompt,
  });

  @override
  State<_ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<_ComposerBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgPrimary,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick prompt rozetleri (sadece bos input + bos olmayan sohbet'te degil)
            if (!hasText && !widget.isLoading)
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  children: [
                    _QuickPromptChip(
                      label: 'THYAO Analiz',
                      icon: Icons.show_chart_rounded,
                      onTap: () => widget.onQuickPrompt('THYAO analiz yap'),
                    ),
                    const SizedBox(width: 6),
                    _QuickPromptChip(
                      label: 'BIST 100',
                      icon: Icons.public_rounded,
                      onTap: () =>
                          widget.onQuickPrompt('BIST 100 piyasa durumu'),
                    ),
                    const SizedBox(width: 6),
                    _QuickPromptChip(
                      label: 'RSI Nedir?',
                      icon: Icons.school_rounded,
                      onTap: () =>
                          widget.onQuickPrompt('RSI göstergesini açıkla'),
                    ),
                    const SizedBox(width: 6),
                    _QuickPromptChip(
                      label: 'Yardım',
                      icon: Icons.help_outline_rounded,
                      onTap: () => widget.onQuickPrompt('yardım'),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.focusNode.hasFocus
                            ? AppTheme.stockUp.withValues(alpha: 0.4)
                            : AppTheme.border,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      enabled: !widget.isLoading,
                      maxLines: 5,
                      minLines: 1,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'AI’a soru sor...',
                        hintStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => widget.onSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SendButton(
                  isLoading: widget.isLoading,
                  enabled: hasText && !widget.isLoading,
                  onTap: widget.onSend,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;
  const _SendButton({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    AppTheme.stockUp,
                    AppTheme.stockUp.withValues(alpha: 0.7),
                  ],
                )
              : null,
          color: enabled ? null : AppTheme.bgTertiary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
                  ),
                )
              : Icon(
                  Icons.arrow_upward_rounded,
                  color: enabled
                      ? AppTheme.bgPrimary
                      : AppTheme.textMuted,
                  size: 22,
                ),
        ),
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickPromptChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.bgTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.border.withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppTheme.stockUp),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

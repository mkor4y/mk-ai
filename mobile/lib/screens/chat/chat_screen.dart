/// MK AI - AI Chat Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/analysis_result.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() { _controller.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(chatMessagesProvider.notifier).sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent + 100, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatLoadingProvider);

    // Auto scroll on new messages
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return SafeArea(
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: const BoxDecoration(
            color: AppTheme.bgPrimary, 
            border: Border(bottom: BorderSide(color: AppTheme.border))
          ),
          child: const Row(children: [
            Text('🤖', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MK AI Asistan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5)),
              Text('Borsa İstanbul analiz botu', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ]),
          ]),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length + (isLoading ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == messages.length && isLoading) return _buildTypingIndicator();
              return _MessageBubble(message: messages[i]);
            },
          ),
        ),

        // Quick actions
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            _QuickBtn(label: 'THYAO Analiz', onTap: () { _controller.text = 'THYAO analiz yap'; _send(); }),
            _QuickBtn(label: 'Piyasa Durumu', onTap: () { _controller.text = 'BIST piyasa durumu'; _send(); }),
            _QuickBtn(label: 'RSI Nedir?', onTap: () { _controller.text = 'RSI göstergesini açıkla'; _send(); }),
            _QuickBtn(label: 'Yardım', onTap: () { _controller.text = 'yardım'; _send(); }),
          ]),
        ),

        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: const BoxDecoration(
            color: AppTheme.bgPrimary, 
            border: Border(top: BorderSide(color: AppTheme.border))
          ),
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Mesaj yazın...', 
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                  border: InputBorder.none, 
                  isDense: true, 
                  contentPadding: EdgeInsets.symmetric(vertical: 10)
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppTheme.bgTertiary, borderRadius: BorderRadius.circular(22)),
                  child: const Icon(Icons.arrow_upward_rounded, color: AppTheme.textPrimary, size: 24),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppTheme.bgTertiary, borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ...[0, 1, 2].map((i) => Container(
            width: 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.6), shape: BoxShape.circle),
          ).animate(onPlay: (c) => c.repeat()).fadeIn(delay: (i * 200).ms).then().fadeOut(delay: 400.ms)),
        ]),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.bgTertiary : AppTheme.bgSecondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4), bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: AppTheme.border),
        ),
        child: Text(message.content, style: TextStyle(fontSize: 14, color: isUser ? AppTheme.textPrimary : AppTheme.textSecondary, height: 1.5)),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2))),
        child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

/// MK AI - Bos chat ekraninda kullaniciya kategorize edilmis oneriler.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_theme.dart';

class SuggestionCategory {
  final String label;
  final IconData icon;
  final Color color;
  final List<String> prompts;
  const SuggestionCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.prompts,
  });
}

const suggestionCategories = [
  SuggestionCategory(
    label: 'Hisse Analizi',
    icon: Icons.show_chart_rounded,
    color: AppTheme.stockUp,
    prompts: [
      'THYAO analiz yap',
      'AKBNK son durum',
      'ASELS teknik analiz',
      'GARAN için al/sat sinyali',
    ],
  ),
  SuggestionCategory(
    label: 'Piyasa & Endeks',
    icon: Icons.public_rounded,
    color: Color(0xFF5B8DEF),
    prompts: [
      'BIST 100 bugün nasıl?',
      'BIST 30 piyasa özeti',
      'Bugün en çok kazanan hisseler',
      'Dolar TL durumu nasıl?',
    ],
  ),
  SuggestionCategory(
    label: 'Eğitim',
    icon: Icons.school_rounded,
    color: Colors.amber,
    prompts: [
      'RSI göstergesini açıkla',
      'MACD nasıl yorumlanır?',
      'Bollinger Bands nedir?',
      'Risk yönetimi temelleri',
    ],
  ),
  SuggestionCategory(
    label: 'Yardım',
    icon: Icons.help_outline_rounded,
    color: AppTheme.textMuted,
    prompts: [
      'Bu uygulama ne yapar?',
      'Hangi hisseler destekleniyor?',
      'Sinyal güvenilirliği ne demek?',
    ],
  ),
];

class SuggestionsPanel extends StatelessWidget {
  final void Function(String prompt) onPromptTap;
  const SuggestionsPanel({super.key, required this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(),
          const SizedBox(height: 28),
          const Text(
            'Nereden başlayalım?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          ...suggestionCategories.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryCard(
                category: entry.value,
                onPromptTap: onPromptTap,
              )
                  .animate()
                  .fadeIn(
                      delay: (200 + entry.key * 80).ms, duration: 350.ms)
                  .slideY(begin: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.stockUp.withValues(alpha: 0.15),
            AppTheme.bgSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.stockUp.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.stockUp.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppTheme.stockUp, size: 22),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2000.ms, color: AppTheme.stockUp.withValues(alpha: 0.3)),
          const SizedBox(height: 14),
          const Text(
            'Merhaba, ben MK AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'BIST hisseleri için teknik analiz, eğitim ve piyasa içgörüleri sunan AI asistanın.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final SuggestionCategory category;
  final void Function(String) onPromptTap;
  const _CategoryCard({required this.category, required this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(category.icon,
                    color: category.color, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                category.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: category.prompts
                .map((p) => _PromptChip(
                      prompt: p,
                      color: category.color,
                      onTap: () => onPromptTap(p),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  final String prompt;
  final Color color;
  final VoidCallback onTap;
  const _PromptChip({
    required this.prompt,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.bgTertiary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              prompt,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

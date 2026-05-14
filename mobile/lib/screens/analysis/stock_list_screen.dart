/// MK AI - Hisse Seçim Listesi
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});
  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  String _searchQuery = '';

  List<StockItem> get _filtered {
    if (_searchQuery.isEmpty) return AppConfig.supportedStocks;
    final q = _searchQuery.toLowerCase();
    return AppConfig.supportedStocks
        .where((s) => s.code.toLowerCase().contains(q) || s.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hisseler', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1.0, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: AppTheme.bgTertiary, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Hisse ara...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, color: AppTheme.textMuted), onPressed: () => setState(() => _searchQuery = ''))
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final stock = _filtered[i];
                return InkWell(
                  onTap: () => context.push('/analysis/${stock.code}'),
                  splashColor: AppTheme.bgTertiary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(stock.code, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Text(stock.name, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted), overflow: TextOverflow.ellipsis),
                      ])),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textMuted),
                    ]),
                  ),
                ).animate().fadeIn();
              },
            ),
          ),
        ],
      ),
    );
  }
}

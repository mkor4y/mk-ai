/// MK AI - Portfoye Yeni Pozisyon Ekleme / Duzenleme Sheet'i
///
/// Bottom sheet olarak acilir. Hem yeni ekleme hem duzenleme icin kullanilir.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_config.dart';
import '../../../config/app_theme.dart';
import '../../../models/holding.dart';
import '../../../providers/providers.dart';

/// Sheet'i acmak icin yardimci. Returns true if saved.
Future<bool> showAddHoldingSheet(
  BuildContext context, {
  Holding? editing,
  String? initialSymbol,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddHoldingSheet(
      editing: editing,
      initialSymbol: initialSymbol,
    ),
  );
  return result ?? false;
}

class _AddHoldingSheet extends ConsumerStatefulWidget {
  final Holding? editing;
  final String? initialSymbol;

  const _AddHoldingSheet({this.editing, this.initialSymbol});

  @override
  ConsumerState<_AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends ConsumerState<_AddHoldingSheet> {
  late final TextEditingController _qty;
  late final TextEditingController _cost;
  late final TextEditingController _note;
  late String _symbol;

  @override
  void initState() {
    super.initState();
    final h = widget.editing;
    _symbol = (widget.editing?.symbol ??
            widget.initialSymbol ??
            AppConfig.supportedStocks.first.code)
        .toUpperCase();
    _qty = TextEditingController(
        text: h != null && h.quantity > 0 ? _trim(h.quantity) : '');
    _cost = TextEditingController(
        text: h != null && h.avgCost > 0 ? _trim(h.avgCost) : '');
    _note = TextEditingController(text: h?.note ?? '');
  }

  static String _trim(double v) {
    final s = v.toString();
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.editing != null;

  bool get _valid {
    final q = double.tryParse(_qty.text.replaceAll(',', '.'));
    final c = double.tryParse(_cost.text.replaceAll(',', '.'));
    return q != null && q > 0 && c != null && c > 0;
  }

  Future<void> _save() async {
    final q = double.parse(_qty.text.replaceAll(',', '.'));
    final c = double.parse(_cost.text.replaceAll(',', '.'));
    final name = AppConfig.stockName(_symbol);

    if (_isEditing) {
      final h = widget.editing!.copyWith(
        quantity: q,
        avgCost: c,
        name: name,
        note: _note.text.trim(),
      );
      await ref.read(portfolioProvider.notifier).update(h);
    } else {
      final h = Holding.create(
        symbol: _symbol,
        name: name,
        quantity: q,
        avgCost: c,
        note: _note.text.trim(),
      );
      await ref.read(portfolioProvider.notifier).add(h);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.stockUp.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppTheme.stockUp,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing ? 'Pozisyonu Düzenle' : 'Yeni Pozisyon',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ---- Hisse secimi (edit modunda disabled) ----
            const _Label('Hisse'),
            const SizedBox(height: 6),
            _SymbolPicker(
              value: _symbol,
              disabled: _isEditing,
              onChanged: (v) => setState(() => _symbol = v),
            ),

            const SizedBox(height: 14),
            const _Label('Adet'),
            const SizedBox(height: 6),
            _NumberField(
              controller: _qty,
              hint: 'Ör: 100',
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 14),
            const _Label('Ortalama Maliyet (TL)'),
            const SizedBox(height: 6),
            _NumberField(
              controller: _cost,
              hint: 'Ör: 145.50',
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 14),
            const _Label('Not (opsiyonel)'),
            const SizedBox(height: 6),
            TextField(
              controller: _note,
              maxLength: 80,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Kısa bir not...',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.bgTertiary,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Toplam maliyet ozeti
            if (_valid) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.stockUp.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.stockUp.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_rounded,
                        color: AppTheme.stockUp, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Toplam Maliyet',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatMoney(
                        double.parse(_qty.text.replaceAll(',', '.')) *
                            double.parse(_cost.text.replaceAll(',', '.')),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.stockUp,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _valid ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.stockUp,
                  foregroundColor: AppTheme.bgPrimary,
                  disabledBackgroundColor:
                      AppTheme.border.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isEditing ? 'Güncelle' : 'Pozisyonu Ekle',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _NumberField({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[\.,]?[0-9]*')),
      ],
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.bgTertiary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SymbolPicker extends StatelessWidget {
  final String value;
  final bool disabled;
  final ValueChanged<String> onChanged;

  const _SymbolPicker({
    required this.value,
    required this.disabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : () => _openPicker(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.bgTertiary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: disabled
                ? AppTheme.border.withValues(alpha: 0.3)
                : AppTheme.border.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.stockUp.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  value.isNotEmpty ? value.substring(0, 1) : '?',
                  style: const TextStyle(
                    color: AppTheme.stockUp,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppConfig.stockName(value),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            if (!disabled)
              const Icon(Icons.expand_more_rounded,
                  color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SymbolListSheet(selected: value),
    );
    if (picked != null && picked != value) onChanged(picked);
  }
}

class _SymbolListSheet extends StatefulWidget {
  final String selected;
  const _SymbolListSheet({required this.selected});

  @override
  State<_SymbolListSheet> createState() => _SymbolListSheetState();
}

class _SymbolListSheetState extends State<_SymbolListSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final all = AppConfig.supportedStocks;
    final q = _query.trim().toUpperCase();
    final filtered = q.isEmpty
        ? all
        : all
            .where((s) =>
                s.code.contains(q) ||
                s.name.toUpperCase().contains(q))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Hisse ara (THYAO, Garanti...)',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textMuted, size: 18),
                filled: true,
                fillColor: AppTheme.bgTertiary,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollCtrl,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(
                color: AppTheme.border.withValues(alpha: 0.3),
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (_, i) {
                final s = filtered[i];
                final isSel = s.code == widget.selected;
                return InkWell(
                  onTap: () => Navigator.of(context).pop(s.code),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color:
                                AppTheme.stockUp.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              s.code.substring(0, 1),
                              style: const TextStyle(
                                color: AppTheme.stockUp,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.code,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  )),
                              const SizedBox(height: 2),
                              Text(
                                s.name,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSel)
                          const Icon(Icons.check_circle,
                              color: AppTheme.stockUp, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _formatMoney(double v) {
  // 1234567.89 -> "1.234.567,89 ₺"
  final isNeg = v < 0;
  final abs = v.abs();
  final whole = abs.truncate();
  final frac = ((abs - whole) * 100).round().toString().padLeft(2, '0');
  final wholeStr = whole.toString();
  final buf = StringBuffer();
  for (int i = 0; i < wholeStr.length; i++) {
    final remaining = wholeStr.length - i;
    buf.write(wholeStr[i]);
    if (remaining > 1 && remaining % 3 == 1) buf.write('.');
  }
  return '${isNeg ? '-' : ''}$buf,$frac ₺';
}

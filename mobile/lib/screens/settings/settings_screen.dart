/// MK AI - Ayarlar / Profil Ekrani
///
/// Bolumler:
/// 1. Profil  - Avatar + isim duzenleme + renk paleti
/// 2. Hesap   - Favoriler/kaydedilenler/okunmuslar/sohbet sayisi (her birini sil)
/// 3. Baglanti - API URL + baglanti testi
/// 4. Veriler  - Tum lokal veriyi sifirla (tehlikeli)
/// 5. Hakkinda - Surum, gelistirici, risk uyarisi, telegram link
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/api_client.dart';

// Avatar icin onceden tanimli renk paleti
const _avatarColors = [
  AppTheme.stockUp,           // neon yesil
  Color(0xFF5B8DEF),          // mavi
  Colors.amber,
  Color(0xFFFF6B35),          // turuncu
  Colors.purpleAccent,
  Color(0xFFFF3B7B),          // pembe
];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _testing = false;
  String? _testResult;
  bool? _testSuccess;

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
      _testSuccess = null;
    });
    try {
      final sw = Stopwatch()..start();
      final response = await ApiClient.instance.get('/');
      sw.stop();
      final ok = response.statusCode == 200;
      setState(() {
        _testSuccess = ok;
        _testResult = ok
            ? 'Bağlantı başarılı (${sw.elapsedMilliseconds}ms)'
            : 'Sunucu yanıt verdi ama beklenmedik status: ${response.statusCode}';
      });
    } on DioException catch (e) {
      setState(() {
        _testSuccess = false;
        _testResult =
            'Bağlantı yok: ${e.message ?? "bilinmeyen hata"}';
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final favorites = ref.watch(favoritesProvider);
    final bookmarks = ref.watch(bookmarkedNewsProvider);
    final read = ref.watch(readNewsProvider);
    final messages = ref.watch(chatMessagesProvider);
    final holdings = ref.watch(portfolioProvider);

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
          'Ayarlar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _ProfileCard(profile: profile),
          const SizedBox(height: 20),

          // ---- Hesap ----
          _SectionHeader(
              label: 'Hesap',
              icon: Icons.account_circle_outlined,
              iconColor: const Color(0xFF5B8DEF)),
          const SizedBox(height: 8),
          _GroupCard(children: [
            _DataRow(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: const Color(0xFFB983FF),
              label: 'Portföy Pozisyonları',
              value: '${holdings.length} pozisyon',
              onDelete: holdings.isEmpty
                  ? null
                  : () => _confirmDelete(
                        context,
                        title: 'Portföyü Sil',
                        body:
                            '${holdings.length} pozisyon (maliyet bilgileri dahil) silinecek.',
                        onConfirm: () =>
                            ref.read(portfolioProvider.notifier).clearAll(),
                      ),
            ),
            const _Divider(),
            _DataRow(
              icon: Icons.star_rounded,
              iconColor: Colors.amber,
              label: 'Favoriler',
              value: '${favorites.length} hisse',
              onDelete: favorites.isEmpty
                  ? null
                  : () => _confirmDelete(
                        context,
                        title: 'Favorileri Sil',
                        body: '${favorites.length} favori hissen silinecek.',
                        onConfirm: () async {
                          for (final c in [...favorites]) {
                            await ref
                                .read(favoritesProvider.notifier)
                                .remove(c);
                          }
                        },
                      ),
            ),
            const _Divider(),
            _DataRow(
              icon: Icons.bookmark_rounded,
              iconColor: Colors.purpleAccent,
              label: 'Kaydedilen Haberler',
              value: '${bookmarks.length} haber',
              onDelete: bookmarks.isEmpty
                  ? null
                  : () => _confirmDelete(
                        context,
                        title: 'Kaydedilen Haberleri Sil',
                        body: '${bookmarks.length} haber silinecek.',
                        onConfirm: () => ref
                            .read(bookmarkedNewsProvider.notifier)
                            .clearAll(),
                      ),
            ),
            const _Divider(),
            _DataRow(
              icon: Icons.visibility_rounded,
              iconColor: const Color(0xFF5B8DEF),
              label: 'Okundu İşareti',
              value: '${read.length} link',
              onDelete: read.isEmpty
                  ? null
                  : () => _confirmDelete(
                        context,
                        title: 'Okundu Geçmişini Sil',
                        body: '${read.length} okundu kaydı silinecek.',
                        onConfirm: () =>
                            ref.read(readNewsProvider.notifier).clearAll(),
                      ),
            ),
            const _Divider(),
            _DataRow(
              icon: Icons.auto_awesome_rounded,
              iconColor: AppTheme.stockUp,
              label: 'Sohbet Geçmişi',
              value: '${messages.length} mesaj',
              onDelete: messages.isEmpty
                  ? null
                  : () => _confirmDelete(
                        context,
                        title: 'Sohbeti Sil',
                        body:
                            '${messages.length} mesaj kalıcı olarak silinecek.',
                        onConfirm: () => ref
                            .read(chatMessagesProvider.notifier)
                            .clearMessages(),
                      ),
            ),
          ]),

          const SizedBox(height: 20),

          // ---- Baglanti ----
          _SectionHeader(
              label: 'Bağlantı',
              icon: Icons.cloud_outlined,
              iconColor: AppTheme.stockUp),
          const SizedBox(height: 8),
          _GroupCard(children: [
            _InfoTile(
              icon: Icons.link_rounded,
              iconColor: AppTheme.stockUp,
              label: 'API Adresi',
              value: AppConfig.apiBaseUrl,
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: AppConfig.apiBaseUrl));
                _toast(context, 'API URL kopyalandı');
              },
            ),
            const _Divider(),
            _InfoTile(
              icon: Icons.timer_outlined,
              iconColor: const Color(0xFF5B8DEF),
              label: 'İstek zaman aşımı',
              value: '${AppConfig.httpTimeout} saniye',
            ),
            const _Divider(),
            _ActionRow(
              icon: _testing
                  ? Icons.hourglass_top_rounded
                  : Icons.wifi_tethering_rounded,
              iconColor: AppTheme.stockUp,
              label: _testing ? 'Test ediliyor...' : 'Bağlantıyı test et',
              onTap: _testing ? null : _testConnection,
            ),
            if (_testResult != null) ...[
              const _Divider(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (_testSuccess ?? false
                            ? AppTheme.stockUp
                            : AppTheme.stockDown)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (_testSuccess ?? false
                              ? AppTheme.stockUp
                              : AppTheme.stockDown)
                          .withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testSuccess ?? false
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: _testSuccess ?? false
                            ? AppTheme.stockUp
                            : AppTheme.stockDown,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _testSuccess ?? false
                                ? AppTheme.stockUp
                                : AppTheme.stockDown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ]),

          const SizedBox(height: 20),

          // ---- Tehlikeli Bolge ----
          _SectionHeader(
              label: 'Tehlikeli Bölge',
              icon: Icons.warning_amber_rounded,
              iconColor: AppTheme.stockDown),
          const SizedBox(height: 8),
          _GroupCard(children: [
            _ActionRow(
              icon: Icons.restart_alt_rounded,
              iconColor: AppTheme.stockDown,
              label: 'Tüm Verileri Sıfırla',
              subtitle:
                  'Favoriler, sohbet, kaydedilenler, profil — hepsi silinir',
              destructive: true,
              onTap: () => _confirmDelete(
                context,
                title: 'TÜM VERİYİ Sıfırla?',
                body:
                    'Favoriler, kaydedilen haberler, okunmuş kayıtları, sohbet geçmişin ve profilin silinecek. Bu işlem geri alınamaz.',
                confirmLabel: 'Hepsini Sil',
                onConfirm: () => resetAllLocalData(ref),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ---- Hakkinda ----
          _SectionHeader(
              label: 'Hakkında',
              icon: Icons.info_outline_rounded,
              iconColor: AppTheme.textMuted),
          const SizedBox(height: 8),
          _GroupCard(children: [
            _InfoTile(
              icon: Icons.smartphone_rounded,
              iconColor: AppTheme.textMuted,
              label: 'Uygulama',
              value: '${AppConfig.appName} v${AppConfig.appVersion}',
            ),
            const _Divider(),
            _InfoTile(
              icon: Icons.person_outline_rounded,
              iconColor: AppTheme.textMuted,
              label: 'Geliştirici',
              value: AppConfig.developerName,
            ),
            const _Divider(),
            _ActionRow(
              icon: Icons.shield_outlined,
              iconColor: Colors.amber,
              label: 'Risk Uyarısı',
              onTap: () => _showRiskDialog(context),
            ),
            const _Divider(),
            _ActionRow(
              icon: Icons.public_rounded,
              iconColor: const Color(0xFF5B8DEF),
              label: 'Web Sitesi',
              onTap: () => launchUrlString(
                'https://m-koray.online',
                mode: LaunchMode.externalApplication,
              ),
            ),
          ]),

          const SizedBox(height: 20),

          Center(
            child: Text(
              'MK AI © ${DateTime.now().year} • Made with ',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 250.ms),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context, {
    required String title,
    required String body,
    required Future<void> Function() onConfirm,
    String confirmLabel = 'Sil',
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: Text(title,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 16)),
        content: Text(body,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel,
                style: const TextStyle(color: AppTheme.stockDown)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await onConfirm();
    if (!context.mounted) return;
    _toast(context, 'Silindi');
  }
}

// ============================ PROFILE CARD ============================
class _ProfileCard extends ConsumerWidget {
  final UserProfile profile;
  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _avatarColors[profile.avatarColorIndex % _avatarColors.length];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            AppTheme.bgSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showNameDialog(context, ref, profile),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.35),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      profile.initial,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'MK AI Kullanıcısı',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded,
                    color: AppTheme.textPrimary, size: 18),
                onPressed: () => _showNameDialog(context, ref, profile),
                tooltip: 'Adı düzenle',
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Avatar renk paleti
          Row(
            children: [
              const Text(
                'Avatar rengi',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_avatarColors.length, (i) {
                    final c = _avatarColors[i];
                    final selected = profile.avatarColorIndex == i;
                    return GestureDetector(
                      onTap: () => ref
                          .read(userProfileProvider.notifier)
                          .setAvatarColor(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: selected ? 26 : 22,
                        height: selected ? 26 : 22,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppTheme.textPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                color: AppTheme.bgPrimary, size: 14)
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNameDialog(
      BuildContext context, WidgetRef ref, UserProfile profile) {
    final ctrl = TextEditingController(text: profile.displayName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: const Text('Adın nedir?',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Adın',
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.bgTertiary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(userProfileProvider.notifier)
                  .setName(ctrl.text.trim().isEmpty ? 'Misafir' : ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Kaydet',
                style: TextStyle(
                    color: AppTheme.stockUp, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ============================ SHARED WIDGETS ============================
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 12),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final List<Widget> children;
  const _GroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Divider(
        color: AppTheme.border.withValues(alpha: 0.4),
        height: 1,
        indent: 16,
        endIndent: 16,
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onLongPress;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onDelete;

  const _DataRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.textMuted, size: 18),
              onPressed: onDelete,
              tooltip: 'Sil',
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Boş',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: destructive
                          ? AppTheme.stockDown
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

// ============================ DIALOGS ============================
void _showRiskDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgSecondary,
      title: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Text('Risk Uyarısı',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        ],
      ),
      content: const SingleChildScrollView(
        child: Text(
          AppConfig.riskWarning,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12.5,
            height: 1.55,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anladım',
              style: TextStyle(
                  color: AppTheme.stockUp, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppTheme.bgTertiary,
      content: Text(message,
          style: const TextStyle(color: AppTheme.textPrimary)),
      duration: const Duration(seconds: 2),
    ),
  );
}

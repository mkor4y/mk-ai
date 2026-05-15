/// MK AI — Akıllı Yatırım Asistanı
///
/// Flutter mobil uygulama giriş noktası.
/// Riverpod + GoRouter + Dark Fintech Theme.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'config/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle (varsa)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('.env dosyası yüklenemedi, varsayılan ayarlar kullanılacak: $e');
  }

  // Status bar stilini ayarla (şeffaf, beyaz ikonlar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgSecondary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: MKAIApp(),
    ),
  );
}

class MKAIApp extends StatelessWidget {
  const MKAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MK AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}

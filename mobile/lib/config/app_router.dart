/// MK AI - GoRouter Navigasyon Yapılandırması
library;

import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/analysis/analysis_screen.dart';
import '../screens/news/saved_news_screen.dart';
import '../screens/news/news_webview_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/portfolio/portfolio_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Ana Sayfa (Bottom Nav)
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Hisse Analiz Detay
    GoRoute(
      path: '/analysis/:code',
      builder: (context, state) {
        final code = state.pathParameters['code'] ?? 'THYAO';
        return AnalysisScreen(stockCode: code);
      },
    ),

    // Kaydedilen Haberler
    GoRoute(
      path: '/saved-news',
      builder: (context, state) => const SavedNewsScreen(),
    ),

    // In-app WebView (haber linki)
    GoRoute(
      path: '/news-webview',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? const {};
        return NewsWebViewScreen(
          url: extra['url'] ?? '',
          title: extra['title'] ?? '',
        );
      },
    ),

    // Ayarlar / Profil
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // Portfoy
    GoRoute(
      path: '/portfolio',
      builder: (context, state) => const PortfolioScreen(),
    ),
  ],
);

/// MK AI - GoRouter Navigasyon Yapılandırması
library;

import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/analysis/analysis_screen.dart';

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
  ],
);

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MK AI - Minimalist Pro Theme (Midas/Robinhood Style)
/// OLED Pure Black, Neon Green, Neon Red. No Shadows. No Cards.
class AppTheme {
  // Pure Black & Minimalist Palette
  static const Color bgPrimary = Color(0xFF000000);    // Pure OLED Black
  static const Color bgSecondary = Color(0xFF050505);  // Extremely dark gray for slight elevation
  static const Color bgTertiary = Color(0xFF111111);   // For search bars / inputs
  
  static const Color accent = Color(0xFFE0E0E0);       // Whiteish for active elements
  static const Color surface = Color(0xFF000000);      // Surfaces are also pure black
  
  static const Color border = Color(0xFF1F1F1F);       // Very subtle borders
  
  // Neon Market Colors (The Robinhood/Midas touch)
  static const Color stockUp = Color(0xFF00FF5E);      // Bright Neon Green
  static const Color stockDown = Color(0xFFFF3B30);    // Bright Neon Red
  static const Color stockNeutral = Color(0xFF8E8E93); // Neutral Gray

  // Typography Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFEBEBF5);
  static const Color textMuted = Color(0xFF8E8E93);

  // Common styles
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgPrimary,
    primaryColor: accent,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      surface: bgPrimary,
      error: stockDown,
    ),
    
    // Typography - Inter (Clean, geometric, pro)
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(color: textPrimary, fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -1.5),
      displayMedium: GoogleFonts.inter(color: textPrimary, fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.0),
      headlineMedium: GoogleFonts.inter(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleLarge: GoogleFonts.inter(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 16),
      bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 14),
      labelSmall: GoogleFonts.inter(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    ),
    
    // UI Elements
    appBarTheme: const AppBarTheme(
      backgroundColor: bgPrimary,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgPrimary,
      elevation: 0,
      selectedItemColor: textPrimary,
      unselectedItemColor: Color(0xFF48484A),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    
    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgTertiary,
        foregroundColor: textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );

  // Helper methods
  static Color signalColor(String signal) {
    final s = signal.toUpperCase();
    if (s.contains('AL') || s.contains('POZİTİF') || s.contains('BULL')) return stockUp;
    if (s.contains('SAT') || s.contains('NEGATİF') || s.contains('BEAR')) return stockDown;
    return stockNeutral;
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF00E676); // Emerald Green Accent
  static const Color primaryDark = Color(0xFF00A859);
  static const Color secondary = Color(0xFF29B6F6); // Sky Blue Accent
  static const Color accentGold = Color(0xFFFFC107);
  
  static const Color bgDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF21262D);
  static const Color borderDark = Color(0xFF30363D);

  static const Color textWhite = Color(0xFFF0F6FC);
  static const Color textMuted = Color(0xFF8B949E);

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surfaceDark,
      ),
      textTheme: GoogleFonts.cairoTextTheme(baseTextTheme).apply(
        bodyColor: textWhite,
        displayColor: textWhite,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textWhite,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
